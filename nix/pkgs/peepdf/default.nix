{ lib
, python312Packages
, fetchFromGitHub
, ...
}:

let
  python3Packages = python312Packages;
  # pythonaes is not packaged in nixpkgs; build it inline from PyPI.
  pythonaes = python3Packages.buildPythonPackage rec {
    pname = "pythonaes";
    version = "1.0";
    format = "setuptools";

    src = python3Packages.fetchPypi {
      inherit pname version;
      hash = "sha256-cd0xwDUAuMugb4PxdgPcyh3RwTCPva73UvNT7Rqvn2c=";
    };

    # No tests shipped in the sdist.
    doCheck = false;

    meta = {
      description = "Pure Python implementation of AES";
      homepage = "https://github.com/caller9/pythonaes";
      license = lib.licenses.asl20;
    };
  };
in
python3Packages.buildPythonApplication rec {
  pname = "peepdf";
  version = "0.4.3";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "cert-ee";
    repo = "peepdf";
    rev = "18dfba1a55651e352b9691d869375ae22d50e646";
    hash = "sha256-HtSq5YR3FNJ4s1B2A0GUZPlbqPpFPe4lJfSweffuxgM=";
  };

  # setup.py pins exact versions (jsbeautifier==1.15.1, Pillow==11.1.0, ...)
  # that differ from nixpkgs; relax them so the app builds against nixpkgs.
  pythonRelaxDeps = true;

  propagatedBuildInputs = with python3Packages; [
    jsbeautifier
    colorama
    future
    pillow
    pythonaes
  ];

  # No import-based smoke test suite wired up here; just ensure the module imports.
  pythonImportsCheck = [ "peepdf" ];

  doCheck = false;

  meta = {
    description = "Powerful Python tool to analyse PDF documents (cert-ee fork)";
    homepage = "https://github.com/cert-ee/peepdf";
    license = lib.licenses.gpl3Plus;
    mainProgram = "peepdf";
  };
}
