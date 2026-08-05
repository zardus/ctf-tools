{ lib
, stdenvNoCC
, fetchFromGitHub
, python3
, makeWrapper
}:

# subbrute is a fast subdomain-enumeration spider. The ctf-tools installer
# just `git clone`s the repo and symlinks subbrute.py into bin/. The script is
# Python 2/3 compatible and vendors its own copy of `dnslib` inside the repo,
# so no third-party Python packages are required. It locates its data files
# (names.txt, resolvers.txt) relative to the real path of subbrute.py, so we
# keep the whole repo together in libexec and wrap it with python3.
stdenvNoCC.mkDerivation {
  pname = "subbrute";
  version = "unstable-2017-03-12";

  src = fetchFromGitHub {
    owner = "TheRook";
    repo = "subbrute";
    rev = "07d29259c337787bf33626ddc1a713275cf9bc9b";
    hash = "sha256-HHhrPlh/+znkK9zms++Qy7BmnY6PekTvGeqOg2Jt6Dw=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ python3 ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/subbrute $out/bin
    cp -r . $out/libexec/subbrute/

    makeWrapper ${python3}/bin/python3 $out/bin/subbrute \
      --add-flags $out/libexec/subbrute/subbrute.py

    # Preserve the original binary name used by the ctf-tools installer.
    ln -s subbrute $out/bin/subbrute.py

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/subbrute --help > /dev/null
  '';

  meta = {
    description = "A (very) fast subdomain enumeration/brute-force spider";
    homepage = "https://github.com/TheRook/subbrute";
    license = lib.licenses.gpl3Only;
    mainProgram = "subbrute";
    platforms = lib.platforms.all;
  };
}
