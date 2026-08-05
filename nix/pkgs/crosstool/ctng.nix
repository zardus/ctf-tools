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
  version = "1.28.0";

  src = fetchFromGitHub {
    owner = "crosstool-ng";
    repo = "crosstool-ng";
    rev = "crosstool-ng-${version}";
    hash = "sha256-ytTgr2sQKV6BarYtiqjpcNcx7gKzM0BUaML92CrsuPo=";
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

  # ct-ng seeds a libc/kernel .config by copying a template that ships with
  # crosstool-NG itself (e.g. packages/uClibc-ng/config). On a normal install
  # that template is mode 644, but here it lives in the *read-only* Nix store
  # (mode 444), and `cp` carries that mode over. CT_KconfigSetOption /
  # CT_KconfigDisableOption fall back to `echo ... >> "${file}"` for options the
  # template doesn't mention, which then dies with ".config: Permission denied"
  # -- this is what broke every uClibc sample. Make the copies writable.
  postPatch = ''
    substituteInPlace scripts/build/libc/uClibc-ng.sh \
      --replace-fail 'CT_DoExecLog ALL cp "''${src}" "''${dst}"' \
                     'CT_DoExecLog ALL cp "''${src}" "''${dst}"
        CT_DoExecLog ALL chmod u+w "''${dst}"'

    # CT_GetFile walks a list of mirrors, but a *digest* mismatch makes it
    # `return 1` outright instead of moving on to the next one -- so a single
    # mirror handing back a truncated file (or a rate-limit page) fails the whole
    # download. ncurses-6.5 hit this repeatedly on invisible-mirror.net when CI
    # builds a dozen samples at once, each run yielding a different bogus digest.
    # Treat a bad digest as "this mirror is no good" and try the next URL.
    substituteInPlace scripts/functions \
      --replace-fail 'Digest verification failed; removing the download' \
                     'Digest verification failed; trying the next mirror'
    sed -i '/Digest verification failed; trying the next mirror/,+2{s/^\( *\)return 1$/\1continue/}' \
      scripts/functions
    grep -A2 'trying the next mirror' scripts/functions | grep -q 'continue'
  '';

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
