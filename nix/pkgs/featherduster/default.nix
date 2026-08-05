{ lib
, pkgsPy2
}:

# UPSTREAM (ctf-tools/featherduster/install):
#   git clone --depth=1 https://github.com/nccgroup/featherduster.git
#   python2 -m virtualenv venv
#   venv/bin/pip2 install -e ./featherduster
#   ln -s ../venv/bin/featherduster bin/
#
# FeatherDuster is a Python 2-only automated cryptanalysis tool. Its setup.py
# declares install_requires = [ 'pycrypto', 'ishell' ] and bundles the
# cryptanalib / feathermodules / featherduster packages. We build it for real
# against the pinned nixos-23.05 python27 package set (pkgsPy2), which still
# ships a maintained python27 with pycrypto/future/gnureadline. The only
# missing dependency, `ishell`, is built here from its upstream release.

let
  py2 = pkgsPy2.python27Packages;

  # ishell: "Build Interactive Shells with Python". Not in nixpkgs; build it
  # from the upstream v0.1.8 tag. Its code uses the stdlib `readline` plus
  # `from builtins import input` (the `future` shim); gnureadline is listed in
  # requirements.txt but unused at runtime, provided for completeness.
  ishell = py2.buildPythonPackage rec {
    pname = "ishell";
    version = "0.1.8";

    src = pkgsPy2.fetchFromGitHub {
      owner = "italorossi";
      repo = "ishell";
      rev = "v${version}";
      hash = "sha256-+r/5n4KCfwBGII6BTedLfWOfExnkjNu0ZHywn0SMemY=";
    };

    propagatedBuildInputs = with py2; [ future gnureadline ];

    # Test suite spins up interactive/readline sessions; skip it.
    doCheck = false;

    pythonImportsCheck = [ "ishell" "ishell.console" "ishell.command" ];

    meta = with lib; {
      description = "Build interactive shells with Python";
      homepage = "https://github.com/italorossi/ishell";
      license = licenses.mit;
    };
  };
in
py2.buildPythonApplication rec {
  pname = "featherduster";
  version = "0.3";

  src = pkgsPy2.fetchFromGitHub {
    owner = "nccgroup";
    repo = "featherduster";
    rev = "9229158e601be2e47b60f41bc862f38b12b162a3";
    hash = "sha256-CzpYk/fJ5QcTOREH26WdeCE60z7Y9Y5FsdJCjWuNlJo=";
  };

  propagatedBuildInputs = with py2; [ pycrypto ishell ];

  # Upstream ships no packaged test-runner config; the tests/ dir needs a live
  # environment. The build's own import wiring is what we care about.
  doCheck = false;

  # featherduster.py uses Python 2 implicit-relative imports (`import completer`,
  # `import advice`) which resolve fine at runtime inside the installed package,
  # but confuse a top-level import check, so only sanity-check the backend libs.
  pythonImportsCheck = [ "cryptanalib" "feathermodules" ];

  meta = with lib; {
    description = "Automated, modular cryptanalysis tool (NCC Group)";
    homepage = "https://github.com/nccgroup/featherduster";
    license = licenses.bsd3;
    mainProgram = "featherduster";
    platforms = platforms.unix;
  };
}
