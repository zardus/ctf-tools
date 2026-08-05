{ lib
, gcc13Stdenv
, bison
, flex
, texinfo
, perl
, gawk
, which
, gnumake
, m4
, ncurses
, file
, bzip2
, gzip
, gnutar
, binutilsSrc
, gccSrc
, newlibSrc
, gdbSrc
, patchDir
}:

# Build ONE cross2 target's toolchain into its own derivation, so each target is
# an independent, individually-cacheable output (cross2-<target>) that fits a
# single CI runner. binutils + gcc(+newlib) are REQUIRED (that's the toolchain);
# gdb is OPPORTUNISTIC — we attempt it for every target and simply skip it if
# this ~30-year-old port doesn't build a cross-gdb on a modern host.
#
# gcc language set / newlib usage per target come from build/gcc/targets.sh
# (resolved by ../default.nix and passed in here).

{ target                 # e.g. "arm-elf"
, gccLang                # "c" or "c,c++"
, gccNewlib              # bool: build gcc combined-tree with newlib
, gccOpt ? ""            # per-target extra gcc configure opt (e.g. --enable-obsolete)
}:

gcc13Stdenv.mkDerivation {
  pname = "cross2-${target}";
  version = "20130826";

  srcs = [ binutilsSrc gccSrc gdbSrc ] ++ lib.optional gccNewlib newlibSrc;
  sourceRoot = ".";

  nativeBuildInputs = [ bison flex texinfo perl gawk which gnumake m4 file bzip2 gzip gnutar ];
  buildInputs = [ ncurses ];  # gdb (readline/sim) links curses

  hardeningDisable = [ "all" ];   # gcc-3.4.6 predates modern hardening
  # These 2006/2011-era sources predate gcc-10's -fno-common default; several
  # (notably gdb-7.3.1's CPU simulators) rely on common symbols and hit
  # "multiple definition" link errors without it.
  env.NIX_CFLAGS_COMPILE = "-fcommon";
  dontMoveLib64 = true;
  dontMoveSbin = true;
  enableParallelBuilding = true;
  dontConfigure = true;
  dontInstall = true;

  inherit patchDir target gccLang gccNewlib gccOpt;

  buildPhase = ''
    runHook preBuild
    export MAKEFLAGS="-j''${NIX_BUILD_CORES:-1}"
    # These old libtools probe for /usr/bin/file to classify libraries; it isn't
    # in the sandbox, which breaks e.g. mmix-elf's configure-gcc. pass_all skips
    # that check entirely (standard cross-build workaround).
    export lt_cv_deplibs_check_method=pass_all
    # Pre-create the install tree: gcc-3.4.6's cross install copies man pages and
    # (per-multilib) target libs into dirs it never mkdir's, and aborts if absent.
    mkdir -p "$out/bin" "$out/man/man1" "$out/man/man7" "$out/share/man/man1" \
             "$out/${target}/lib" "$out/${target}/include" "$out/${target}/sys-include"
    export PATH="$out/bin:$PATH"
    common="--disable-werror --disable-nls"

    echo "=== patching sources (kozos setup.sh order) ==="
    ( cd binutils-2.21.1
      for p in alpha sed-am sed-in arm; do patch -p0 < "$patchDir/patch-binutils-2.21.1-$p.txt"; done )
    ( cd gcc-3.4.6
      for p in alpha gcc4 ia64 newlib vax x64-h8300 x64-m68k mmix arc fr30 v850 mcore mcoremd i960 i960c frv frvmd; do patch -p0 < "$patchDir/patch-gcc-3.4.6-$p.txt"; done )
    ( cd gdb-7.3.1
      for p in centos mn10300; do patch -p0 < "$patchDir/patch-gdb-7.3.1-$p.txt"; done )

    # These 2006/2011 autotools/libtool scripts hardcode /usr/bin/file, which
    # doesn't exist in the sandbox (it did on the legacy Ubuntu host). Point them
    # at `file` on PATH so libtool's object-type probe works (else e.g. mmix-elf's
    # configure-gcc fails).
    find binutils-2.21.1 gcc-3.4.6 gdb-7.3.1 newlib-1.20.0 -type f \
      \( -name configure -o -name ltmain.sh -o -name libtool -o -name ltconfig \) \
      -exec sed -i 's,/usr/bin/file,file,g' {} + 2>/dev/null || true

    ############################ binutils (required) ############################
    echo "================ BINUTILS $target ================"
    mkdir -p build/binutils
    ( cd build/binutils
      "$PWD/../../binutils-2.21.1/configure" --target="$target" --prefix="$out" $common
      make $MAKEFLAGS && make install ) || { echo "BINUTILS FAILED for $target" >&2; exit 1; }

    ############################ gcc (+newlib) (required) #######################
    echo "================ GCC ($gccLang, newlib=$gccNewlib) $target ================"
    newlibopt=""
    if [ "$gccNewlib" = "1" ]; then
      ln -sf ../newlib-1.20.0/newlib   gcc-3.4.6/newlib
      ln -sf ../newlib-1.20.0/libgloss gcc-3.4.6/libgloss
      newlibopt="--with-newlib"
    fi
    mkdir -p build/gcc
    ( cd build/gcc
      "$PWD/../../gcc-3.4.6/configure" --target="$target" --prefix="$out" $common \
        --disable-threads --disable-shared --enable-languages="$gccLang" $newlibopt $gccOpt
      # STMP_FIXINC= skips gcc-3.4.6's fixincludes, which chokes on modern host
      # headers (e.g. x86_64-linux's stmp-fixinc). Cross+newlib toolchains use the
      # target's own (newlib) headers, so fixing host headers is unnecessary.
      # Build xgcc + newlib's libc BEFORE the rest of the combined tree: some
      # targets' libgloss board-support links a hosted ELF against -lc during the
      # library build (e.g. xstormy16's eva_stub.elf). Under parallel make the
      # combined tree otherwise races all-target-libgloss ahead of all-target-newlib
      # and fails with "ld: cannot find -lc". Staging newlib first is the correct
      # dependency order and is a no-op for targets that don't hit the race.
      if [ "$gccNewlib" = "1" ]; then make $MAKEFLAGS all-target-newlib STMP_FIXINC=; fi
      make $MAKEFLAGS STMP_FIXINC= ) || { echo "GCC COMPILE FAILED for $target" >&2; exit 1; }
    # gcc's cross install writes per-multilib target libs (e.g. arm-elf/lib/thumb)
    # into dirs it doesn't create; pre-create them from the compiler's own list.
    for ml in $(build/gcc/gcc/xgcc -Bbuild/gcc/gcc/ -print-multi-lib 2>/dev/null | sed 's/;.*//'); do
      mkdir -p "$out/${target}/lib/$ml"
    done
    ( cd build/gcc && make install ) || { echo "GCC INSTALL FAILED for $target" >&2; exit 1; }

    ############################ gdb (opportunistic) ###########################
    # Attempt a cross-gdb for every target; skip (don't fail the toolchain) if
    # this old target doesn't build one on a modern host.
    echo "================ GDB $target (opportunistic) ================"
    mkdir -p build/gdb
    if ( cd build/gdb
         "$PWD/../../gdb-7.3.1/configure" --target="$target" --prefix="$out" $common
         make $MAKEFLAGS && make install ); then
      echo "GDB OK $target"
    else
      echo "GDB skipped for $target (does not build; compiler still installed)"
    fi

    test -x "$out/bin/${target}-gcc"   # the toolchain must have produced a compiler
    runHook postBuild
  '';

  meta = with lib; {
    description = "kozos.jp cross2 ${target} toolchain (binutils 2.21.1 + gcc 3.4.6"
      + lib.optionalString gccNewlib " + newlib 1.20.0"
      + "; gdb 7.3.1 when it builds)";
    homepage = "https://kozos.jp/books/asm/";
    license = with licenses; [ gpl2Plus gpl3Plus ];
    mainProgram = "${target}-gcc";
    platforms = platforms.linux;
  };
}
