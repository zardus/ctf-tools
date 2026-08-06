{
  description = "ctf-tools: a collection of CTF / security-research tools, packaged as a Nix flake (channel-style). Install any tool with `nix profile install github:zardus/ctf-tools#<tool>`.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Pinned older nixpkgs that still ships a working CPython 2.7 (python27)
    # and its package set (virtualenv/pip/distorm3/pycrypto/...). Used to build
    # the Python-2-only tools faithfully (volatility 2, featherduster, qira, and
    # the `python2` tool itself) instead of stubbing them.
    nixpkgs-py2.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  # Binary cache (the Nix-native replacement for pushing Docker images): CI
  # builds this repo's own tool derivations (`.#ciTargets`) and the toolchain
  # fleet (`.#ciToolchainTargets`) and pushes the results to Cachix, so users
  # download prebuilt store paths instead of compiling. The nixpkgs passthroughs
  # are not rebuilt here — they come from cache.nixos.org. Trusted users pick
  # this up automatically; others run `cachix use ctftools` or pass
  # --accept-flake-config once.
  nixConfig = {
    extra-substituters = [ "https://ctftools.cachix.org" ];
    extra-trusted-public-keys = [ "ctftools.cachix.org-1:sBvy7vTAU6dLkJJizYtgYh4/NzpxjwRBrBGJLrVAzgA=" ];
  };

  outputs = { self, nixpkgs, nixpkgs-py2 }:
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

      # Tools CI builds and pushes to Cachix. We only cache our *own* derivations
      # (the nixpkgs passthroughs are already served by cache.nixos.org; CI just
      # checks that they still evaluate, see ciPassthroughCheck).
      #
      # cross2's `cross2` bundle is a symlink aggregate; the real work is its
      # per-target cross2-<target> derivations, which build in the toolchains
      # matrix (not the light per-tool build). Keep the bundle out of ciTargets.
      #
      # burpsuite is excluded for a different reason: it is a ~700 MB unfree
      # PortSwigger download whose meta.license has redistributable = false, and
      # everything the build job builds is pushed to the *public* ctftools cache.
      ciExclude = [ "cross2" "burpsuite" ];

      # Attribute names of the nixpkgs passthroughs. Only the names are needed
      # here and they don't depend on the package set (every value in that file
      # is a lazy thunk that attrNames never forces), so an empty `pkgs` is
      # enough — which keeps this usable from the system-independent outputs.
      passthroughNames =
        builtins.attrNames (import ./nix/passthrough.nix { pkgs = { }; });

      # What goes into the `default` aggregate profile (see `packages.default`):
      # the passthroughs, plus the tools that were passthroughs until they grew a
      # local derivation, minus the ones too big/unfree to install by default.
      # The lists are filtered against what actually exists, so moving a tool
      # between nix/passthrough.nix and nix/pkgs/ can't turn either into an
      # eval error.
      defaultNames = lib.subtractLists [ "angr" "angr-management" "burpsuite" ]
        (lib.unique (passthroughNames
                     ++ lib.intersectLists [ "hashpump-partialhash" "qiling" ] customNames));

      # The heavy toolchain builds get their own CI matrix (each is a
      # gcc+libc-from-source build): every cross2 target plus every pinned
      # crosstool-ng sample. Lists are derived from the same data the derivations
      # use, so they stay in sync. avr's crosstool build is broken -> excluded.
      cross2Targets = import ./nix/pkgs/cross2/targets.nix;
      ctHashes = import ./nix/pkgs/crosstool/hashes.nix;
      ctBrokenBuild = [ "avr" ];
    in {
      # Plain list of attr names for the CI build/docker matrices.
      ciTargets = lib.subtractLists ciExclude customNames;

      # Heavy toolchain outputs for the (separate) toolchains CI matrix.
      ciToolchainTargets =
        (map (t: "cross2-${t}") cross2Targets)
        ++ map (n: "crosstool-ng-${n}")
             (lib.subtractLists ctBrokenBuild (builtins.attrNames ctHashes));

      # The tools the README's `<!--tool-->` table is supposed to list: one row
      # per installable tool, i.e. every hand-written derivation plus every
      # nixpkgs passthrough — but not the per-target `cross2-*`/`crosstool-ng-*`
      # outputs or the `default` aggregate. CI diffs the table against this
      # (see the listcheck job), so the two can't drift apart unnoticed.
      readmeTargets = lib.sort (a: b: a < b) (lib.unique (customNames ++ passthroughNames));

      # The tools taken straight from nixpkgs. Not a build matrix — CI checks
      # them with ciPassthroughCheck below — but having the list as an output
      # means "which tools are passthroughs?" is answerable without reading
      # nix/passthrough.nix (PORTING.md quotes this set).
      ciPassthroughTargets = passthroughNames;

      packages = forAll ({ pkgs, pkgsPy2, ... }:
        let
          # tools we take straight from nixpkgs (see nix/passthrough.nix)
          passthrough = import ./nix/passthrough.nix { inherit pkgs; };
          # tools with a hand-written derivation under nix/pkgs/<name>/default.nix.
          # pkgsPy2 is put in the callPackage *scope* (auto-args), so it is
          # forwarded (via intersectAttrs) only to the tools whose function
          # actually declares a `pkgsPy2` argument — passing it as an explicit
          # override instead would error ("unexpected argument") on every tool
          # that doesn't take it.
          callPkg = lib.callPackageWith (pkgs // { inherit pkgsPy2; });
          custom = lib.genAttrs customNames (n: callPkg (pkgDir + "/${n}") { });
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
          all = passthrough // custom // crosstoolSamples // cross2Samples;
        in all // {
          # `nix profile install .` — the general-purpose profile: the
          # nixpkgs-backed set, plus the two tools that used to be passthroughs
          # (and so used to be in this profile) before they grew a local
          # derivation. Names are resolved through `all`, so a tool we have
          # since taken over resolves to our derivation, not to nixpkgs'.
          # Collisions tolerated (many tools ship their own gdb/python/etc).
          #
          # Deliberately left out — install them individually with
          # `nix profile install .#<tool>`: burpsuite (a ~700 MB unfree jar) and
          # angr/angr-management (~1 h of uncached source builds); nobody wants
          # either of those pulled in by a bare `nix profile install .`.
          default = pkgs.buildEnv {
            name = "ctf-tools";
            paths = builtins.attrValues (lib.getAttrs defaultNames all);
            ignoreCollisions = true;
          };
        });

      # Evaluation-only CI guard for the passthroughs: forcing this string
      # forces every passthrough's drvPath, so `pkgs.<foo>` disappearing from
      # nixpkgs fails CI with an error naming the attribute instead of shipping
      # a broken `.#<tool>` silently. Deliberately not a build — cache.nixos.org
      # already covers building these.
      ciPassthroughCheck = forAll ({ pkgs, ... }:
        lib.concatStringsSep "\n" (lib.mapAttrsToList (n: v: "${n} ${v.drvPath}")
          (import ./nix/passthrough.nix { inherit pkgs; })));
    };
}
