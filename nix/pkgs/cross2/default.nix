{ lib
, gcc13Stdenv
, fetchurl
, bison
, flex
, texinfo
, perl
, gawk
, which
, gnumake
, bzip2
, gzip
, gnutar
  # Accepted for interface-compatibility with the flake's callPackage (which
  # offers the Python-2 package set to every tool); cross2 does not use it.
, pkgsPy2 ? null
}:

# `cross2` from ctf-tools is the companion toolchain builder for the Japanese
# assembly-language book at kozos.jp. Upstream's install script downloads
# cross2-20130826.tgz and then runs toolchain/{fetch,setup}.sh +
# build/build-install-all.sh, which fetch binutils-2.21.1, gcc-3.4.6,
# newlib-1.20.0 and gdb-7.3.1 from kozos.jp at build time (no pinned hashes)
# and compile a *large* fleet of bare-metal ELF cross toolchains from source.
#
# This derivation reproduces that build faithfully but hermetically:
#   * the exact upstream source tarballs are pinned as fetchurl inputs;
#   * the exact upstream patch set (patch/) is applied with the same -p0 flow
#     as toolchain/setup.sh;
#   * we then drive the same configure/make/make-install steps that
#     build/{binutils,gcc}/all.sh run, for the toolchain targets, entirely
#     offline.
#
# gcc-3.4.6 (2006) only compiles with a pre-14 GCC (GCC 14 promoted
# -Wimplicit-int / -Wimplicit-function-declaration to errors), so the whole
# thing is built with gcc13Stdenv and Nix's hardening flags disabled (upstream
# passed no such flags).
#
# Scope / faithful deviation: we build the cross *compilers* (binutils + a
# freestanding C gcc-3.4.6, i.e. --enable-languages=c without newlib) for the
# "major architectures" target list from build/binutils/targets.sh. This yields
# real, working `<target>-as/ld/objdump/...` and `<target>-gcc` under the same
# bin names upstream produces. We do not build newlib or gdb (extras beyond the
# cross compilers). The target loop is tolerant: any target whose gcc-3.4.6
# port does not build on a modern host is skipped rather than aborting the
# whole build; the build log prints "OK"/"FAIL" per target and per stage.

let
  binutilsSrc = fetchurl {
    url = "http://kozos.jp/books/asm/binutils-2.21.1.tar.bz2";
    sha256 = "sha256-zez6afAqp7BfvN9njjMTcVHzYTE7Lz5Iq6kl9k6r9lQ=";
  };
  gccSrc = fetchurl {
    url = "http://kozos.jp/books/asm/gcc-3.4.6.tar.gz";
    sha256 = "sha256-QbJVEKz6Dvu5QRr6NU/tX5RlmtefNh3/7DBo0tPtzUQ=";
  };

  # The "major architectures" from build/binutils/targets.sh, plus two more
  # widely-used bare-metal ELF targets (m68k, sparc).
  targets = [
    "arm-elf"
    "h8300-elf"
    "i386-elf"
    "mips-elf"
    "powerpc-elf"
    "sh-elf"
    "m68k-elf"
    "sparc-elf"
  ];
