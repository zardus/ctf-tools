{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "evilize";
  version = "0.2";

  src = fetchurl {
    url = "https://www.mscs.dal.ca/~selinger/md5collision/downloads/evilize-${version}.tar.gz";
    hash = "sha256-+k96FXEMA+0Fqzdv0u/Jem9pqhP8jtG87b5TjD8pVRI=";
  };

  # Default make target `tools` builds evilize and md5coll.
  buildFlags = [ "tools" ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm755 evilize md5coll -t $out/bin
    runHook postInstall
  '';

  meta = with lib; {
    description = "Tool to create MD5 colliding binaries (Peter Selinger's md5collision toolkit)";
    homepage = "https://www.mscs.dal.ca/~selinger/md5collision/";
    license = licenses.gpl2Plus;
    mainProgram = "evilize";
    platforms = platforms.unix;
  };
}
