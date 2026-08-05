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
  # builds every tool and pushes the results to Cachix, so users download
  # prebuilt store paths instead of compiling. Trusted users pick this up
  # automatically; others run `cachix use ctftools` or pass
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
            config.allowBroken = true;   # some upstreams flap in nixpkgs (e.g. qiling)
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
      # (the ~31 nixpkgs passthroughs are already served by cache.nixos.org).
      # cross2's `cross2` bundle is a symlink aggregate; the real work is its
      # per-target cross2-<target> derivations, which build in the toolchains
      # matrix (not the light per-tool build). Keep the bundle out of ciTargets.
      ciExclude = [ "cross2" ];

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
          # `nix profile install .` — the reliably-building nixpkgs-backed set,
          # collisions tolerated (many tools ship their own gdb/python/etc).
          default = pkgs.buildEnv {
            name = "ctf-tools";
            paths = builtins.attrValues (removeAttrs passthrough [ "qiling" ]);
            ignoreCollisions = true;
          };
        });
    };
}
