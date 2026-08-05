{ lib
, stdenvNoCC
, fetchurl
, jre
, makeWrapper
}:

stdenvNoCC.mkDerivation rec {
  pname = "jd-gui";
  version = "1.6.6";

  src = fetchurl {
    url = "https://github.com/java-decompiler/jd-gui/releases/download/v${version}/jd-gui-${version}.jar";
    hash = "sha256-LJ0++osGQ4pyhBOfaPbvy/sqEeC50gozcNUBiWha/As=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/jd-gui $out/bin
    cp $src $out/share/jd-gui/jd-gui.jar

    makeWrapper ${jre}/bin/java $out/bin/jd-gui \
      --add-flags "-jar $out/share/jd-gui/jd-gui.jar"
    ln -s $out/bin/jd-gui $out/bin/jdgui

    runHook postInstall
  '';

  meta = with lib; {
    description = "Standalone graphical utility that displays Java source codes of .class files (JD-GUI)";
    homepage = "https://github.com/java-decompiler/jd-gui";
    license = licenses.gpl3Plus;
    mainProgram = "jd-gui";
    platforms = platforms.all;
  };
}
