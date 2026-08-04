{ lib
, python312Packages
}:

let
  py = python312Packages;

  # galeodes is a small QeeqBox helper library that is not packaged in
  # nixpkgs; build it inline from PyPI so social-analyzer can import it.
  galeodes = py.buildPythonPackage rec {
    pname = "galeodes";
    version = "0.7";
    pyproject = true;

    src = py.fetchPypi {
      inherit pname version;
      hash = "sha256-MeqDmriXT9UrLi6fIw2EaD8VsKHQ4zbYtmjf8sojVr8=";
    };

    build-system = [ py.setuptools ];

    dependencies = [
      py.selenium
      py.requests
      py.pillow
    ];

    doCheck = false;
    pythonImportsCheck = [ "galeodes" ];
  };
in
py.buildPythonApplication rec {
  pname = "social-analyzer";
  version = "0.45";
  pyproject = true;

  src = py.fetchPypi {
    inherit pname version;
    hash = "sha256-GYHnHQXXx4DwFpevWGaB1nsAMI4JEviimaSfoZk2NqM=";
  };

  build-system = [ py.setuptools ];

  dependencies = [
    py.beautifulsoup4
    py.tld
    py.termcolor
    py.langdetect
    py.requests
    py.lxml
    galeodes
  ];

  doCheck = false;

  # The importable module name contains a hyphen and cannot be imported with a
  # plain `import` statement, so skip pythonImportsCheck.
  pythonImportsCheck = [ ];

  meta = {
    description = "API, CLI & Web App for analyzing and finding a person's profile across 300+ social media websites";
    homepage = "https://github.com/qeeqbox/social-analyzer";
    license = lib.licenses.agpl3Only;
    mainProgram = "social-analyzer";
  };
}
