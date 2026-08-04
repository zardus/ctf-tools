{ lib, stdenv, fetchurl }:

stdenv.mkDerivation {
  pname = "scrdec18";
  version = "1.8";

  src = fetchurl {
    url = "https://gist.githubusercontent.com/bcse/1834878/raw/7483fb72abbb32aa69b853fdcc9f6f72e7568677/scrdec18.c";
    sha256 = "sha256-Z+nm5VJVQdLOcoiej04Y8/mBorhHeaVCPpHP8xgnui0=";
  };

  dontUnpack = true;

  buildPhase = ''
    runHook preBuild
    $CC -o scrdec18 $src
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 scrdec18 $out/bin/scrdec18
    runHook postInstall
  '';

  meta = with lib; {
    description = "Decoder for Microsoft Script Encoder (scrdec) version 1.8";
    homepage = "https://virtualconspiracy.com/";
    license = licenses.free;
    platforms = platforms.all;
    mainProgram = "scrdec18";
  };
}
