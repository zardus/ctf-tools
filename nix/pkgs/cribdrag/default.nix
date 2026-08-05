{ lib
, stdenvNoCC
, fetchFromGitHub
, python3
, makeWrapper
}:

# cribdrag ships two standalone Python scripts (cribdrag.py, xorstrings.py).
# The ctf-tools installer just symlinks the repo contents into bin/. Upstream
# is Python 2 (print statements, raw_input, xrange, str.decode('hex')), and
# python2 has been removed from nixpkgs, so we apply a small patch porting the
# scripts to Python 3 and then wrap them with python3.
stdenvNoCC.mkDerivation {
  pname = "cribdrag";
  version = "unstable-2015-10-07";

  src = fetchFromGitHub {
    owner = "SpiderLabs";
    repo = "cribdrag";
    rev = "2d27dbf2e18f986b5bbc3fcb6851783e88f13b1b";
    hash = "sha256-f5AGG88VgJ4wZ5JunJTLi3D244VOiYeoqmCIoyb9u94=";
  };

  patches = [ ./python3.patch ];

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ python3 ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/cribdrag $out/bin
    install -m0755 cribdrag.py xorstrings.py $out/libexec/cribdrag/
    cp -r README.md LICENSE.txt samples.txt $out/libexec/cribdrag/ || true

    makeWrapper ${python3}/bin/python3 $out/bin/cribdrag \
      --add-flags $out/libexec/cribdrag/cribdrag.py
    makeWrapper ${python3}/bin/python3 $out/bin/xorstrings \
      --add-flags $out/libexec/cribdrag/xorstrings.py

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    res=$($out/bin/xorstrings 414243 010101)
    if [ "$res" != "404342" ]; then
      echo "xorstrings smoke test failed: got '$res'" >&2
      exit 1
    fi
    $out/bin/cribdrag -h > /dev/null
  '';

  meta = {
    description = "Interactive crib dragging tool for cryptanalysis of XOR/stream-cipher ciphertext";
    homepage = "https://github.com/SpiderLabs/cribdrag";
    license = lib.licenses.gpl3Plus;
    mainProgram = "cribdrag";
    platforms = lib.platforms.all;
  };
}
