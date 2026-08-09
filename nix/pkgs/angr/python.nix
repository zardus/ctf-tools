# A python312 whose `angr` attribute is the current angr release.
#
# nixpkgs cannot give us one. At our pinned rev its angr family is internally
# inconsistent -- `angr` claims 9.2.193 while `pyvex`/`archinfo`/`cle` are still
# 9.2.154, and angr pins those `==9.2.193` -- so `python3Packages.angr` does not
# build at all, and the family it belongs to is a year behind upstream besides.
#
# So the whole family is built here from upstream's PyPI sdists rather than
# overridden: 9.3.x changed enough (a Rust extension, a CMake pyvex, protobuf
# codegen at build time, dependencies nixpkgs does not carry) that patching
# nixpkgs' 9.2.x derivations into shape would be more code than writing them,
# and much less obvious to read.
#
# What upstream's build wants, and where each piece is handled below:
#
#   pyvex     scikit-build-core + CMake (it used to be setuptools + a Makefile),
#             and it installs the libpyvex headers/library that angr's
#             unicornlib links against.
#   claripy   an exact z3-solver pin, dropped in favour of the z3 nixpkgs ships.
#   cle       uefi-firmware, which nixpkgs lacks and which is built below, and
#             pyxdia, which is dropped (see the comment on cle).
#   angr      three build steps in one: setuptools-rust builds the `rustylib`
#             cdylib, `make` builds native/unicornlib against pyvex's headers,
#             and grpc_tools.protoc generates angr/protos/*_pb2.py. Plus
#             angr-data, split out of the angr release and also missing from
#             nixpkgs, and pypcode, which nixpkgs has a major behind.
#
# This lives in its own file (rather than inside angr/default.nix) because
# nix/pkgs/angr-management/default.nix needs the very same interpreter: the GUI
# is assembled from a python package set, so the whole set has to be repaired,
# not a single derivation.
{ lib
, python312
, fetchPypi
, fetchFromGitHub
, rustPlatform
, cargo
, rustc
, cmake
, ninja
}:

let
  # The angr family releases in lockstep and pins itself `==` across packages,
  # so one version string drives archinfo/pyvex/claripy/cle/angr together.
  version = "9.3.2";
