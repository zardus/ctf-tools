{ lib
, stdenvNoCC
, fetchFromGitHub
, python3
, makeWrapper
, binutils
, coreutils
, gcc
, gcc_multi
, gdb
}:

# shellnoob is a single standalone Python script (shellnoob.py). The ctf-tools
# installer just `git clone`s the repo and symlinks shellnoob.py into bin/.
# The script is Python 2/3 compatible (it branches on sys.version) and needs
# no third-party Python packages. It shells out to the assembler/objdump for
# asm<->opcode, to gcc for anything producing an executable (--to-exe from
# any input format, and --to-gdb via c_to_exe), and to gdb for --to-gdb, so
# all three go on the wrapper's PATH. coreutils joins them because
# get_objdump_options() shells out to `uname` before any conversion runs;
# without it the wrapper only works when the caller's PATH already has one.

let
  # shellnoob's default target on x86_64 is 32-bit (`gcc -m32`), which needs a
  # multilib compiler. gcc_multi only exists on x86_64-linux -- merely
  # referencing it elsewhere throws at eval time -- so it must stay behind
  # this guard rather than a lib.optional on an already-forced value.
  # The same flag gates the conversion tests below: shellnoob's as/gcc option
  # tables only have entries for x86/x86_64 (and 32-bit arm), so every
  # conversion raises "options not found" on aarch64 regardless of packaging.
  isX86_64Linux = stdenvNoCC.hostPlatform.system == "x86_64-linux";
  cc = if isX86_64Linux then gcc_multi else gcc;
in
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
      --prefix PATH : ${lib.makeBinPath [ binutils cc gdb coreutils ]}

    # Preserve the original binary name used by the ctf-tools installer.
    ln -s shellnoob $out/bin/shellnoob.py

    runHook postInstall
  '';

  # A --help-only check cannot see a missing compiler: every --to-exe path
  # goes through c_to_exe, which shells out to gcc and only reports
  # "Ret value: 127". Assert on a real conversion instead.
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/shellnoob --help > /dev/null
    ${lib.optionalString isX86_64Linux ''
      cat > hello.c <<'EOF'
      int main(void) { return 0; }
      EOF

      # default (32-bit, needs the multilib gcc) and explicit 64-bit
      $out/bin/shellnoob --from-c hello.c --to-exe hello32
      $out/bin/shellnoob --64 --from-c hello.c --to-exe hello64
      test -s hello32 && test -s hello64
    ''}

    runHook postInstallCheck
  '';

  meta = {
    description = "Swiss-army knife for shellcode writing: convert between asm, opcodes, C, and more";
    homepage = "https://github.com/reyammer/shellnoob";
    license = lib.licenses.mit;
    mainProgram = "shellnoob";
    platforms = lib.platforms.all;
  };
}
