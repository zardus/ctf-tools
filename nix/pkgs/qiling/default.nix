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
    rev = "f71f45fe1a39d58d8b8cae717f55cebeb37f63c7";
    hash = "sha256-i+9+/qtBn8TrHUBN96Y18U2F4V+V3Pcaa9Zn9MwdfLc=";
  };
in
py.buildPythonApplication rec {
  pname = "qiling";
  version = "1.4.11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "qilingframework";
    repo = "qiling";
    tag = "v${version}";
    hash = "sha256-HTlp6zSxeYEytXR085kLQadZKX+xaJ8u9XpWCLxI4Eg=";
  };

  # Keep help and examples stable when Nix renames the Python entry point.
  postPatch = ''
    substituteInPlace qiling/cli.py \
      --replace-fail 'parser = argparse.ArgumentParser()' "parser = argparse.ArgumentParser(prog='qltool')"
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

  # Upstream now includes qltool and qltui.py in the wheel.
  # The example scripts resolve their guest images through the relative path
  # `rootfs/...`, so they only run from inside $out/share/qiling/examples. The
  # rootfs itself is symlinked rather than copied: it is ~400 MB, and a copy
  # would double that in the store for no benefit.
  postInstall = ''
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
    changelog = "https://github.com/qilingframework/qiling/releases/tag/v${version}";
    license = lib.licenses.gpl2Only;
    mainProgram = "qltool";
  };
}
