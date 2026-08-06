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

  # `decomp2dbg --install` appends `source <pkg>/d2d_client.py` to ~/.gdbinit.
  # That line can never work here (see postInstall), so make the installer
  # emit the sys.path-repairing shim instead -- otherwise it cheerfully
  # writes a permanently erroring line into the user's gdbinit.
  postPatch = ''
    substituteInPlace decomp2dbg/installer.py \
      --replace-fail 'self.pkg_path / "d2d_client.py"' \
                     "Path(\"$out/share/decomp2dbg/d2d.py\")"
  '';

  # gdb embeds its own Python, which has no idea about this package's
  # site-packages, so sourcing d2d_client.py directly fails with
  # ModuleNotFoundError and the `decompiler` command is never registered.
  # (A wrapper cannot help: gdb `source`s the file into its interpreter, it
  # never spawns a process we could set PYTHONPATH on.) Ship a shim that
  # prepends the closure to sys.path and then executes the real client in
  # the *same* globals -- d2d_client.py sniffs globals() for `gef`/`pwndbg`
  # to pick its frontend, so it must not be run in a fresh namespace.
  postInstall = ''
    mkdir -p $out/share/decomp2dbg
    cat > $out/share/decomp2dbg/d2d.py <<EOF
    import sys
    sys.path[0:0] = "${python3Packages.makePythonPath dependencies}".split(":")
    sys.path.insert(0, "$out/${python3Packages.python.sitePackages}")
    _d2d = "$out/${python3Packages.python.sitePackages}/decomp2dbg/d2d_client.py"
    exec(compile(open(_d2d).read(), _d2d, "exec"))
    EOF
  '';

  pythonImportsCheck = [ "decomp2dbg" ];

  meta = {
    description = "A decompiler-to-debugger bridge for syncing decompiler symbols into gdb (load the gdb half with `source <pkg>/share/decomp2dbg/d2d.py`, or let `decomp2dbg --install` add it to ~/.gdbinit)";
    homepage = "https://github.com/mahaloz/decomp2dbg";
    license = lib.licenses.bsd2;
    mainProgram = "decomp2dbg";
  };
}
