{ lib
, python3Packages
, fetchFromGitHub
}:

# RsaCtfTool (Ganapati / RsaCtfTool) — RSA multi-attack tool.
#
# The ctf-tools installer git-clones the upstream repo into a virtualenv,
# `pip install -r requirements.txt`, and drops a bin/RsaCtfTool.py launcher.
# Upstream now ships a proper pyproject.toml with console_scripts
# `RsaCtfTool` and `rsacrack`, so we build it as a buildPythonApplication.
#
# One dependency, factordb-pycli, is not packaged in nixpkgs, so we build it
# inline below.

let
  factordb-pycli = python3Packages.buildPythonPackage rec {
    pname = "factordb-pycli";
    version = "1.3.0";
    format = "setuptools";

    src = python3Packages.fetchPypi {
      inherit pname version;
      hash = "sha256-Q88qZy/EnDifndmnZWiQlzqqZfm9LYcWXKTnqZb32ms=";
    };

    # setup.py declares setup_requires=['pytest-runner'], which triggers a
    # network fetch at build time; strip it (we don't run its tests anyway).
    postPatch = ''
      substituteInPlace setup.py \
        --replace-fail "setup_requires=['pytest-runner']," "" \
        --replace-fail "tests_require=['pytest']," ""
    '';

    propagatedBuildInputs = [ python3Packages.requests ];

    # The upstream package ships no tests.
    doCheck = false;

    pythonImportsCheck = [ "factordb" ];

    meta = with lib; {
      description = "Python client for the factordb.com factorization database";
      homepage = "https://github.com/ryosan-470/factordb-pycli";
      license = licenses.mit;
    };
  };
in
python3Packages.buildPythonApplication rec {
  pname = "rsactftool";
  version = "unstable-2026-08-04";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "Ganapati";
    repo = "RsaCtfTool";
    rev = "7c98848f1945de3e67a420871e8672f5ad9aa5d5";
    hash = "sha256-Yq0VvO6qZtTXPRmPvP+tr83B0gwIAwl49EL/Ucc919k=";
  };

  nativeBuildInputs = [
    python3Packages.setuptools
    python3Packages.wheel
    python3Packages.pythonRelaxDepsHook
  ];

  # requirements.txt pins exact versions that differ from nixpkgs; relax them.
  pythonRelaxDeps = true;

  # nixpkgs' z3-solver installs the `z3` module without dist metadata, so the
  # runtime-deps check can't see it; pytest is only a dev/test dep. Drop both
  # from the recorded metadata (the z3 module is still provided at runtime).
  pythonRemoveDeps = [ "z3-solver" "pytest" ];

  propagatedBuildInputs = with python3Packages; [
    six
    cryptography
    urllib3
    requests
    gmpy2
    pycryptodome
    tqdm
    z3-solver
    bitarray
    psutil
    factordb-pycli
  ];

  # Upstream test suite is heavy and hits the network; skip it.
  doCheck = false;

  pythonImportsCheck = [ "RsaCtfTool" ];

  meta = with lib; {
    description = "RSA multi attacks tool (attack RSA public keys and uncover private keys)";
    homepage = "https://github.com/RsaCtfTool/RsaCtfTool";
    license = licenses.mit;
    mainProgram = "RsaCtfTool";
  };
}
