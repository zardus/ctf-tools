{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, bash
, coreutils
, which
, pkgsPy2
}:

# QIRA (Queens Instrumenting Reverse Analysis) is an archived Python-2 web app
# (a Flask/socket.io timeless-debugging frontend) plus a QEMU-user fork used as a
# tracer backend. We build it for real against nixpkgs-23.05's python27:
#   * every pinned, py2-only requirement is built from PyPI with a real hash,
#   * the qiradb C++/Cython trace database is compiled into a real .so,
#   * the geohot/qemu "qira" tracer fork is built and its qira-<arch> binaries
#     are wired into tracers/qemu so `qira /bin/ls` can actually trace.
let
  py = pkgsPy2.python27;
  pyPkgs = py.pkgs;
  inherit (pyPkgs) buildPythonPackage fetchPypi;

  # ---- pinned, py2-only PyPI deps (nixpkgs-23.05 only ships py3 versions) ----
  itsdangerous = buildPythonPackage rec {
    pname = "itsdangerous";
    version = "1.1.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-MhsDPQfypBNtPsdi6snxahDM1g9TwMka+QIXrOe6Hxk=";
    };
    doCheck = false;
  };

  click = buildPythonPackage rec {
    pname = "Click";
    version = "7.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-W5S0lSH2RWZw/bMM2CpOypQSeIqT+m3W33LJTVqP8tc=";
    };
    doCheck = false;
  };

  werkzeug = buildPythonPackage rec {
    pname = "Werkzeug";
    version = "0.15.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-ylwtzTZ9bA34cYW5CCkp0lU1j1ORkjJpM1eCshPVJlU=";
    };
    doCheck = false;
  };

  flask = buildPythonPackage rec {
    pname = "Flask";
    version = "1.0.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-InHABw28tSdfrUqC4p8jq5JoLcRfnfvCLAK6m5Mizkg=";
    };
    propagatedBuildInputs = [ werkzeug pyPkgs.jinja2 click itsdangerous ];
    doCheck = false;
  };

  python-engineio = buildPythonPackage rec {
    pname = "python-engineio";
    version = "3.5.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-snVs5TB2Fj6yT1nB0akDrHLwca1Pt7PvbasbG5rppE8=";
    };
    propagatedBuildInputs = [ pyPkgs.six ];
    doCheck = false;
  };

  python-socketio = buildPythonPackage rec {
    pname = "python-socketio";
    version = "3.1.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-qnAhV2lNVadD+28cwL0a9Y+/2op9cddH1LEtbawpyrM=";
    };
    propagatedBuildInputs = [ pyPkgs.six python-engineio ];
    doCheck = false;
  };

  flask-socketio = buildPythonPackage rec {
    pname = "Flask-SocketIO";
    version = "3.3.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-jY+fEE213f8bBroyLY4ViIHVkBRBmcmT/ibPUyGMft0=";
    };
    propagatedBuildInputs = [ flask python-socketio ];
    doCheck = false;
  };

  pyelftools = buildPythonPackage rec {
    pname = "pyelftools";
    version = "0.25";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-icbab1YoDDel/zNGhZG6mhJOF9cf5C3pcYGMv/RsGyQ=";
    };
    doCheck = false;
  };

  pydot = buildPythonPackage rec {
    pname = "pydot";
    version = "1.4.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-1JydTdGRO+7CqZf4MVQ8jL1T5TWxpznpIWQv5BYjXwE=";
    };
    propagatedBuildInputs = [ pyPkgs.pyparsing ];
    doCheck = false;
  };

  pillow = buildPythonPackage rec {
    pname = "Pillow";
    version = "5.4.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-UjNmTq36NCxjm5uZdxkNZK16yk7cUalmOU1+COfzip8=";
    };
    nativeBuildInputs = [ pkgsPy2.pkg-config ];
    buildInputs = [ pkgsPy2.zlib pkgsPy2.libjpeg pkgsPy2.freetype ];
    doCheck = false;
  };

  # Full interpreter environment for running the middleware.
  pythonEnv = py.withPackages (ps: [
    flask
    flask-socketio
    python-socketio
    python-engineio
    ps.capstone
    pyelftools
    ps.ipaddr
    pillow
    pydot
    ps.hexdump
    ps.six
    ps.pyparsing
  ]);

  # ---- pinned tracer backend: geohot/qemu, "qira" branch ----
  qemuSrc = fetchFromGitHub {
    owner = "geohot";
    repo = "qemu";
    rev = "ca1808b49a545b1889a1856e8984dc40cf7d35cf";
    hash = "sha256-p+85KIWKfy0a4z9uNylfMZg6KNvxMzPLDMeemNO2lvM=";
  };

  qiraTracer = stdenv.mkDerivation {
    pname = "qira-qemu-tracer";
    version = "unstable-2018";
    src = qemuSrc;
    patches = [ ./qemu.patch ];
    nativeBuildInputs = [
      pkgsPy2.pkg-config
      py
      pkgsPy2.flex
      pkgsPy2.bison
    ];
    buildInputs = [ pkgsPy2.glib pkgsPy2.zlib pkgsPy2.pixman ];
    # Old QEMU's configure is not a standard autoconf script.
    configurePhase = ''
      runHook preConfigure
      ./configure \
        --target-list=i386-linux-user,x86_64-linux-user,arm-linux-user,ppc-linux-user,aarch64-linux-user,mips-linux-user,mipsel-linux-user \
        --enable-tcg-interpreter --enable-debug-tcg --cpu=unknown \
        --python=${py}/bin/python --disable-werror --disable-pie \
        --prefix=$out
      runHook postConfigure
    '';
    enableParallelBuilding = true;
    dontStrip = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      for t in i386 x86_64 arm ppc aarch64 mips mipsel; do
        for f in $(find . -name "qemu-$t" -type f -executable); do
          cp "$f" "$out/bin/qira-$t"
        done
      done
      runHook postInstall
    '';
  };

  qiraSrc = fetchFromGitHub {
    owner = "BinaryAnalysisPlatform";
    repo = "qira";
    rev = "5f34406410aa492bc491fe0e579dbe103390a432";
    hash = "sha256-+sz25WPdXXyDnGUYXW3AQoMsk4zYUzfB4ckmkhvcqOY=";
  };

  # qiradb is a C++/Cython trace database normally jit-compiled by pyximport at
  # runtime; compile it ahead of time. Built with pkgsPy2's stdenv so it links
  # against the same glibc as the python27 interpreter that loads it.
  qiradb = pkgsPy2.stdenv.mkDerivation {
    pname = "qiradb";
    version = "unstable-2018";
    src = qiraSrc;
    nativeBuildInputs = [ pyPkgs.cython py ];
    buildPhase = ''
      runHook preBuild
      cd middleware/qiradb
      cython --cplus -I Trace qiradb.pyx -o qiradb.cpp
      $CXX -shared -fPIC $(python-config --includes) -I Trace \
        qiradb.cpp -o qiradb.so -lpthread
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp qiradb.so $out/
      runHook postInstall
    '';
  };

