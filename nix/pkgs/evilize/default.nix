{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "evilize";
  version = "0.2";

  src = fetchurl {
    url = "https://www.mscs.dal.ca/~selinger/md5collision/downloads/evilize-${version}.tar.gz";
    hash = "sha256-+k96FXEMA+0Fqzdv0u/Jem9pqhP8jtG87b5TjD8pVRI=";
  };

  # Default make target `tools` builds evilize, md5coll and goodevil.o.
  # Do not add the `examples` target: it runs a full MD5 collision search,
  # which upstream's README warns takes several hours.
  buildFlags = [ "tools" ];

  installPhase = ''
    runHook preInstall
    # goodevil.o is not an incidental build artifact: it embeds the "crib"
    # byte string that evilize searches for, so a template binary can only be
    # produced by linking against it (README step 3). Ship it, its headers and
    # the example program, or the installed evilize has no valid inputs.
    install -Dm755 evilize md5coll -t $out/bin
    install -Dm644 goodevil.o -t $out/lib
    install -Dm644 crib.h md5.h -t $out/include
    install -Dm644 hello-erase.c README -t $out/share/evilize
    runHook postInstall
  '';

  # Fast end-to-end check (seconds, no collision search): build a template the
  # documented way and confirm evilize finds the crib in it.
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $CC $out/share/evilize/hello-erase.c $out/lib/goodevil.o -o hello-erase-template
    $out/bin/evilize hello-erase-template -i | tee vector.txt
    grep -q 'Initial vector' vector.txt
    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "Tool to create MD5 colliding binaries (Peter Selinger's md5collision toolkit)";
    homepage = "https://www.mscs.dal.ca/~selinger/md5collision/";
    license = licenses.gpl2Plus;
    mainProgram = "evilize";
    platforms = platforms.unix;
  };
}
