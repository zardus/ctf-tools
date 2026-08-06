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
# this ~30-year-old port doesn't build a cross-gdb on a modern host; when it
# can't, we fall back to gdb's standalone CPU simulator (upstream's
# targets_simonly path), which is how e.g. mcore-elf-run gets built.
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
      # Generate gcc/Makefile (without building yet) so we can see what gcc
      # decided about system headers.
      make $MAKEFLAGS configure-gcc
      # When the target triple equals the build triple -- cross2's x86_64-linux on
      # an x86_64 host -- gcc-3.4.6 considers itself native and points fixincludes
      # at the host's /usr/include, which does not exist in the Nix sandbox:
      # "The directory that should contain system headers does not exist".
      # This is a --with-newlib toolchain that uses the target's own headers, so
      # fixing host headers achieves nothing; drop the step for the native case
      # only, leaving genuine cross targets' fixincludes alone.
      # NB: `make STMP_FIXINC=` does NOT work here -- gcc's top-level Makefile
      # sets MAKEOVERRIDES= ("Don't pass command-line variables to submakes"), so
      # the override never reaches gcc/Makefile. It has to be edited in place.
      if grep -qE '^SYSTEM_HEADER_DIR *= *\$\(NATIVE_SYSTEM_HEADER_DIR\)' gcc/Makefile; then
        sed -i 's/^STMP_FIXINC *=.*/STMP_FIXINC =/' gcc/Makefile
      fi
      # Build xgcc + newlib's libc BEFORE the rest of the combined tree: some
      # targets' libgloss board-support links a hosted ELF against -lc during the
      # library build (e.g. xstormy16's eva_stub.elf). Under parallel make the
      # combined tree otherwise races all-target-libgloss ahead of all-target-newlib
      # and fails with "ld: cannot find -lc". Staging newlib first is the correct
      # dependency order and is a no-op for targets that don't hit the race.
      if [ "$gccNewlib" = "1" ]; then make $MAKEFLAGS all-target-newlib; fi
      make $MAKEFLAGS ) || { echo "GCC COMPILE FAILED for $target" >&2; exit 1; }
    # gcc's cross install writes per-multilib target libs (e.g. arm-elf/lib/thumb)
    # into dirs it doesn't create; pre-create them from the compiler's own list.
    for ml in $(build/gcc/gcc/xgcc -Bbuild/gcc/gcc/ -print-multi-lib 2>/dev/null | sed 's/;.*//'); do
      mkdir -p "$out/${target}/lib/$ml"
    done
    # libgloss's multilib install races with itself: for e.g. mcore-elf two
    # rules (install / install-mon) copy the same crt0.o into
    # <target>/lib/<multilib>, and coreutils' install unlinks the destination
    # and reopens it O_EXCL, so under -j the loser dies with "cannot create
    # regular file ...: File exists". Nothing is corrupted, so retry serially
    # rather than fail the toolchain -- the parallel path is left alone for the
    # targets that don't hit this.
    ( cd build/gcc && make install ) \
      || { echo "GCC INSTALL: parallel install raced for $target, retrying with -j1" >&2
           ( cd build/gcc && make -j1 install ); } \
      || { echo "GCC INSTALL FAILED for $target" >&2; exit 1; }

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

    ###################### gdb simulator only (opportunistic) ##################
    # Upstream build/gdb/all.sh has a second path (targets_simonly) for targets
    # whose gdb core has no port -- mcore-elf is the one upstream lists, and its
    # gdb configure really does say "configuration mcore-unknown-elf is
    # unsupported" -- but which do ship a CPU simulator under gdb-7.3.1/sim. For
    # those it builds bfd/opcodes/libiberty/sim standalone and installs just
    # <target>-run. Do the same generically for any target whose full-gdb
    # attempt above didn't leave a <target>-run behind.
    if [ ! -x "$out/bin/${target}-run" ]; then
      echo "================ SIM $target (opportunistic) ================"
      # sim/<arch>'s Makefile hardcodes ../../{bfd,opcodes,libiberty}/lib*.a and
      # -I../../{bfd,opcodes}, so these four build dirs must be siblings under a
      # common root -- they can't go in build/{bfd,sim,...} next to build/gcc.
      mkdir -p build/sim-only/sim
      # Configure sim first: it's cheap and needs nothing else built, and
      # whether it created an arch subdir tells us if this target has a
      # simulator at all -- targets without one then skip bfd/opcodes entirely.
      ( cd build/sim-only/sim
        "$PWD/../../../gdb-7.3.1/sim/configure" --target="$target" --prefix="$out" $common ) || true
      simarch=""
      for d in build/sim-only/sim/*/; do
        [ -d "$d" ] || continue
        case "$(basename "$d")" in
          common|testsuite) ;;
          *) simarch="$(basename "$d")" ;;
        esac
      done
      # Only sim is installed: gdb-7.3.1's bfd/opcodes/libiberty would overwrite
      # files binutils 2.21.1 already put in $out (lib64/libiberty.a, bfd.info)
      # with near-identical copies from a different source tree, for no gain --
      # their .a files are only consumed in-tree by sim.
      if [ -n "$simarch" ] && ( set -e
           cd build/sim-only
           for sub in libiberty bfd opcodes; do
             mkdir -p "$sub"
             ( cd "$sub"
               "$PWD/../../../gdb-7.3.1/$sub/configure" --target="$target" --prefix="$out" $common
               make $MAKEFLAGS )
           done
           cd sim && make $MAKEFLAGS && make install ); then
        echo "SIM OK $target ($simarch)"
      else
        echo "SIM skipped for $target (no simulator for this target, or it does not build)"
      fi
    fi

    test -x "$out/bin/${target}-gcc"   # the toolchain must have produced a compiler
    runHook postBuild
  '';

  meta = with lib; {
    description = "kozos.jp cross2 ${target} toolchain (binutils 2.21.1 + gcc 3.4.6"
      + lib.optionalString gccNewlib " + newlib 1.20.0"
      + "; gdb 7.3.1, or just its CPU simulator, when they build)";
    homepage = "https://kozos.jp/books/asm/";
    license = with licenses; [ gpl2Plus gpl3Plus ];
    mainProgram = "${target}-gcc";
    platforms = platforms.linux;
  };
}
