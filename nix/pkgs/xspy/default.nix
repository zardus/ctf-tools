{ lib, stdenv, fetchFromGitLab, xorg }:

stdenv.mkDerivation {
  pname = "xspy";
  version = "unstable-2024";

  src = fetchFromGitLab {
    owner = "kalilinux/packages";
    repo = "xspy";
    rev = "7d445b0280c100521a5236ffa709646647f893d7";
    hash = "sha256-Vwjnb0SBxiXsOKz50slws37z/RfCWWanEUN7btaO2vc=";
  };

  buildInputs = [ xorg.libX11 ];

  buildPhase = ''
    runHook preBuild
    gcc -o xspy Xspy.c -lX11
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 xspy $out/bin/xspy
    runHook postInstall
  '';

  meta = {
    description = "Snoop on keystrokes of X11 clients on an insecure display";
    mainProgram = "xspy";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl2Plus;
  };
}
