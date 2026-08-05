{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, autoreconfHook
, libjpeg
, file
}:

let
  # rules.ini for stegbreak, fetched by the original installer from launchpad.
  rulesIni = fetchurl {
    url = "https://launchpadlibrarian.net/16697277/rules.ini";
    hash = "sha256-MssHcCdbUMoaT1Rh98oluiqWXfPae/S4QRTAa0GmtSo=";
  };
in
stdenv.mkDerivation {
  pname = "stegdetect";
  version = "0.6-unstable-2020-01-06";

  src = fetchFromGitHub {
    owner = "sparticvs";
    repo = "stegdetect";
    rev = "cff6b306170e51c5c9d8cb666a5adb4d3257ad75"; # dev/fix-compilation
    hash = "sha256-rsi+1OJdlJoxzmZQmXWE044KeheI3WUCAgGuc8ZcuqQ=";
  };

  patches = [ ./statics.patch ];

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ libjpeg file ];

  # AC_CONFIG_SUBDIRS references bundled jpeg-6b/file dirs that are not present
  # in this fork; drop it so configure uses the system libjpeg/libmagic.
  postPatch = ''
    sed -i -e '/AC_CONFIG_SUBDIRS/d' configure.ac
  '';

  # The original installer strips the HAVE_TIMERADD guard from the generated
  # config.h so the fallback timeradd/timersub macros are always defined.
  postConfigure = ''
    sed -i -e "s/#ifndef HAVE_TIMERADD//" config.h
  '';

  # This ~2000-era C code predates C99/C23: it uses `false` as an ordinary
  # variable name and relies on implicit function declarations. Build it as
  # gnu17 and demote the corresponding gcc-14 hard errors back to warnings.
  env.NIX_CFLAGS_COMPILE = toString [
    "-std=gnu17"
    "-fcommon"
    "-Wno-error=implicit-function-declaration"
    "-Wno-error=implicit-int"
    "-Wno-error=int-conversion"
  ];

  enableParallelBuilding = true;

  postInstall = ''
    mkdir -p $out/share/stegbreak
    cp ${rulesIni} $out/share/stegbreak/rules.ini
  '';

  meta = with lib; {
    description = "Detect steganographic content in JPEG images (stegdetect/stegbreak)";
    homepage = "https://github.com/sparticvs/stegdetect";
    license = licenses.bsd3;
    platforms = platforms.linux;
    mainProgram = "stegdetect";
  };
}