in
stdenv.mkDerivation {
  pname = "qira";
  version = "1.3-unstable-2018";
  src = qiraSrc;

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/qira $out/bin
    cp -r . $out/share/qira/

    # upstream ships a dangling release symlink that trips noBrokenSymlinks
    rm -f $out/share/qira/extra/website/dl

    # Replace the pyximport-based loader with the precompiled extension.
    cp ${qiradb}/qiradb.so $out/share/qira/middleware/qiradb/qiradb.so
    cat > $out/share/qira/middleware/qiradb/__init__.py <<'EOF'
from .qiradb import PyTrace
EOF

    # Wire in the prebuilt qira-<arch> tracer binaries.
    mkdir -p $out/share/qira/tracers/qemu
    for b in ${qiraTracer}/bin/qira-*; do
      ln -sf "$b" "$out/share/qira/tracers/qemu/$(basename "$b")"
    done

    makeWrapper ${pythonEnv}/bin/python $out/bin/qira \
      --add-flags "$out/share/qira/middleware/qira.py" \
      --prefix PATH : ${lib.makeBinPath [ which coreutils bash ]} \
      --set PYTHONDONTWRITEBYTECODE 1
    runHook postInstall
  '';

  meta = {
    description = "QIRA: timeless debugging / instrumenting reverse-analysis platform (Python 2 frontend + QEMU tracer)";
    homepage = "https://github.com/BinaryAnalysisPlatform/qira";
    license = lib.licenses.mit;
    mainProgram = "qira";
    platforms = lib.platforms.linux;
  };
}
