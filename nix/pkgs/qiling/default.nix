{ lib
, python312Packages
, fetchFromGitHub
}:

let
  py = python312Packages;

  # nixpkgs' python-registry is tagged 1.4 upstream but its setup.py still says
  # 1.3.1, so pythonMetadataCheckPhase fails the build on every interpreter.
  # The code is fine; only the declared version disagrees. Qiling asks for
  # `python-registry = "^1.3.1"`, which the 1.3.1 metadata satisfies.
  python-registry = py.python-registry.overridePythonAttrs (_: {
    dontCheckPythonMetadata = true;
  });

  # `examples/rootfs` is a git submodule (qilingframework/rootfs) holding the
  # prebuilt guest filesystems every example emulates against; the pre-nix
  # installer pulled it via `git submodule update --init --recursive`, but a
  # GitHub source tarball leaves the directory empty. Fetched separately at the
  # rev qiling's tree records for this tag, so that bumping qiling does not
  # silently re-download ~400 MB under a stale hash.
  rootfs = fetchFromGitHub {
    owner = "qilingframework";
    repo = "rootfs";
    rev = "df3fa4dfc0b9d4164f8678699d8923df847eb3d2";
    hash = "sha256-xDEvm5vABUpjjVkFeIGcJHX4rD7uZOKgh2hjlfwPEDg=";
  };
in
py.buildPythonApplication rec {
  pname = "qiling";
  version = "1.4.10";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "qilingframework";
    repo = "qiling";
    tag = version;
    hash = "sha256-EX0Zd9T6Hioy5AytV2IE/sppdhwELnBwIvzVutdGJ58=";
  };

  # `qltool examples` builds its sample command lines from
  # `os.path.basename(__file__)`. wrapPythonPrograms renames the real script to
  # `.qltool-wrapped` and puts a shell wrapper at `bin/qltool`, so every printed
  # example would tell the user to run `.qltool-wrapped`. Hardcode the name the
  # user actually types.
  postPatch = ''
    substituteInPlace qltool \
      --replace-fail 'prog = os.path.basename(__file__)' "prog = 'qltool'"
  '';

  # Upstream pins `unicorn = "2.1.3"` exactly; nixpkgs ships 2.1.4.
  pythonRelaxDeps = [ "unicorn" ];

  build-system = [ py.poetry-core ];

  dependencies = with py; [
    capstone
    gevent
    keystone-engine
    multiprocess
    pefile
    pyelftools
    python-fx
    python-registry
    pyyaml
    questionary
    termcolor
    unicorn
  ];

  # qltool and qltui.py live at the repo root and are not declared as poetry
  # scripts, so the wheel does not carry them. Install them by hand: qltool is
  # the CLI (postInstall runs before wrapPythonPrograms, so it gets its shebang
  # rewritten and PYTHONPATH injected like a normal entry point), while qltui.py
  # is a plain module that `qltool qltui` does `import qltui` on — it belongs on
  # sys.path, not in bin, which is where the pre-nix installer put it too.
  #
  # The example scripts resolve their guest images through the relative path
  # `rootfs/...`, so they only run from inside $out/share/qiling/examples. The
  # rootfs itself is symlinked rather than copied: it is ~400 MB, and a copy
  # would double that in the store for no benefit.
  postInstall = ''
    install -Dm755 qltool -t $out/bin
    install -Dm644 qltui.py -t $out/${py.python.sitePackages}

    mkdir -p $out/share/qiling
    cp -r examples $out/share/qiling/examples
    chmod -R u+w $out/share/qiling/examples
    rm -rf $out/share/qiling/examples/rootfs
    ln -s ${rootfs} $out/share/qiling/examples/rootfs
  '';

  # Upstream's suite is not runnable as a build check: it emulates binaries from
  # the source tree's examples/rootfs and includes modules that abort on import.
  doCheck = false;

  pythonImportsCheck = [ "qiling" ];

  meta = {
    description = "Qiling Advanced Binary Emulation Framework";
    homepage = "https://qiling.io/";
    changelog = "https://github.com/qilingframework/qiling/releases/tag/${version}";
    license = lib.licenses.gpl2Only;
    mainProgram = "qltool";
  };
}
