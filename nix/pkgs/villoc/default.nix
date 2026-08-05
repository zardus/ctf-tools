{ lib, stdenvNoCC, fetchFromGitHub, python3, makeWrapper }:

# villoc: a heap visualization tool. The upstream repo also ships a pintool
# tracer that requires the nonfree Intel Pin toolkit; that tracer is omitted
# here. We package only the pure-python villoc.py analyzer/renderer.
stdenvNoCC.mkDerivation {
  pname = "villoc";
  version = "unstable-2024-01-01";

  src = fetchFromGitHub {
    owner = "wapiflapi";
    repo = "villoc";
    rev = "6f78fb2eac308bdd0bc7f57c0d76c6b0f6326900";
    hash = "sha256-1H3htCR30B362/p+p+QcWY5Pe+CwDVpdvSyWRqnU2qg=";
  };

  nativeBuildInputs = [ makeWrapper python3 ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/villoc $out/bin
    cp villoc.py $out/libexec/villoc/villoc.py

    makeWrapper ${python3.interpreter} $out/bin/villoc \
      --add-flags $out/libexec/villoc/villoc.py

    runHook postInstall
  '';

  meta = {
    description = "Heap visualization tool for CTF/exploitation (pintool tracer omitted, needs nonfree Intel Pin)";
    homepage = "https://github.com/wapiflapi/villoc";
    license = lib.licenses.mit;
    mainProgram = "villoc";
    platforms = lib.platforms.all;
  };
}