in
python312.override {
  packageOverrides = self: super: {

    # ---------------------------------------------------------------- angr ---

    archinfo = self.buildPythonPackage {
      pname = "archinfo";
      inherit version;
      pyproject = true;

      src = fetchPypi {
        pname = "archinfo";
        inherit version;
        hash = "sha256-vhN3ixMWV8VtOrXZSXD03KplnxtIO6SSeIx4xpMIUTI=";
      };

      build-system = [ self.setuptools ];

      # The sdist ships no tests; the GitHub tag does.
      doCheck = false;
      pythonImportsCheck = [ "archinfo" ];

      meta = {
        description = "Classes with architecture-specific information useful to binary analysis";
        homepage = "https://github.com/angr/archinfo";
        license = lib.licenses.bsd2;
      };
    };

    pyvex = self.buildPythonPackage {
      pname = "pyvex";
      inherit version;
      pyproject = true;

      src = fetchPypi {
        pname = "pyvex";
        inherit version;
        hash = "sha256-NNnGUCVwAMuDUgvh2wBobAdDE6L87NZSE0KvELjmHI0=";
      };

      # 9.3 builds libpyvex (and the vendored VEX) with CMake through
      # scikit-build-core, which drives cmake/ninja itself -- hence
      # dontUseCmakeConfigure, or nixpkgs' cmake hook would configure the
      # source tree behind its back.
      build-system = [ self.scikit-build-core self.cffi ];
      nativeBuildInputs = [ cmake ninja ];
      dontUseCmakeConfigure = true;

      # Upstream pins its build backend to `scikit-build-core ~=0.12.2`;
      # nixpkgs ships 1.0.2, and the build refuses to start on the mismatch.
      # Only the two settings pyvex uses (`build-dir`, `sdist.include`) matter
      # here, and both are unchanged in 1.x -- so relax the pin rather than
      # carry a second copy of the backend.
      postPatch = ''
        substituteInPlace pyproject.toml \
          --replace-fail 'scikit-build-core ~= 0.12.2' 'scikit-build-core'
      '';

      dependencies = [ self.bitstring self.cffi ];

      doCheck = false;
      pythonImportsCheck = [ "pyvex" ];

      meta = {
        description = "Python interface to libVEX and VEX IR";
        homepage = "https://github.com/angr/pyvex";
        license = with lib.licenses; [ bsd2 gpl2Only ];
      };
    };

    claripy = self.buildPythonPackage {
      pname = "claripy";
      inherit version;
      pyproject = true;

      src = fetchPypi {
        pname = "claripy";
        inherit version;
        hash = "sha256-zxsx5Pa4pgGitu3lZuiWQW8U+BQCp+VjY7bplZP5HUU=";
      };

      build-system = [ self.setuptools ];

      # claripy pins z3-solver ==4.13.0.0. nixpkgs' z3-solver is the `z3`
      # package's own Python bindings (a whole SMT solver compile), so honoring
      # the pin would mean building a second, older z3 for one Python module.
      # The pin is upstream's reproducibility choice, not an API floor --
      # claripy uses the ordinary z3 Python API -- so take the z3 nixpkgs has.
      # It is *removed* rather than relaxed because those bindings install no
      # .dist-info, so the runtime-deps check cannot see them either way
      # (nixpkgs' own claripy does the same).
      pythonRemoveDeps = [ "z3-solver" ];

      dependencies = [ self.cachetools self.z3-solver ];

      doCheck = false;
      pythonImportsCheck = [ "claripy" ];

      meta = {
        description = "Abstraction layer for constraint solvers";
        homepage = "https://github.com/angr/claripy";
        license = lib.licenses.bsd2;
      };
    };

    cle = self.buildPythonPackage {
      pname = "cle";
      inherit version;
      pyproject = true;

      src = fetchPypi {
        pname = "cle";
        inherit version;
        hash = "sha256-ARvUSwLuOJc1FS0jj4KsTKNBvRGwgdTemFZgQeQV2/k=";
      };

      build-system = [ self.setuptools ];

      # pyxdia is dropped, not packaged. Its Linux wheel is a bag of Windows
      # blobs -- Microsoft's msdia140.dll, an xdia.exe, and a loader that runs
      # them -- and its sdist builds by *downloading* those from GitHub
      # releases, which a sandboxed build cannot do. Nothing is silently
      # broken: cle imports it in a try/except and only PDB debug-symbol
      # loading for PE binaries uses it, which then logs "PDB support is
      # unavailable because pyxdia is not installed".
      #
      # arpy/lmdb: upstream pins exact versions; nixpkgs carries newer ones.
      pythonRemoveDeps = [ "pyxdia" ];
      pythonRelaxDeps = [ "arpy" ];

      dependencies = [
        self.archinfo
        self.arpy
        self.cart
        self.minidump
        self.pefile
        self.pyelftools
        self.pyvex
        self.pyxbe
        self.sortedcontainers
        self.uefi-firmware
      ];

      # The tests want the multi-gigabyte angr/binaries corpus.
      doCheck = false;
      pythonImportsCheck = [ "cle" ];

      meta = {
        description = "Python loader for many binary formats";
        homepage = "https://github.com/angr/cle";
        license = lib.licenses.bsd2;
      };
    };

    angr = self.buildPythonPackage (finalAttrs: {
      pname = "angr";
      inherit version;
      pyproject = true;

      src = fetchPypi {
        pname = "angr";
        inherit version;
        hash = "sha256-C0AyMypVEF2qmGIBWMmz7crv5/f4YpcKVtJ9rgZY4V8=";
      };

      # angr.rustylib, built by setuptools-rust out of the workspace at the
      # sdist root (native/angr).
      cargoDeps = rustPlatform.fetchCargoVendor {
        inherit (finalAttrs) src;
        hash = "sha256-zdOpD3llDK+us5OripMv+kuvqkL7kUDjSKswbolzb2o=";
      };

      nativeBuildInputs = [ rustPlatform.cargoSetupHook cargo rustc ];

      # pyvex is a *build* dependency as well as a runtime one: setup.py builds
      # native/unicornlib against libpyvex's headers and library. grpcio-tools
      # runs protoc over angr/protos/*.proto during the build.
      build-system = [
        self.setuptools
        self.setuptools-rust
        self.pyvex
        self.grpcio-tools
        self.protobuf
      ];

      # Upstream pins these exactly or with an upper bound, and nixpkgs sits
      # above each; none is an API floor angr actually needs.
      pythonRelaxDeps = [ "capstone" "lmdb" "protobuf" "pypcode" ];

      # The same two pins on the *build* side, which pythonRelaxDeps does not
      # reach. Upstream pins grpcio-tools (and protobuf <7 with it) to keep the
      # protobuf gencode stamp its protoc writes into angr/protos/*_pb2.py
      # deterministic and on the 6.x major, because the runtime protobuf must
      # be the same major as the stamp and no older. nixpkgs is a major ahead
      # on both halves *in step* -- grpcio-tools 1.82 depends on protobuf 7.35,
      # which is also what angr will import at runtime -- so the invariant the
      # pin protects still holds, one major up. The `angr.protos` import check
      # below is what actually verifies that.
      postPatch = ''
        substituteInPlace pyproject.toml \
          --replace-fail '"grpcio-tools~=1.80.0",' '"grpcio-tools",' \
          --replace-fail '"protobuf>=6.31.1,<7",' '"protobuf",'
      '';

      dependencies = [
        self.angr-data
        self.archinfo
        self.cachetools
        self.capstone
        self.cffi
        self.claripy
        self.cle
        self.cxxheaderparser
        self.gitpython
        self.lmdb
        self.msgspec
        self.mulpyplexer
        self.networkx
        self.platformdirs
        self.protobuf
        self.psutil
        self.pycparser
        self.pydemumble
        self.pypcode
        self.pyvex
        self.rich
        self.sortedcontainers
        self.sympy
        self.typing-extensions
      ];

      optional-dependencies = {
        angrDB = [ self.sqlalchemy ];
        # 9.3 asks for stock `unicorn==2.1.4`, which is exactly what nixpkgs
        # ships. (nixpkgs' `unicorn-angr`, the old angr fork this extra used to
        # need, is itself broken at our rev -- it imports pkg_resources, gone
        # in setuptools 83 -- and is no longer what angr wants.)
        unicorn = [ self.unicorn ];
      };

      # angr's own suite needs the angr/binaries corpus and a lot of wall clock.
      doCheck = false;
      # angr.protos.cfg_pb2 is one of the modules generated during the build;
      # importing it is what proves the generated code and the runtime protobuf
      # agree (a stamp/runtime mismatch raises at import).
      pythonImportsCheck = [ "angr" "angr.protos.cfg_pb2" ];

      meta = {
        description = "Powerful and user-friendly binary analysis platform";
        homepage = "https://angr.io/";
        license = lib.licenses.bsd2;
      };
    });

    # ------------------------------------------- dependencies nixpkgs lacks ---

    # angr's function/type prototype definitions, split out of the angr release
    # so they do not bloat it. Pure data plus a PyInstaller hook.
    angr-data = self.buildPythonPackage {
      pname = "angr_data";
      version = "0.1.0.post1";
      pyproject = true;

      src = fetchPypi {
        pname = "angr_data";
        version = "0.1.0.post1";
        hash = "sha256-MNpl1Hv6BQLMNEpz+sdP9GEVmM2u7d0Iq7KpR8lIDc0=";
      };

      build-system = [ self.setuptools ];

      pythonImportsCheck = [ "angr_data" ];

      meta = {
        description = "Function and type prototype definitions for angr";
        homepage = "https://github.com/angr/angr-data";
        license = lib.licenses.bsd2;
      };
    };

    # cle's UEFI firmware backend.
    uefi-firmware = self.buildPythonPackage {
      pname = "uefi_firmware";
      version = "1.16";
      pyproject = true;

      src = fetchPypi {
        pname = "uefi_firmware";
        version = "1.16";
        hash = "sha256-Fia5kwsQBvnsELde+In/wXxjLgtDpKugehCQ2QIxM+o=";
      };

      build-system = [ self.setuptools self.setuptools-scm ];

      dependencies = [ self.future ];

      pythonImportsCheck = [ "uefi_firmware" ];

      meta = {
        description = "Parser for UEFI firmware volumes, capsules and PE32+ images";
        homepage = "https://github.com/theopolis/uefi-firmware-parser";
        license = lib.licenses.bsd3;
      };
    };

    # ----------------------------------------------- version-bumped nixpkgs ---

    # libbs (via binsync) is an angr-management dependency, and nixpkgs' 3.3.0
    # does not survive the pycparser nixpkgs itself ships: its C-type parser
    # calls `pycparser.ply.yacc`, and pycparser 3.00 replaced ply with a
    # hand-written parser, so every test that touches the type parser dies on
    # "module 'pycparser' has no attribute 'ply'".
    #
    # Note what is *not* available as a fix here. Holding pycparser at 2.x --
    # what this file used to do for angr 9.2 -- is no longer possible: angr 9.3
    # requires `pycparser~=3.0`. Upstream's own fix was to drop pycparser from
    # libbs entirely in 3.8, but that release depends on declib, which pulls in
    # pyghidra/wordfreq and a binsync bump behind it; that is a lot of new
    # packaging for a collaboration plugin. So the tests are skipped and the
    # breakage stays where nixpkgs has it: binsync's "parse this C type" path
    # inside angr-management raises, and nothing else does.
    libbs = super.libbs.overridePythonAttrs (old: {
      disabledTestPaths = (old.disabledTestPaths or [ ]) ++ [
        "tests/test_client_server.py"
      ];
    });

    # One level up from libbs, and only rebuilt here because libbs was: binsync's
    # tests/test_auxiliary_server.py imports flask, which is in none of nixpkgs'
    # binsync inputs, so collection errors out. The aux server is an optional
    # binsync extra angr-management does not use.
    binsync = super.binsync.overridePythonAttrs (old: {
      disabledTestPaths = (old.disabledTestPaths or [ ]) ++ [
        "tests/test_auxiliary_server.py"
      ];
    });

    # Not an angr dependency but an angr-management one, and broken at our
    # nixpkgs rev: nixpkgs' pyqodeng-angr points at the wrong upstream tag.
    # "2.11.0" is the legacy pyqode.core fork, which still does
    # `pkg_resources.declare_namespace` in pyqode/__init__.py and so cannot be
    # built with setuptools 83 (no pkg_resources any more). Everything else in
    # nixpkgs' derivation -- the PySide6-Essentials patch, the dependency list,
    # pythonImportsCheck "pyqodeng" -- already describes the renamed 0.0.x
    # line, which is also what angr-management asks for ("pyqodeng>=0.0.10").
    # Point it at that.
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

    # angr 9.3 wants pypcode ~=4.0; nixpkgs is on 3.3.3. Same build shape, so
    # this is a source bump of nixpkgs' derivation rather than a rewrite.
    pypcode = super.pypcode.overridePythonAttrs (_: {
      version = "4.0.0";
      src = fetchFromGitHub {
        owner = "angr";
        repo = "pypcode";
        tag = "v4.0.0";
        hash = "sha256-OwnwgN2/MElH7SOwauS/hfVkgwAd0uMH0y00Ydkq+8I=";
      };
    });
  };
}
