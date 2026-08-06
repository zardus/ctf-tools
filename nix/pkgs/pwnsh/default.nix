{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, bash
, gcc
, glibc
, binutils
, coreutils
, gnused
, gnugrep
, util-linux
, xxd
, strace
, sudo
}:

# pwnsh is a small collection of bash helper scripts for shellcoding and
# exploitation (assemble / disassemble / analyze shellcode, look up
# syscall numbers and C constants, compile-and-run C snippets).
#
# Upstream's ctf-tools installer clones the repo, runs
# ./update-syscalls.sh (which just re-downloads the arch/*/syscall.tbl
# files from torvalds/linux -- but the repo already ships committed copies
# under syscalls/), then symlinks scripts/* into bin/. So the produced
# "binaries" are exactly the seven scripts in scripts/.
#
# We reproduce that faithfully as a pure derivation: install the whole
# scripts/ + syscalls/ tree (the checked-in syscall tables, so no
# build-time network), and expose each script in $out/bin via a
# makeWrapper launcher that (a) execs the real script so the scripts'
# BASH_SOURCE-based SCRIPT_DIR resolves to the real scripts/ dir (letting
# them find their siblings and ../syscalls) and (b) puts the runtime tools
# they shell out to on PATH.
#
# The scripts hardcode `$ARCH-linux-gnu-{gcc,objcopy,objdump}` toolchain
# names (default ARCH=x86_64). We provide x86_64 shims pointing at the
# native gcc/binutils so the default architecture works out of the box;
# other architectures need the matching cross toolchains on PATH.

let
  rev = "8fde7e1ff92bc44a77aa4161ef3efb79657e620b";

  runtimeInputs = [
    bash
    gcc
    binutils
    coreutils
    gnused
    gnugrep
    util-linux
    xxd
    strace
    sudo
  ];
in
stdenv.mkDerivation {
  pname = "pwnsh";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "zardus";
    repo = "pwnsh";
    inherit rev;
    hash = "sha256-VAPCgUDzrAMjnqFfrKATSzT7/Ob0u8ZBqZWKbthABrw=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/pwnsh
    cp -a scripts syscalls $out/share/pwnsh/

    # write-c picks which libc headers to #include by probing /usr/include,
    # which does not exist here, so it emitted an empty header block and
    # run-c / lookup-constant failed to compile. Probe glibc's dev output
    # instead. The upstream multiarch fallback line is dropped rather than
    # repointed: nixpkgs' gcc reports x86_64-unknown-linux-gnu (not the
    # Debian x86_64-linux-gnu), and there is no such subdirectory anywhere,
    # so any surviving form of that line only emits unresolvable includes.
    substituteInPlace $out/share/pwnsh/scripts/write-c \
      --replace-fail '[ -f "/usr/include/$(gcc -dumpmachine)/$1" ] && echo "#include \"$(gcc -dumpmachine)/$1\""' 'true' \
      --replace-fail '[ -f "/usr/include/$1" ]' '[ -f "${lib.getDev glibc}/include/$1" ]'

    # Toolchain shims: the scripts call x86_64-linux-gnu-gcc/objcopy/objdump
    # by name; point those at the native toolchain for the default arch.
    mkdir -p $out/share/pwnsh/shims
    ln -s ${gcc}/bin/gcc          $out/share/pwnsh/shims/x86_64-linux-gnu-gcc
    ln -s ${binutils}/bin/objcopy $out/share/pwnsh/shims/x86_64-linux-gnu-objcopy
    ln -s ${binutils}/bin/objdump $out/share/pwnsh/shims/x86_64-linux-gnu-objdump

    # `hd` (BSD hexdump) shim -> hexdump -C, used by `analyze`.
    cat > $out/share/pwnsh/shims/hd <<EOF
    #!${bash}/bin/bash
    exec ${util-linux}/bin/hexdump -C "\$@"
    EOF
    chmod +x $out/share/pwnsh/shims/hd

    mkdir -p $out/bin
    for s in $out/share/pwnsh/scripts/*; do
      name=$(basename "$s")
      makeWrapper "$s" "$out/bin/$name" \
        --prefix PATH : "$out/share/pwnsh/shims:${lib.makeBinPath runtimeInputs}"
    done

    runHook postInstall
  '';

  # Compile-and-run smoke test: both of these go through write-c, so they
  # fail loudly if the header probe above ever stops finding libc headers.
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    [ "$($out/bin/run-c 'printf("hello %d\n", 42);')" = "hello 42" ]
    [ "$($out/bin/lookup-constant PROT_EXEC)" = "0x4" ]

    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "Shell scripts useful for exploitation and shellcoding";
    homepage = "https://github.com/zardus/pwnsh";
    license = licenses.free;
    platforms = platforms.linux;
  };
}
