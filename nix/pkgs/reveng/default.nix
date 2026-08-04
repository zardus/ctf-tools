{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "reveng";
  version = "3.0.6";

  src = fetchurl {
    url = "https://downloads.sourceforge.net/project/reveng/${version}/reveng-${version}.tar.gz";
    hash = "sha256-0jD57We9gMwaMaLdw2/VA0tZQNMeDtvRabXzH0dtX7I=";
  };

  postPatch = ''
    sed -i -e "s/^#define BMP_BIT.*/#define BMP_BIT 64/" config.h
    sed -i -e "s/^#define BMP_SUB.*/#define BMP_SUB 32/" config.h
  '';

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 reveng $out/bin/reveng
    runHook postInstall
  '';

  meta = {
    description = "Arbitrary-precision CRC calculator and algorithm finder";
    homepage = "https://reveng.sourceforge.io/";
    license = lib.licenses.gpl3Plus;
    mainProgram = "reveng";
    platforms = lib.platforms.unix;
  };
}
