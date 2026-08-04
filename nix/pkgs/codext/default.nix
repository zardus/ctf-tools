{ lib
, python312Packages
}:

python312Packages.buildPythonApplication rec {
  pname = "codext";
  version = "1.16.5";
  pyproject = true;

  src = python312Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-sNfZ4Mo2wEW2SbWLTcYDTv67R/3gIwGcMqLFlqLSy8o=";
  };

  build-system = [
    python312Packages.setuptools
    python312Packages.setuptools-scm
  ];

  # legacycrypt is only required on python >= 3.13; python312 provides the
  # stdlib `crypt` module, so it is not needed here.
  dependencies = [
    python312Packages.markdown2
  ];

  # The upstream test suite pulls extra fixtures/network; skip it.
  doCheck = false;

  pythonImportsCheck = [ "codext" ];

  meta = {
    description = "Native Python codecs extension providing many CLI encoders/decoders";
    homepage = "https://github.com/dhondta/python-codext";
    license = lib.licenses.gpl3Plus;
    mainProgram = "codext";
  };
}
