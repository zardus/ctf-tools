{ lib
, python3Packages
, fetchFromGitHub
}:

let
  # decomp2dbg depends on `declib` (from binsync), which is not yet packaged in
  # nixpkgs. We build it inline here. Its `[ghidra]` extra pulls in
  # PySide6-Essentials; nixpkgs only ships the full `pyside6`, which satisfies
  # the same imports, so we use that.
  declib = python3Packages.buildPythonPackage rec {
    pname = "declib";
    version = "4.5.0";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "binsync";
      repo = "declib";
      rev = "v${version}";
      hash = "sha256-u074QMyz9plYtRNSFGxFvzRsKiOxkfjQTh2sWVdP/II=";
    };

    build-system = [ python3Packages.setuptools ];

    dependencies = with python3Packages; [
      toml
      ply
      pycparser
      setuptools
      prompt-toolkit
      tqdm
      psutil
      pyghidra
      platformdirs
      filelock
      networkx
      # [ghidra] extra: upstream asks for PySide6-Essentials, nixpkgs' pyside6
      # provides the same modules.
      pyside6
    ];

    # Upstream's console entry points import decompiler backends lazily; the
    # package itself has no importable top-level that pulls in everything.
    pythonImportsCheck = [ "declib" ];

    # Relax the strict `pycparser~=3.0` style pins against nixpkgs versions.
    dontCheckRuntimeDeps = true;

    doCheck = false;

    meta = {
      description = "Your Only Decompiler API Lib - a generic API to script in and out of decompilers";
      homepage = "https://github.com/binsync/declib";
      license = lib.licenses.bsd2;
    };
  };
in
python3Packages.buildPythonApplication rec {
  pname = "decomp2dbg";
  version = "4.0.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mahaloz";
    repo = "decomp2dbg";
    rev = "416dce4986f90c74876ddb00af18583f8de6e4fe";
    hash = "sha256-6gbigJwh35yELm0VgPJQJi5peqdyli/9kNU5qo4WY8s=";
  };

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    sortedcontainers
    pyelftools
    declib
  ];

  dontCheckRuntimeDeps = true;

  pythonImportsCheck = [ "decomp2dbg" ];

  meta = {
    description = "A decompiler-to-debugger bridge for syncing decompiler symbols into gdb (skips the interactive plugin installer)";
    homepage = "https://github.com/mahaloz/decomp2dbg";
    license = lib.licenses.bsd2;
    mainProgram = "decomp2dbg";
  };
}
