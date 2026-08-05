{ lib
, python312
, fetchPypi
, fetchFromGitHub
, makeWrapper
, stdenv
, exiftool
}:

let
  python = python312;
  ps = python.pkgs;

  # --- tinyscript's companion libraries that are missing from nixpkgs ---

  cowpy = ps.buildPythonPackage rec {
    pname = "cowpy";
    version = "1.1.5";
    pyproject = true;
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-CJFy2x2IwwouG3QbGJRe6EFwvZQ6PKcZSOSuOjJV5VQ=";
    };
    build-system = [ ps.poetry-core ];
    doCheck = false;
    pythonImportsCheck = [ "cowpy" ];
  };

  patchy = ps.buildPythonPackage rec {
    pname = "patchy";
    version = "2.10.0";
    pyproject = true;
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-59w2ENILjOMK8t2/pKHtZ/BmJp+msQCU8W3HmLgBGdo=";
    };
    build-system = [ ps.setuptools ps.setuptools-scm ];
    doCheck = false;
    pythonImportsCheck = [ "patchy" ];
  };

  codext = ps.buildPythonPackage rec {
    pname = "codext";
    version = "1.16.5";
    pyproject = true;
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-sNfZ4Mo2wEW2SbWLTcYDTv67R/3gIwGcMqLFlqLSy8o=";
    };
    build-system = [ ps.setuptools ps.setuptools-scm ];
    dependencies = [ ps.markdown2 ];
    doCheck = false;
    dontCheckRuntimeDeps = true;
    pythonImportsCheck = [ "codext" ];
  };

  asciistuff = ps.buildPythonPackage rec {
    pname = "asciistuff";
    version = "1.3.3";
    pyproject = true;
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-1NFAhRL6eSvVDD5wZLw5wpiVpGeLgBPXBbUm1rhc8H4=";
    };
    build-system = [ ps.setuptools ps.setuptools-scm ];
    dependencies = [ ps.colorama cowpy ps.pillow ps.pyfiglet ];
    doCheck = false;
    dontCheckRuntimeDeps = true;
    pythonImportsCheck = [ "asciistuff" ];
  };

  tinyscript = ps.buildPythonPackage rec {
    pname = "tinyscript";
    version = "1.31.2";
    pyproject = true;
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-boSP4uTc0a5R3q+dWX6tu4i/Y0/98oRt9NQNNJcvuYY=";
    };
    build-system = [ ps.setuptools ps.setuptools-scm ];
    # tinyscript declares a very large optional dependency set; it lazily
    # imports most of them.  We wire up only the ones actually needed to
    # import the package and to run the stegano-tools scripts, and skip the
    # runtime-deps check that would otherwise demand the full list.
    dependencies = [
      ps.coloredlogs
      ps.lazy-object-proxy
      ps.pathlib2
      ps.six
      ps.terminaltables
      ps.colorama
      ps.colorful
      ps.pyfiglet
      ps.markdown2
      ps.python-magic
      ps.pyyaml
      ps.requests
      ps.rich
      ps.python-dateutil
      ps.packaging
      ps.pillow
      codext
      asciistuff
      patchy
    ];
    doCheck = false;
    dontCheckRuntimeDeps = true;
    pythonImportsCheck = [ "tinyscript" ];
  };

  pythonEnv = python.withPackages (_: [ tinyscript ps.pillow ]);

  # name-in-bin -> path of the script within the checkout
  scripts = {
    paddinganograph = "base-padding/paddinganograph.py";
    stegolsb = "image-lsb/stegolsb.py";
    stegopit = "image-pit/stegopit.py";
    stegopvd = "image-pvd/stegopvd.py";
  };

in
stdenv.mkDerivation {
  pname = "stegano-tools";
  version = "unstable-2024-01-11";

  src = fetchFromGitHub {
    owner = "dhondta";
    repo = "stegano-tools";
    rev = "31230db3f29ece83aa75812f51071b6f8c7dfc8a";
    fetchSubmodules = true;
    hash = "sha256-DzMAcdAFjfBK6vp9ArPYlGG+k2TpmpmyraLUId8rKrs=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/libexec/stegano-tools" "$out/bin"

    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: rel: ''
      install -Dm755 "${rel}" "$out/libexec/stegano-tools/${name}.py"
      makeWrapper "${pythonEnv}/bin/python" "$out/bin/${name}" \
        --add-flags "$out/libexec/stegano-tools/${name}.py" \
        ${lib.optionalString (name == "paddinganograph")
          "--prefix PATH : ${lib.makeBinPath [ exiftool ]}"}
    '') scripts)}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Set of CTF steganography tools by Alexandre D'Hondt (LSB, PIT, PVD, paddinganography)";
    homepage = "https://github.com/dhondta/stegano-tools";
    license = licenses.gpl3Only;
    mainProgram = "stegolsb";
    platforms = platforms.unix;
  };
}
