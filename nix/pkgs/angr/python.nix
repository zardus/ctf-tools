# A python312 whose `angr` attribute actually builds.
#
# nixpkgs' python3Packages.angr is unbuildable at our pinned rev. It claims
# version 9.2.193, but:
#   * 9.2.193's setup.py hard-fails without setuptools-rust (it compiles the
#     `angr.rustylib` cdylib from native/angr), and the derivation still says
#     `build-system = [ setuptools ]`;
#   * 9.2.193 pins archinfo/cle/pyvex `==9.2.193`, while the same nixpkgs rev
#     ships those three at 9.2.154 — so even with the Rust plumbing added the
#     build dies on "Unmet dependencies: pyvex==9.2.193".
# Chasing the whole family up to 9.2.193 is worse than it looks: cle 9.2.193
# top-level-imports `pyxdia`, which is only distributed as a wheel full of
# prebuilt xdia/msdia140.dll blobs and is not in nixpkgs.
#
# So we go the other way and pin the *whole* angr family to 9.2.154 — the
# release nixpkgs' pyvex/archinfo/cle already sit on, and the exact version
# nixpkgs' angr-management is built from. That means downgrading two packages
# (claripy, ailment) that nixpkgs happens to carry ahead of the rest, and
# nothing else: 9.2.154 predates the Rust extension entirely.
#
# This lives in its own file (rather than inside angr/default.nix) because
# nix/pkgs/angr-management/default.nix needs the very same interpreter: nixpkgs'
# angr-management is built from python312.pkgs, so the fix has to be applied to
# the package *set*, not to a single derivation.
{ python312
, fetchFromGitHub
}:

let
  version = "9.2.154";

  angrSrc = { repo, hash }: fetchFromGitHub {
    owner = "angr";
    inherit repo hash;
    tag = "v${version}";
  };
