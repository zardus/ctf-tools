{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, pkgsPy2
}:

# UPSTREAM (ctf-tools/volatility/install):
#   git clone --depth 1 https://github.com/volatilityfoundation/volatility
#   python2 -m virtualenv venv
#   venv/bin/pip2 install -e ./volatility
#   venv/bin/pip2 install distorm3
#   venv/bin/pip2 install pycrypto
#   ln -s ../venv/bin/vol* bin/
#
# Volatility 2 is a Python-2-only memory-forensics framework. We build it
# faithfully against the pinned nixos-23.05 python27 package set (pkgsPy2),
# which still ships the native distorm3 + pycrypto extensions the installer
# pip-installs. Rather than a virtualenv we assemble the interpreter with
# python27.withPackages and wrap the shipped vol.py as `volatility`/`vol.py`.

let
  py2 = pkgsPy2.python27Packages;

  # The distorm3 in nixos-23.05's python27 set is 3.5.2, which upstream marked
  # python3-only (its build refuses python2.7). Build the last py2-compatible
  # release (3.4.4) inline from PyPI instead.
  distorm3 = py2.buildPythonPackage rec {
    pname = "distorm3";
    version = "3.4.4";
    src = py2.fetchPypi {
      inherit pname version;
      hash = "sha256-ZVZ8rdOb0zz8fqsPBdNZTY+Wuuh29kdrG8YZUKeqNj8=";
    };
    doCheck = false;
  };

  pythonEnv = pkgsPy2.python27.withPackages (ps: with ps; [
    distorm3
    pycrypto
    pycryptodome
  ]);
in
stdenv.mkDerivation rec {
  pname = "volatility";
  version = "2.6.1";

  src = fetchFromGitHub {
    owner = "volatilityfoundation";
    repo = "volatility";
    rev = version;
    hash = "sha256-LhvYZZqcWolgkgfrdgyYAR6RO2eSznDmVGOzcSlVIu0=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/volatility" "$out/bin"
    cp -r . "$out/share/volatility"

    makeWrapper "${pythonEnv}/bin/python2.7" "$out/bin/volatility" \
      --add-flags "$out/share/volatility/vol.py"
    ln -s "$out/bin/volatility" "$out/bin/vol.py"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Advanced memory forensics framework (Volatility 2, Python 2)";
    longDescription = ''
      The Volatility Framework is an open collection of tools for the
      extraction of digital artifacts from volatile memory (RAM) samples.
      This is the legacy Python 2 series (volatilityfoundation/volatility),
      built against a pinned python27 with the native distorm3 and pycrypto
      extensions, matching the original ctf-tools installer.
    '';
    homepage = "https://github.com/volatilityfoundation/volatility";
    mainProgram = "volatility";
    platforms = platforms.unix;
    license = licenses.gpl2Plus;
  };
}
