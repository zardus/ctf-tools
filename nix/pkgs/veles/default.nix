{ lib
, stdenv
, fetchFromGitHub
, cmake
, zlib
, libGL
, libGLU
, qt5
}:

# VELES — a binary analysis / visualization hex editor (Qt5 GUI) from Codilime.
# The ctf-tools installer fetches the 2016.12 source tarball from the (now
# defunct) codisec.com and builds it with cmake against Qt5 + zlib. We build the
# equivalent source from the upstream github tag and install the resulting
# `veles` binary (target main_ui, OUTPUT_NAME "veles") into $out/bin.
stdenv.mkDerivation rec {
  pname = "veles";
  version = "2016.12.0";

  src = fetchFromGitHub {
    owner = "codilime";
    repo = "veles";
    rev = "2016.12.0.FITYMI.RC5";
    hash = "sha256-3U/RTPFVXSn7JKTZmVxZBe6J8fAMrSYXNm1eB/yHSKI=";
  };

  nativeBuildInputs = [ cmake qt5.wrapQtAppsHook ];

  buildInputs = [ zlib libGL libGLU qt5.qtbase ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    # This is a 2016-era CMakeLists (cmake_minimum_required 3.1); modern cmake
    # refuses <3.5 compatibility without this override.
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  # 2016-era C++11 built with a modern GCC: silence the flood of warnings that
  # would otherwise be promoted, and relax a couple of hardening defaults that
  # this old codebase does not satisfy.
  env.NIX_CFLAGS_COMPILE = "-w -fpermissive -std=c++14";

  meta = with lib; {
    description = "VELES — binary data analysis and visualization hex editor (Qt5)";
    homepage = "https://github.com/codilime/veles";
    license = licenses.asl20;
    mainProgram = "veles";
    platforms = platforms.linux;
  };
}
