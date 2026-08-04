{ lib
, pkgsPy2
, symlinkJoin
, makeWrapper
}:

# UPSTREAM (ctf-tools/python2/install):
#   pyenv install 2.7.18   # builds CPython 2.7.18 from source
#   symlinks python2/python2.7/pip2/... into bin/
#   pip2 install virtualenv
#
# Faithful Nix equivalent: a real, working CPython 2.7 interpreter with pip,
# setuptools and virtualenv available, exposed under the usual py2 command
# names. We take it from the pinned nixpkgs-py2 input (nixos-23.05), the last
# release line that still ships a maintained python27 package set, rather than
# rebuilding pyenv's from-source install by hand. This is the same interpreter
# the volatility / featherduster / qira derivations build their venvs against.

let
  # virtualenv's modern releases pull in platformdirs>=3 which dropped Python 2,
  # so pin the last py2-native virtualenv (16.7.x: self-contained, no
  # platformdirs/filelock dep chain).
  virtualenv16 = pkgsPy2.python27Packages.buildPythonPackage rec {
    pname = "virtualenv";
    version = "16.7.12";
    src = pkgsPy2.python27Packages.fetchPypi {
      inherit pname version;
      hash = "sha256-HKCaihaEuhWRXuuzC7c5iPevR64x9IVEzIctLVYMFzg=";
    };
    doCheck = false;
  };

  pyEnv = pkgsPy2.python27.withPackages (ps: with ps; [
    pip
    setuptools
    virtualenv16
  ]);
in
symlinkJoin {
  name = "python2-${pkgsPy2.python27.version}";
  paths = [ pyEnv ];
  nativeBuildInputs = [ makeWrapper ];

  # Guarantee the classic py2 command names exist (python2, pip2), regardless
  # of which symlinks the interpreter ships.
  postBuild = ''
    mkdir -p "$out/bin"
    [ -e "$out/bin/python2" ]  || ln -s "${pyEnv}/bin/python2.7" "$out/bin/python2"
    if [ ! -e "$out/bin/pip2" ] && [ -e "$out/bin/pip2.7" ]; then
      ln -s "$out/bin/pip2.7" "$out/bin/pip2"
    fi
  '';

  meta = with lib; {
    description = "CPython 2.7 interpreter with pip + virtualenv (for legacy CTF tooling)";
    longDescription = ''
      A working Python 2.7 environment (interpreter, pip, setuptools,
      virtualenv), replacing the pyenv-based build in the original ctf-tools
      installer. Sourced from the pinned nixos-23.05 nixpkgs, the last release
      line to ship a maintained python27 package set. Python 2 is end-of-life;
      this exists only to run legacy tools that never moved to Python 3.
    '';
    mainProgram = "python2";
    platforms = platforms.unix;
    license = licenses.psfl;
  };
}
