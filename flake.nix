{
  description = "ctf-tools: a collection of CTF / security-research tools, packaged as a Nix flake (channel-style). Install any tool with `nix profile install github:zardus/ctf-tools#<tool>`.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # cross2 and crosstool are intentionally excluded from global upgrades.
    # Keep their whole package scope on the last validated nixpkgs revision.
    nixpkgs-toolchains.url =
      "github:NixOS/nixpkgs/104240a772428cc2e20d8fd86c9ddbb886bbaff2";
    # Pinned older nixpkgs that still ships a working CPython 2.7 (python27)
    # and its package set (virtualenv/pip/distorm3/pycrypto/...). Used to build
    # the Python-2-only tools faithfully (volatility 2, featherduster, qira, and
    # the `python2` tool itself) instead of stubbing them.
    nixpkgs-py2.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  # Binary cache (the Nix-native replacement for pushing Docker images): CI
  # builds this repo's own tool derivations and locally overridden passthroughs
  # (`.#ciTargets`), plus the toolchain fleet (`.#ciToolchainTargets`), and
  # pushes the results to Cachix so users download prebuilt store paths instead
  # of compiling. Unchanged nixpkgs passthroughs come from cache.nixos.org.
  # Trusted users pick this up automatically; others run `cachix use ctftools`
  # or pass --accept-flake-config once.
  nixConfig = {
    extra-substituters = [ "https://ctftools.cachix.org" ];
    extra-trusted-public-keys = [ "ctftools.cachix.org-1:sBvy7vTAU6dLkJJizYtgYh4/NzpxjwRBrBGJLrVAzgA=" ];
  };

  outputs = { self, nixpkgs, nixpkgs-toolchains, nixpkgs-py2 }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      lib = nixpkgs.lib;

      forAll = f: lib.genAttrs systems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;   # ida, ghidra, burpsuite, tor-browser, ...
            # No allowBroken: it was here for nixpkgs' `qiling`, which we now
            # build ourselves (nix/pkgs/qiling). Leaving it on would hide the
            # next upstream breakage, which is precisely the signal CI's
            # passthrough check exists to keep.
          };
          # Python-2 package set. python27 is EOL/insecure, so allow it explicitly.
          pkgsPy2 = import nixpkgs-py2 {
            inherit system;
            config.allowUnfree = true;
            config.allowInsecurePredicate = _: true;
          };
        in f { inherit system pkgs pkgsPy2; });

      pkgDir = ./nix/pkgs;
      customNames = builtins.attrNames
        (lib.filterAttrs (_: t: t == "directory") (builtins.readDir pkgDir));

      # Tools CI builds and pushes to Cachix. We cache our own derivations plus
      # passthroughs with repository-local overrides; unchanged nixpkgs
      # passthroughs are already served by cache.nixos.org and CI only checks
      # that they still evaluate (see ciPassthroughCheck).
      #
      # cross2's `cross2` bundle is a symlink aggregate; the real work is its
      # per-target cross2-<target> derivations, which build in the toolchains
      # matrix (not the light per-tool build). Keep the bundle out of ciTargets.
      #
      # burpsuite is excluded for a different reason: it is a ~700 MB unfree
      # PortSwigger download whose meta.license has redistributable = false, and
      # everything the build job builds is pushed to the *public* ctftools cache.
      ciExclude = [ "cross2" "burpsuite" ];

      # These live in passthrough.nix but no longer produce the stock nixpkgs
      # output, so cache our repaired derivations rather than assuming the
      # official cache has them.
      ciOverriddenPassthroughs = [ "dirsearch" ];

      # Attribute names of the nixpkgs passthroughs. Only the names are needed
      # here and they don't depend on the package set (every value in that file
      # is a lazy thunk that attrNames never forces), so an empty `pkgs` is
      # enough — which keeps this usable from the system-independent outputs.
      passthroughNames =
        builtins.attrNames (import ./nix/passthrough.nix { pkgs = { }; });

      # Human-facing tools, as distinct from the generated cross-toolchain
      # variants and aggregate profile outputs.
      catalogNames = lib.sort (a: b: a < b)
        (lib.unique (customNames ++ passthroughNames));

      # What goes into the `default` aggregate profile (see `packages.default`).
      # Keep this set explicit: adding a nixpkgs forward should not silently add
      # several GiB to every bare `nix profile install .`. These are the original
      # passthrough-backed defaults; the expanded catalog remains available as
      # individual `.#<tool>` outputs. The two custom names were passthroughs in
      # the pre-Nix collection and remain in the general-purpose profile.
      defaultPassthroughNames = [
        "commix" "elfkickers" "gdb" "gef" "ghidra" "hash-identifier"
        "honggfuzz" "mitmproxy" "msieve" "one_gadget" "pdf-parser" "pkcrack"
        "pwninit" "pwntools" "qemu" "rappel" "ropper" "rp++" "seccomp-tools"
        "sslsplit" "stegsolve" "tor-browser" "valgrind" "volatility3" "xortool"
        "zsteg"
      ];
      defaultNames = lib.unique
        (lib.intersectLists defaultPassthroughNames passthroughNames
         ++ lib.intersectLists [ "hashpump-partialhash" "qiling" ] customNames);

      # Packages whose own metadata is broader than one of their dependencies.
      # Keep this explicit: ARM CI should fail on a new evaluation problem, not
      # silently hide arbitrary failures behind tryEval.
      aarch64Unsupported = [ "apktool" ];

      # The heavy toolchain builds get their own CI matrix (each is a
      # gcc+libc-from-source build): every cross2 target plus every pinned
      # crosstool-ng sample. Lists are derived from the same data the derivations
      # use, so they stay in sync. avr's crosstool build is broken -> excluded.
      cross2Targets = import ./nix/pkgs/cross2/targets.nix;
      ctHashes = import ./nix/pkgs/crosstool/hashes.nix;
      ctBrokenBuild = [ "avr" ];
      toolchainNames =
        (map (t: "cross2-${t}") cross2Targets)
        ++ map (n: "crosstool-ng-${n}")
             (lib.subtractLists ctBrokenBuild (builtins.attrNames ctHashes));
    in {
      # Plain list of attr names for the CI build/docker matrices.
      ciTargets = lib.sort (a: b: a < b)
        (lib.subtractLists ciExclude customNames ++ ciOverriddenPassthroughs);

      # Heavy toolchain outputs for the (separate) toolchains CI matrix.
      ciToolchainTargets = toolchainNames;

      # The tools the README's `<!--tool-->` table is supposed to list: one row
      # per installable tool, i.e. every hand-written derivation plus every
      # nixpkgs passthrough — but not the per-target `cross2-*`/`crosstool-ng-*`
      # outputs or the `default` aggregate. CI diffs the table against this
      # (see the listcheck job), so the two can't drift apart unnoticed.
      readmeTargets = catalogNames;

      # System-specific lists for manage-tools. Unlike readmeTargets, these
      # omit packages filtered out by platform metadata (for example, x86-only
      # tools on ARM). Aggregate outputs are not members of either list.
      catalogTargets = lib.mapAttrs
        (_: ps: lib.intersectLists catalogNames (builtins.attrNames ps))
        self.packages;
      toolchainTargets = lib.mapAttrs
        (_: ps: lib.intersectLists toolchainNames (builtins.attrNames ps))
        self.packages;

      # The tools sourced from nixpkgs, including thin local overrides. This is
      # not generally a build matrix — CI checks them with ciPassthroughCheck
      # below — but having the list as an output means "which tools are
      # passthroughs?" is answerable without reading nix/passthrough.nix.
      ciPassthroughTargets = passthroughNames;

      packages = forAll ({ system, pkgs, pkgsPy2, ... }:
        let
          pkgsToolchains = import nixpkgs-toolchains {
            inherit system;
            config.allowUnfree = true;
          };
          # tools we take straight from nixpkgs (see nix/passthrough.nix)
          passthrough = import ./nix/passthrough.nix { inherit pkgs; };
          # tools with a hand-written derivation under nix/pkgs/<name>/default.nix.
          # pkgsPy2 is put in the callPackage *scope* (auto-args), so it is
          # forwarded (via intersectAttrs) only to the tools whose function
          # actually declares a `pkgsPy2` argument — passing it as an explicit
          # override instead would error ("unexpected argument") on every tool
          # that doesn't take it.
          callPkg = lib.callPackageWith (pkgs // { inherit pkgsPy2; });
          callPkgToolchains = pkgsToolchains.lib.callPackageWith
            (pkgsToolchains // { inherit pkgsPy2; });
          custom = lib.genAttrs customNames (n:
            (if builtins.elem n [ "cross2" "crosstool" ]
             then callPkgToolchains
             else callPkg)
              (pkgDir + "/${n}") { });
          # crosstool builds a whole fleet of per-sample cross toolchains; surface
          # each pinned/buildable one as its own top-level `crosstool-ng-<sample>`
          # output (so they land in the CI/Cachix build matrix individually).
          crosstoolSamples = lib.mapAttrs'
            (n: v: lib.nameValuePair "crosstool-ng-${n}" v)
            (custom.crosstool.pinnedToolchains or { });
          # each cross2 target as its own cross2-<target> output
          cross2Samples = lib.mapAttrs'
            (n: v: lib.nameValuePair "cross2-${n}" v)
            (custom.cross2.targets or { });
          # The generated toolchain fleet is built, cached, and supported only
          # on x86_64. In particular, do not duplicate these very large outputs
          # in the size-limited ctftools cache for aarch64.
          toolchainOutputs = lib.optionalAttrs (system == "x86_64-linux")
            (crosstoolSamples // cross2Samples);

          # Keep each system's package set honest. A number of upstream binary
          # releases are x86-only; exposing them on aarch64 makes `.#default`
          # fail during evaluation before users can install anything. Packages
          # without explicit platform metadata remain available, as usual in
          # nixpkgs. ARM outputs are intentionally not pushed to our Cachix
          # cache: see the evaluation-only guard in .github/workflows/nix.yml.
          unfiltered = passthrough // custom // toolchainOutputs;
          available = lib.filterAttrs (n: pkg:
            (system == "x86_64-linux" || n != "cross2")
            && (system != "aarch64-linux" || !(builtins.elem n aarch64Unsupported))
            && lib.meta.availableOn pkgs.stdenv.hostPlatform pkg
          ) unfiltered;
          availableNames = builtins.attrNames available;
          supportedDefaultNames = lib.intersectLists defaultNames availableNames;
          supportedCatalogNames = lib.intersectLists catalogNames availableNames;
          supportedToolchainNames = lib.intersectLists toolchainNames availableNames;
          aggregate = name: names: pkgs.buildEnv {
            inherit name;
            paths = builtins.attrValues (lib.getAttrs names available);
            ignoreCollisions = true;
          };
        in available // {
          # `nix profile install .` — the curated general-purpose profile from
          # defaultNames. Names are resolved through `available`, so a tool we have
          # since taken over resolves to our derivation, not to nixpkgs'.
          # Collisions tolerated (many tools ship their own gdb/python/etc).
          #
          # Deliberately left out — install them individually with
          # `nix profile install .#<tool>`: burpsuite (a ~700 MB unfree jar) and
          # angr/angr-management (~1 h of uncached source builds); nobody wants
          # either of those pulled in by a bare `nix profile install .`.
          default = pkgs.buildEnv {
            name = "ctf-tools";
            paths = builtins.attrValues (lib.getAttrs supportedDefaultNames available);
            ignoreCollisions = true;
          };

          # Every catalogued tool as one atomic profile entry. The generated
          # cross-toolchain variants are separate because they dwarf the rest
          # of the catalog and are useful as a group in their own right.
          all = aggregate "ctf-tools-all" supportedCatalogNames;
        } // lib.optionalAttrs (supportedToolchainNames != [ ]) {
          "all-toolchains" = aggregate
            "ctf-tools-all-toolchains" supportedToolchainNames;
          everything = aggregate "ctf-tools-everything"
            (supportedCatalogNames ++ supportedToolchainNames);
        });

      # Evaluation-only CI guard for the passthroughs: forcing this string
      # forces every passthrough's drvPath, so `pkgs.<foo>` disappearing from
      # nixpkgs fails CI with an error naming the attribute instead of shipping
      # a broken `.#<tool>` silently. Deliberately not a build: most underlying
      # packages are already covered by cache.nixos.org; compatibility
      # overrides that need a distinct build are promoted into ciTargets.
      ciPassthroughCheck = forAll ({ system, pkgs, ... }:
        let
          candidates = import ./nix/passthrough.nix { inherit pkgs; };
          available = lib.filterAttrs (n: pkg:
            (system != "aarch64-linux" || !(builtins.elem n aarch64Unsupported))
            && lib.meta.availableOn pkgs.stdenv.hostPlatform pkg
          ) candidates;
        in lib.concatStringsSep "\n"
          (lib.mapAttrsToList (n: v: "${n} ${v.drvPath}") available));
    };
}
