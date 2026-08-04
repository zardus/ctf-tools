{ lib
, stdenvNoCC
, fetchFromGitHub
, python3
, makeWrapper
, binutils
}:

# shellnoob is a single standalone Python script (shellnoob.py). The ctf-tools
# installer just `git clone`s the repo and symlinks shellnoob.py into bin/.
# The script is Python 2/3 compatible (it branches on sys.version) and needs
# no third-party Python packages. Its core asm<->opcode features shell out to
# the assembler/objdump, so we put binutils on the wrapper's PATH.
stdenvNoCC.mkDerivation {
  pname = "shellnoob";
  version = "unstable-2020-05-16";

  src = fetchFromGitHub {
    owner = "reyammer";
    repo = "shellnoob";
    rev = "65861336b01072a3e4805080cc4eb22d8f44c869";
    hash = "sha256-sSfeL6RK9fOy8cBAEBgZgyC2hopx8I5phvLXnYJCClc=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ python3 ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/shellnoob $out/bin
    install -m0755 shellnoob.py $out/libexec/shellnoob/shellnoob.py
    cp -r README.md COPYRIGHT samples $out/libexec/shellnoob/ || true

    makeWrapper ${python3}/bin/python3 $out/bin/shellnoob \
      --add-flags $out/libexec/shellnoob/shellnoob.py \
      --prefix PATH : ${lib.makeBinPath [ binutils ]}

    # Preserve the original binary name used by the ctf-tools installer.
    ln -s shellnoob $out/bin/shellnoob.py

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/shellnoob --help > /dev/null
  '';

  meta = {
    description = "Swiss-army knife for shellcode writing: convert between asm, opcodes, C, and more";
    homepage = "https://github.com/reyammer/shellnoob";
    license = lib.licenses.mit;
    mainProgram = "shellnoob";
    platforms = lib.platforms.all;
  };
}