in
gcc13Stdenv.mkDerivation {
  pname = "cross2";
  version = "20130826";

  srcs = [ binutilsSrc gccSrc ];
  sourceRoot = ".";

  # kozos.jp patch/ directory, copied verbatim from the upstream cross2 tarball.
  patchDir = ./patch;

  nativeBuildInputs = [ bison flex texinfo perl gawk which gnumake bzip2 gzip gnutar ];

  # gcc-3.4.6 predates every modern hardening default; build it as upstream did.
  hardeningDisable = [ "all" ];

  # gcc's 64-bit multilibs install a target libgcc under $out/lib64; nixpkgs'
  # default lib64->lib consolidation hook then fails on the non-empty dir. These
  # are per-target cross libraries, not host libs, so keep them where gcc put
  # them and skip the move.
  dontMoveLib64 = true;
  dontMoveSbin = true;

  # gcc-3.4.6 / binutils-2.21.1 parallel-build fine; we drive -j ourselves.
  enableParallelBuilding = true;

  targetsStr = lib.concatStringsSep " " targets;

  dontConfigure = true;
  dontInstall = true;

  # srcs unpacks both tarballs into $PWD (binutils-2.21.1/, gcc-3.4.6/).
  buildPhase = ''
    runHook preBuild

    set -o pipefail
    export MAKEFLAGS="-j''${NIX_BUILD_CORES:-1}"
    mkdir -p "$out/bin"
    export PATH="$out/bin:$PATH"

    echo "=== applying kozos patch set (setup.sh order) ==="
    ( cd binutils-2.21.1
      patch -p0 < "$patchDir/patch-binutils-2.21.1-alpha.txt"
      patch -p0 < "$patchDir/patch-binutils-2.21.1-sed-am.txt"
      patch -p0 < "$patchDir/patch-binutils-2.21.1-sed-in.txt"
      patch -p0 < "$patchDir/patch-binutils-2.21.1-arm.txt"
    )
    ( cd gcc-3.4.6
      patch -p0 < "$patchDir/patch-gcc-3.4.6-alpha.txt"
      patch -p0 < "$patchDir/patch-gcc-3.4.6-gcc4.txt"
      patch -p0 < "$patchDir/patch-gcc-3.4.6-ia64.txt"
      patch -p0 < "$patchDir/patch-gcc-3.4.6-newlib.txt"
      patch -p0 < "$patchDir/patch-gcc-3.4.6-vax.txt"
      patch -p0 < "$patchDir/patch-gcc-3.4.6-x64-h8300.txt"
      patch -p0 < "$patchDir/patch-gcc-3.4.6-x64-m68k.txt"
    )

    binutils_src="$PWD/binutils-2.21.1"
    gcc_src="$PWD/gcc-3.4.6"

    # binutils/all.sh options.
    bopt="--prefix=$out --disable-werror --disable-nls"
    # gcc/all.sh options (freestanding C compiler, no newlib).
    gopt="--prefix=$out --disable-werror --disable-nls --disable-threads --disable-shared --enable-languages=c"

    built=""

    for t in $targetsStr; do
      echo "=================================================================="
      echo "=== BINUTILS build for $t ==="
      echo "=================================================================="
      mkdir -p "build/binutils/$t"
      if ( cd "build/binutils/$t"
           "$binutils_src/configure" --target="$t" $bopt \
             && make $MAKEFLAGS \
             && make install ); then
        echo "BINUTILS OK $t"
      else
        echo "BINUTILS FAIL $t"
        continue
      fi

      echo "=================================================================="
      echo "=== GCC build for $t ==="
      echo "=================================================================="
      mkdir -p "build/gcc/$t"
      if ( cd "build/gcc/$t"
           "$gcc_src/configure" --target="$t" $gopt \
             && make $MAKEFLAGS \
             && make install ); then
        echo "GCC OK $t"
        built="$built $t"
      else
        echo "GCC FAIL $t"
      fi
    done

    echo "=================================================================="
    echo "=== cross2: successfully built cross-gcc targets:$built"
    echo "=================================================================="

    # Guard: the reference target must exist, otherwise the build is worthless.
    if [ ! -x "$out/bin/arm-elf-gcc" ]; then
      echo "ERROR: arm-elf-gcc was not produced; failing build." >&2
      exit 1
    fi

    runHook postBuild
  '';

  meta = with lib; {
    description = "kozos.jp cross2 bare-metal ELF cross toolchains (binutils 2.21.1 + gcc 3.4.6), built from source";
    homepage = "https://kozos.jp/books/asm/";
    license = with licenses; [ gpl2Plus gpl3Plus ];
    mainProgram = "arm-elf-gcc";
    platforms = platforms.linux;
  };
}