in
python312.override {
  packageOverrides = self: super: {
    angr = super.angr.overridePythonAttrs (old: {
      inherit version;
      src = angrSrc {
        repo = "angr";
        hash = "sha256-aOgZXHk6GTWZAEraZQahEXUYs8LWAWv1n9GfX+2XTPU=";
      };

      # angr's setup.py builds native/unicornlib, which links against libpyvex
      # and needs its headers, so pyvex is a *build* dependency as well as a
      # runtime one (pyproject: requires = [..., "pyvex==9.2.154"]).
      build-system = (old.build-system or [ ]) ++ [ self.pyvex ];
    });

    # nixpkgs carries these two ahead of the rest of the family; angr 9.2.154
    # pins them `==9.2.154`.
    claripy = super.claripy.overridePythonAttrs (_: {
      inherit version;
      src = angrSrc {
        repo = "claripy";
        hash = "sha256-90JX+VDWK/yKhuX6D8hbLxjIOS8vGKrN1PKR8iWjt2o=";
      };
    });

    # angr monkey-patches pycparser's ply-based CParser
    # (`self.clex.filename = ...` in sim_type.py) to thread a scope stack
    # through parsing. pycparser 3.00 replaced ply with a hand-written parser
    # and made CLexer.filename a read-only property, so `import angr` dies with
    # "property 'filename' of 'CLexer' object has no setter". Current angr
    # (9.2.193) carries the identical monkey-patch, so this is not something a
    # version bump would fix — hold pycparser at the last 2.x for this
    # interpreter only. cffi works with either (its only 2.x-specific import,
    # pycparser.yacctab, sits in a function that is never called). angr also
    # reaches into pycparser.ply.{lex,yacc} directly, which 3.00 removed
    # outright, so no amount of version-bumping angr fixes this.
    pycparser = super.pycparser.overridePythonAttrs (_: {
      version = "2.22";
      src = fetchFromGitHub {
        owner = "eliben";
        repo = "pycparser";
        tag = "release_v2.22";
        hash = "sha256-RY0xQ4Mj8IfYAcypZQx4lDBmcgzYqtM4ARm9NSccBgA=";
      };
    });

    # Fallout from the pycparser pin: nothing downstream of cffi can be
    # substituted from cache.nixos.org any more, so a pile of packages that are
    # normally just downloaded now actually run their test suites here — and
    # three of them do not survive that. None is a runtime dependency of angr;
    # they arrive as test/optional deps (sniffio -> curio, rpyc -> plumbum ->
    # paramiko). Skip their tests rather than the packages:
    #   curio    — tests/test_network.py wedges forever in the sandbox
    #   paramiko — all 541 tests pass, then the interpreter segfaults
    #              ("double free or corruption") tearing down SSH threads
    #   plumbum  — test_nohup.py::test_closed_filehandles hits its 300s timeout
    curio = super.curio.overridePythonAttrs (_: { doCheck = false; });
    paramiko = super.paramiko.overridePythonAttrs (_: { doCheck = false; });
    plumbum = super.plumbum.overridePythonAttrs (_: { doCheck = false; });

    # Hard stop for the rebuild cascade. numpy's own *test* inputs reach
    # pycparser (numpy -> pytest-xdist -> execnet -> gevent -> cffi), so the pin
    # would otherwise rebuild numpy, and with it shiboken6 and pyside6 — an
    # hours-long Qt bindings compile for a package that has nothing to do with
    # angr. Take numpy from the untouched interpreter instead: its inputs then
    # match nixpkgs' exactly, so it (and everything above it) keeps substituting
    # from cache.nixos.org. Safe to mix, because numpy propagates no Python
    # dependencies that could collide with ours in a withPackages env.
    numpy = python312.pkgs.numpy;

    # nixpkgs' pyqodeng-angr points at the wrong upstream tag: "2.11.0" is the
    # legacy pyqode.core fork, which still does `pkg_resources.declare_namespace`
    # in pyqode/__init__.py and therefore cannot be built with setuptools 83
    # (no pkg_resources any more). Everything else in nixpkgs' derivation —
    # the PySide6-Essentials patch, the dependency list, pythonImportsCheck
    # "pyqodeng" — already describes the renamed 0.0.x line, which is also what
    # angr-management asks for ("pyqodeng>=0.0.10"). Point it at that.
    pyqodeng-angr = super.pyqodeng-angr.overridePythonAttrs (_: {
      # the distribution really is called "pyqodeng"; keeping nixpkgs' pname
      # would fail pythonMetadataCheckPhase, which looks the pname up in the
      # installed .dist-info, and would also fail angr-management's runtime
      # dependency check.
      pname = "pyqodeng";
      version = "0.0.14";
      src = fetchFromGitHub {
        owner = "angr";
        repo = "pyqodeng";
        tag = "v0.0.14";
        hash = "sha256-6EayPtWUd4Mruu6KbHVL3o3PUIZPfIxHqDr77o1+wjU=";
      };
    });

    # libbs (via binsync, an angr-management dependency) is a *direct*
    # pycparser consumer, and it is broken at our nixpkgs rev for exactly the
    # reason angr is: its tests die on "module 'pycparser' has no attribute
    # 'ply'". Pinning pycparser gets past that and uncovers the next layer —
    # tests/test_client_server.py spins up libbs' Ghidra headless interface and
    # fails on the missing GHIDRA_INSTALL_DIR. nixpkgs already skips libbs'
    # other Ghidra-dependent classes; this one just got missed.
    libbs = super.libbs.overridePythonAttrs (old: {
      disabledTests = (old.disabledTests or [ ]) ++ [ "TestClientServer" ];
    });

    # Same story one level up: binsync's tests/test_auxiliary_server.py imports
    # flask, which is in none of nixpkgs' binsync inputs, so collection errors
    # out. The aux server is an optional binsync extra angr-management does not
    # use.
    binsync = super.binsync.overridePythonAttrs (old: {
      disabledTestPaths = (old.disabledTestPaths or [ ]) ++ [
        "tests/test_auxiliary_server.py"
      ];
    });

    ailment = super.ailment.overridePythonAttrs (_: {
      inherit version;
      src = angrSrc {
        repo = "ailment";
        hash = "sha256-JjS+jYWrbErkb6uM0DtB5h2ht6ZMmiYOQL/Emm6wC5U=";
      };
    });
  };
}
