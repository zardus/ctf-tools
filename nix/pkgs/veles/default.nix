{ lib
, stdenv
, fetchFromGitHub
, cmake
, zlib
, libGL
, libGLU
, qt5
, python3
, msgpack-cxx
}:

# VELES — a binary analysis / visualization hex editor (Qt5 GUI) from Codilime.
# The ctf-tools installer fetches an older source tarball from the (now
# defunct) codisec.com and builds it with cmake against Qt5 + zlib. We build the
# equivalent source from the upstream github tag and install the resulting
# `veles` binary (target main_ui, OUTPUT_NAME "veles") into $out/bin.
let
  pythonEnv = python3.withPackages (ps: with ps; [
    pbr
    six
    msgpack
    pyopenssl
  ]);
in
stdenv.mkDerivation rec {
  pname = "veles";
  version = "2018.05.0";

  src = fetchFromGitHub {
    owner = "codilime";
    repo = "veles";
    rev = "2018.05.0.TIF";
    hash = "sha256-Df7D8mSqplgZA+Y+hfLbKQ9R42e7D7LN/GMJiIeosGE=";
  };

  nativeBuildInputs = [ cmake qt5.wrapQtAppsHook ];

  buildInputs = [ zlib libGL libGLU qt5.qtbase msgpack-cxx ];

  postPatch = ''
    # The latest release uses QtNetwork without first asking CMake to find it.
    sed -i '/find_package(Qt5Widgets REQUIRED)/a find_package(Qt5Network REQUIRED)' \
      cmake/qt.cmake

    # Reuse Nix's complete Python environment instead of creating a virtualenv
    # and downloading its requirements during the sandboxed build.
    substituteInPlace cmake/cppgen.cmake \
      --replace-fail 'set(PYEXE "''${VENV_DIR}/bin/python3")' \
                     'set(PYEXE "${pythonEnv}/bin/python3")' \
      --replace-fail 'set(SIX_LOC "''${VENV_DIR}/lib/site-packages/six.py")' \
                     'set(SIX_LOC "${pythonEnv}/${python3.sitePackages}/six.py")'

    # Compatibility with Python 3.14 and current msgpack.
    substituteInPlace python/srv.py \
      --replace-fail 'loop = asyncio.get_event_loop()' \
                     'loop = asyncio.new_event_loop(); asyncio.set_event_loop(loop)'
    substituteInPlace python/veles/proto/msgpackwrap.py \
      --replace-fail "encoding='utf-8'" 'raw=False'
  '';

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    # This is a 2016-era CMakeLists (cmake_minimum_required 3.1); modern cmake
    # refuses <3.5 compatibility without this override.
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    # Avoid the configure-time download of msgpack-c++ 2.1.1.
    "-DMSGPACK_INCLUDE_PATH=${msgpack-cxx}/include"
  ];

  # 2016-era C++11 built with a modern GCC: silence the flood of warnings that
  # would otherwise be promoted, and relax a couple of hardening defaults that
  # this old codebase does not satisfy.
  env.NIX_CFLAGS_COMPILE = "-w -fpermissive -std=c++14";

  # Upstream's CMake install creates a source archive for a Debian postinst
  # script. Install the already prepared server directly for a working Nix
  # package and let the Qt wrapper expose its Python interpreter.
  installPhase = ''
    runHook preInstall
    install -Dm755 veles "$out/bin/veles"
    mkdir -p "$out/share/veles-server"
    cp -r ../python/. "$out/share/veles-server/"
    runHook postInstall
  '';

  qtWrapperArgs = [ "--prefix PATH : ${lib.makeBinPath [ pythonEnv ]}" ];

  meta = with lib; {
    description = "VELES — binary data analysis and visualization hex editor (Qt5)";
    homepage = "https://github.com/codilime/veles";
    license = licenses.asl20;
    mainProgram = "veles";
    platforms = platforms.linux;
  };
}
