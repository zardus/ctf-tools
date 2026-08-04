{ lib
, stdenv
, fetchurl
, jdk
, jre
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "steganabara";
  version = "1.1.1";

  src = fetchurl {
    url = "http://www.caesum.com/handbook/steganabara-${version}.tar.gz";
    hash = "sha256-NZhX+CE0x/L7W+CQLaHO/XmlpfXhQegj3W26NekDek4=";
  };

  nativeBuildInputs = [ jdk makeWrapper ];

  # The tarball ships both Java sources (src/) and precompiled Eclipse
  # .class files (bin/). We recompile from source with the pinned JDK for
  # reproducibility instead of shipping the prebuilt classes.
  buildPhase = ''
    runHook preBuild
    mkdir -p classes
    find src -name '*.java' > sources.txt
    javac -d classes @sources.txt
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/steganabara
    cp -r classes $out/share/steganabara/bin
    makeWrapper ${jre}/bin/java $out/bin/steganabara \
      --add-flags "-cp $out/share/steganabara/bin steganabara.Steganabara"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Java-based image steganography analysis tool (steganalysis)";
    homepage = "http://www.caesum.com/handbook/stego.htm";
    license = licenses.unfree; # no explicit license stated upstream
    platforms = platforms.all;
    mainProgram = "steganabara";
  };
}
