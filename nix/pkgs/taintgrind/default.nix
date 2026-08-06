{ lib
, stdenv
, fetchurl
, fetchFromGitHub
, autoconf
, automake
, libtool
, perl
, python3
, makeWrapper
}:

let
  # Taintgrind is a Valgrind tool that lives in a subdirectory of the
  # Valgrind source tree and is built as part of the whole Valgrind build.
  # See ../../taintgrind/install and upstream build_taintgrind.sh.
  taintgrindSrc = fetchFromGitHub {
    owner = "wmkhoo";
    repo = "taintgrind";
    rev = "9875412a860dbcf85f924df49b26db09a76fc6da";
    hash = "sha256-eVhrJt+lbY3w+3evgspqBy29pakQLk7PrtA92YRckaw=";
  };
in
stdenv.mkDerivation {
  pname = "taintgrind";
  version = "3.25.1";

  src = fetchurl {
    url = "https://sourceware.org/pub/valgrind/valgrind-3.25.1.tar.bz2";
    hash = "sha256-Yd640HJ7RcJo79wbO2yeZ5zZfL9e5LKNHerXyLeica8=";
  };

  nativeBuildInputs = [ autoconf automake libtool perl python3 makeWrapper ];

  # Drop the taintgrind checkout into the Valgrind source tree.
  postUnpack = ''
    cp -r ${taintgrindSrc} $sourceRoot/taintgrind
    chmod -R u+w $sourceRoot/taintgrind
  '';

  # Reuse upstream's own patch logic to wire taintgrind into the Valgrind
  # autotools build, then leave an empty capstone placeholder dir so automake
  # accepts the (disabled) conditional SUBDIRS entry.
  postPatch = ''
    ( source taintgrind/build_taintgrind.sh; patch_valgrind_build_files )
    mkdir -p taintgrind/capstone
    patchShebangs .
  '';

  preConfigure = ''
    ./autogen.sh
  '';

  enableParallelBuilding = true;
  doCheck = false;

  # Valgrind wants the default (non-hardened) build; hardening can break the
  # tool binaries it produces.
  hardeningDisable = [ "all" ];

  # `make install` lays down a complete Valgrind tree, which collides with the
  # `valgrind` package on ~150 paths (bin/valgrind, lib/valgrind/*.a,
  # libexec/valgrind/*, include/valgrind/*) and makes the two impossible to
  # co-install in one profile. Tuck the whole tree under libexec/taintgrind and
  # expose only the two entry points the stock ctf-tools installer put on PATH.
  postInstall = ''
    mkdir -p $out/libexec/taintgrind
    mv $out/bin $out/libexec/taintgrind/bin
    # VALGRIND_LIB must point here: libexec/valgrind holds the per-platform
    # tool binaries (taintgrind-amd64-linux), the vgpreload_*.so shims and
    # default.supp. lib/valgrind only has static archives for building tools,
    # and pointing VALGRIND_LIB at it fails with "failed to start tool".
    mv $out/libexec/valgrind $out/libexec/taintgrind/vglib
    # Everything left in these prefixes belongs to Valgrind proper.
    rm -rf $out/include $out/lib $out/share/doc $out/share/man

    # Valgrind tools are invoked through the valgrind driver. The relocation
    # invalidates the driver's compiled-in library path, hence the explicit
    # VALGRIND_LIB.
    makeWrapper $out/libexec/taintgrind/bin/valgrind $out/bin/taintgrind \
      --add-flags "--tool=taintgrind" \
      --set VALGRIND_LIB $out/libexec/taintgrind/vglib

    install -Dm755 taintgrind/tools/log2dot.py $out/share/taintgrind/log2dot.py
    makeWrapper ${python3}/bin/python3 $out/bin/taintgrind-log2dot \
      --add-flags "$out/share/taintgrind/log2dot.py"
  '';

  meta = with lib; {
    description = "Taintgrind: a Valgrind taint-analysis tool";
    homepage = "https://github.com/wmkhoo/taintgrind";
    license = licenses.gpl2Plus;
    mainProgram = "taintgrind";
    platforms = platforms.linux;
  };
}
