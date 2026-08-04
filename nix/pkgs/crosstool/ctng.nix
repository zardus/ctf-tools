{ lib
, stdenv
, fetchFromGitHub
, autoconf
, automake
, libtool
, pkg-config
, gperf
, flex
, bison
, help2man
, gawk
, texinfo
, ncurses
, python3
, wget
, makeWrapper
, unzip
, which
, ctBuildInputs
}:

# The `ct-ng` driver of crosstool-NG. This is the program the ctf-tools
# `crosstool` installer actually compiles. It knows about ~158 sample
# cross-toolchain configurations (`ct-ng list-samples`) and drives the
# download/configure/build of a full cross toolchain (binutils + gcc + libc + ...).
#
# Building an individual toolchain is done in a *separate* derivation
# (see ./mk-toolchain.nix), because that step needs to download upstream
# source tarballs. Here we only build and package the driver itself.

stdenv.mkDerivation rec {
  pname = "crosstool-ng";
  version = "unstable-2024-c893759";

  src = fetchFromGitHub {
    owner = "crosstool-ng";
    repo = "crosstool-ng";
    rev = "c8937598ac071322b7095e30bed4760d3c9c50ec";
    hash = "sha256-V1FXB7w2eEpWiSCO0Anh+V2zgJGaZ9750T3UISet/Xw=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    pkg-config
    help2man
    texinfo
    makeWrapper
    unzip
    which
    wget
  ];

  buildInputs = [
    gperf
    flex
    bison
    gawk
    ncurses
    python3
  ];

  # crosstool-ng ships a ./bootstrap that regenerates the autotools files.
  # Patch the source scripts' shebangs first: ./bootstrap (and the scripts it
  # calls) use `#!/usr/bin/env`, which does not exist in a strict build sandbox.
  preConfigure = ''
    patchShebangs .
    bash ./bootstrap
  '';

  configureFlags = [ "--prefix=${placeholder "out"}" ];

  enableParallelBuilding = true;

  # At runtime ct-ng needs a full build environment on PATH to drive a
  # toolchain build: a host C/C++ compiler, make, awk, bison, flex, etc.
  # Crucially this includes a working `gcc` (ct-ng runs `gcc -dumpversion`
  # very early and aborts with exit 127 if it is missing). We inject the same
  # tool set the offline toolchain builds use (`ctBuildInputs`) so that a bare
  # `ct-ng <sample> && ct-ng build` works out of the box for end users too.
  postInstall = ''
    wrapProgram $out/bin/ct-ng \
      --prefix PATH : ${lib.makeBinPath ctBuildInputs}
  '';

  meta = with lib; {
    description = "crosstool-NG: versatile (cross-)toolchain generator (ct-ng driver)";
    homepage = "https://crosstool-ng.github.io/";
    license = licenses.gpl2Plus;
    mainProgram = "ct-ng";
    platforms = platforms.linux;
  };
}
