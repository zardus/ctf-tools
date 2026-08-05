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

  postInstall = ''
    # The stock ctf-tools installer exposes two entry points. Provide a
    # working `taintgrind` launcher (Valgrind tools are invoked through the
    # valgrind driver) and the log2dot helper.
    makeWrapper $out/bin/valgrind $out/bin/taintgrind \
      --add-flags "--tool=taintgrind"

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
