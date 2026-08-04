{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  pname = "foresight";
  version = "0.1-unstable-2024";

  src = fetchFromGitHub {
    owner = "ALSchwalm";
    repo = "foresight";
    rev = "6f4898470a24d04391bb8a15c78a306ce5cb4fa1";
    hash = "sha256-7S+usxOc9hAleDsZqzcwKDtBw9w0EshLo+VT+tgvYq4=";
  };

  pyproject = true;
  build-system = [ python3Packages.setuptools ];

  # Pure-stdlib package; no third-party runtime dependencies.
  propagatedBuildInputs = [ ];

  # Upstream ships tests but no pytest config; skip runtime import checks.
  doCheck = false;
  pythonImportsCheck = [ "foresight" ];

  meta = {
    description = "Library for predicting the output of random number generators";
    homepage = "https://github.com/ALSchwalm/foresight";
    license = lib.licenses.mit;
    mainProgram = "foresee";
  };
}
