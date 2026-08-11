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
, prune ? true           # strip host binaries + target debug info, drop the
                         # libstdc++ precompiled headers and de-duplicate
                         # identical files (see the prune block in buildPhase).
                         # Defaults on; `.unstripped` is the same toolchain with
                         # prune = false, for anyone who wants full DWARF and the
                         # precompiled headers locally.
}:

let
  # The toolchain proper, parameterised on `prune` alone. Everything else is
  # closed over from the argument set above, so the two variants differ only in
  # the tail of buildPhase.
  mkTc = { prune }: gcc13Stdenv.mkDerivation {
  pname = "cross2-${target}" + lib.optionalString (!prune) "-unstripped";
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

  # `.unstripped` is this same toolchain with the prune block switched off, so a
  # developer who wants full target DWARF (and the libstdc++ precompiled
  # headers) can `nix build .#cross2-<target>.unstripped` without editing
  # anything. The `optionalAttrs prune` guard is what makes this terminate: the
  # recursive call is `mkTc { prune = false; }`, and inside *that* derivation
  # the guard is false, so it gets no `unstripped` of its own and the chain
  # stops one level down. Laziness alone would not be enough — an unguarded
  # `unstripped = mkTc { prune = !prune; }` only diverges when something walks
  # the attribute, which is exactly what `nix flake show` / `nix search` do.
  passthru = { inherit target gccLang gccNewlib gccOpt; }
    // lib.optionalAttrs prune { unstripped = mkTc { prune = false; }; };

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
  ''
  # ==========================================================================
  # Prune: shrink the installed tree without changing what it can do.
  #
  # This hangs off the END of buildPhase, after the `test -x` gate, on purpose.
  # The derivation sets dontInstall = true and installs from inside buildPhase
  # (binutils, then gcc, then gdb-or-its-simulator), so $out is only complete at
  # this point — anything earlier would prune a tree that a later `make install`
  # then repopulates with un-pruned files. It also has to run *before* stdenv's
  # fixupPhase, so that the before/after link probe below brackets exactly our
  # own edits and nothing else, and so a prune that breaks the toolchain fails
  # the build here rather than shipping.
  #
  # Why bother: the Cachix cache is 5GB and the toolchain fleet needs 12.78GB,
  # so it evicts constantly and CI rebuilds half the fleet nightly. cross2 is
  # 34 targets / 4.09GB raw. Measured by hand on the largest of them,
  # cross2-sh64-elf (294MB raw / 54.0MB zstd-3):
  #   + strip host binaries              292MB / 53.5MB
  #   + strip debug from target archives 163MB / 28.1MB   <- the big one
  #   + drop libstdc++ .gch headers      106MB / 21.0MB
  # i.e. 61% off, with C and C++ verified still compiling and linking after.
  # That 61% is the best case, not the mean: sh64-elf is the biggest and most
  # multilib-heavy target. A small one like x86_64-linux, whose target-side tree
  # is a handful of files and which has no .gch at all, sheds ~10%. The
  # de-duplication step (4) is worth a lot of raw NAR but much less compressed
  # (~0.4-0.9MB zstd-3 per target) — zstd already collapses most duplication.
  #
  # Nothing removed here has runtime meaning: the target libc/newlib/libgloss
  # libraries, the linker scripts, the specs files and the gdb CPU simulators
  # (mcore-elf-run and friends — the whole point of several targets) are all
  # left exactly as installed.
  # ==========================================================================
  + lib.optionalString prune ''

    # ------------------------------------------------------------------ probe
    # A prune bug can leave a toolchain that still *looks* right — plausible
    # files, plausible sizes — but cannot link at all (see the host-strip vs
    # cross-strip hazard below). So: compile+link before pruning and again
    # after, and fail on any before->after regression.
    #
    # These are 34 heterogeneous ~30-year-old ports — bare-metal ELF with and
    # without newlib, a few hosted-ish ones (hppa-linux, powerpc64-linux,
    # s390-linux, x86_64-linux), vax-netbsdelf, pdp11-aout — so no single fixed
    # command line can work everywhere. Walk a ladder of flag sets from most to
    # least demanding and take the first rung that produces an output file:
    #
    #   rung 1  (no flags)              full link: crt*.o + libc + libgcc
    #   rung 2  -nostartfiles           links libc + libgcc, no startup files
    #   rung 3  -nostdlib -nostartfiles ld runs, but opens no target library
    #   rung 4  -c                      compile only; any working gcc manages it
    #
    # Rung 2 exists because several ports cannot manage rung 1 for reasons that
    # have nothing to do with pruning — newlib's i386-elf ships no crt0.o, so
    # even the unpruned toolchain fails "cannot find crt0.o" — and without it
    # those targets would settle on a rung that opens no target archive at all,
    # leaving the step that rewrites every target archive unverified precisely
    # where it matters. Rung 2 still pulls libc.a and libgcc.a through ld.
    #
    # The verdict compares the rung NUMBER, not merely "did anything work". A
    # boolean comparison is worthless here: corrupt libc.a and rung 1 fails
    # while rung 2 still "succeeds", so the probe would wave through exactly
    # the damage it exists to catch (confirmed by hand — truncating
    # $out/${target}/lib/libc.a demotes the probe from rung 1 to rung 2 while a
    # user's link dies with "could not read symbols"). Falling to a higher rung
    # number, or off the ladder entirely, is therefore a failure. A port that
    # could only manage rung 3 (or nothing) *before* the prune is held to that
    # same rung afterwards and otherwise tolerated — that is a pre-existing
    # property of the port, not a regression this prune caused.
    #
    # Both languages the toolchain was built with are probed: step 3 deletes a
    # C++-only artifact, so a C-only probe would leave it unverified on the 18
    # targets built --enable-languages=c,c++.
    #
    # prune_probe prints ONLY the rung number on stdout, so a caller can capture
    # it; everything human-readable goes to stderr, which lands in the same
    # build log.
    prune_probe() {
      local phase="$1" lang="$2"
      local drv ext
      case "$lang" in
        c++) drv="$out/bin/${target}-g++"; ext="cc" ;;
        *)   drv="$out/bin/${target}-gcc"; ext="c"  ;;
      esac
      if [ ! -x "$drv" ]; then
        echo "  probe ($phase, $lang): no $(basename "$drv") in \$out/bin; skipping" >&2
        return 1
      fi
      local dir="$TMPDIR/prune-probe-$phase-$lang"
      rm -rf "$dir"; mkdir -p "$dir"
      if [ "$lang" = "c++" ]; then
        # Pulls in a real libstdc++ header on purpose: that header is precisely
        # what step 3 deletes the precompiled copy of.
        printf '%s\n' \
          '#include <vector>' \
          '#include <string>' \
          'int main(void){ std::vector<int> v; v.push_back(1);' \
          '  std::string s("x"); return (int)(v.size() + s.size()) - 2; }' \
          > "$dir/probe.$ext"
      else
        printf 'int main(void){return 0;}\n' > "$dir/probe.$ext"
      fi
      local rung n=0
      for rung in "" "-nostartfiles" "-nostdlib -nostartfiles" "-c"; do
        n=$((n + 1))
        rm -f "$dir/probe.out"
        # $rung is intentionally unquoted: it carries multiple flags.
        if "$drv" $rung "$dir/probe.$ext" -o "$dir/probe.out" \
             > "$dir/rung$n.log" 2>&1 && [ -s "$dir/probe.out" ]; then
          echo "  probe ($phase, $lang): ok on rung $n [$(basename "$drv") $rung]" >&2
          echo "$n"
          return 0
        fi
      done
      echo "  probe ($phase, $lang): every rung failed; tail of the last one:" >&2
      tail -n 20 "$dir/rung$n.log" | sed 's/^/    /' >&2
      return 1
    }

    # buildPhase already gated on this, but the whole prune (and every rung of
    # the probe) is meaningless without it, so say so rather than degrade into
    # "nothing worked before either, tolerate everything" mode.
    if [ ! -x "$out/bin/${target}-gcc" ]; then
      echo "ERROR: \$out/bin/${target}-gcc is missing; refusing to prune." >&2
      exit 1
    fi

    # C-only targets have no ${target}-g++ at all; gccLang decides.
    probe_langs="${if lib.hasInfix "c++" gccLang then "c c++" else "c"}"
    declare -A prune_rung_before prune_rung_after
    echo "=== prune: probing the toolchain BEFORE pruning ==="
    for probe_lang in $probe_langs; do
      # `|| true`: an empty rung means "this port could not do it beforehand",
      # which the verdict below tolerates. It must not abort the build here.
      prune_rung_before[$probe_lang]="$(prune_probe before "$probe_lang" || true)"
    done

    # ==== HOST STRIP vs CROSS STRIP — read this before touching either find ===
    # Two strips are in play and they are not interchangeable:
    #   * the HOST strip from stdenv, for the x86-64 executables and shared
    #     objects this toolchain is made of ($out/bin, $out/libexec, and
    #     $out/${target}/bin — see step 1);
    #   * $out/bin/${target}-strip, for the TARGET .a/.o archives it ships.
    # Getting them backwards does not fail loudly — it corrupts silently. Run a
    # cross strip over a host ELF and BFD's generic backend happily rewrites the
    # header's e_machine to "no machine", after which shared objects will not
    # load and every link dies. That mistake has already been made once by hand
    # on the sibling crosstool-NG family. The two find expressions below are
    # therefore scoped so they cannot overlap, and each re-checks with file(1)
    # rather than trusting the directory layout — note in particular that
    # $out/${target}/bin/{ld,as,ar,...} is a *second copy of the host binutils*
    # sitting inside the target directory.
    # =========================================================================

    # ------------------------------------------- 1. strip the HOST executables
    # cross2 (unlike crosstool-NG) strips nothing at all: ${target}-gcc ships
    # "not stripped". --strip-unneeded rather than a full strip, because
    # $out/libexec may hold host shared objects whose dynamic symbols must
    # survive. Only files file(1) calls x86-64 are touched, so shell wrappers,
    # gcc's install-tools scripts and the specs files are passed over.
    #
    # $out/${target}/bin is in scope and has to be: binutils installs a whole
    # SECOND copy of the host tools there (ar, as, ld, ld.bfd, nm, objcopy,
    # objdump, ranlib, strip + gcc's gcc/c++/g++ drivers — 13.5MB on sh64-elf),
    # nixpkgs' fixupPhase does not reach it (stripDebugList is bin/sbin/lib/
    # lib32/lib64/libexec), and skipping it would also break step 4: those files
    # are byte-identical to their $out/bin/${target}-* counterparts, so
    # stripping one copy and not the other makes their hashes diverge and the
    # de-duplication finds nothing (measured: 11.3MB, 12% of the pruned tree).
    # It holds no *.a/*.o, so it cannot collide with the cross strip below.
    #
    # `strip` is NOT taken from PATH: buildPhase prepends $out/bin, so a bare
    # `strip` is one binutils-layout change away from resolving to a CROSS
    # strip — the precise mix-up the banner above warns about. Resolve it from
    # the stdenv part of PATH instead, and refuse to guess if it isn't there.
    host_strip=""
    IFS=: read -r -a prune_path_dirs <<< "$PATH"
    for d in "''${prune_path_dirs[@]}"; do
      case "$d" in "$out"|"$out"/*) continue ;; esac
      if [ -x "$d/strip" ]; then host_strip="$d/strip"; break; fi
    done
    if [ -z "$host_strip" ]; then
      echo "ERROR: no host strip on PATH outside \$out — stdenv always provides" >&2
      echo "one, so something is wrong. Refusing to prune with a guess." >&2
      exit 1
    fi
    echo "=== prune: stripping host binaries with $host_strip ==="
    host_roots=()
    for d in "$out/bin" "$out/libexec" "$out/${target}/bin"; do
      if [ -d "$d" ]; then host_roots+=("$d"); fi
    done
    if [ "''${#host_roots[@]}" -eq 0 ]; then
      echo "  no host binary dirs under \$out; nothing to do"
    else
      echo "  roots: ''${host_roots[*]}"
      host_n=0
      while IFS= read -r -d "" f; do
        case "$(file -b "$f")" in
          *x86-64*) ;;
          *) continue ;;
        esac
        if "$host_strip" --strip-unneeded "$f" 2> "$TMPDIR/prune-strip.err"; then
          host_n=$((host_n + 1))
        else
          # Reported, not swallowed: a strip that genuinely errors should be
          # visible in the log even though one bad file must not fail 34 builds.
          printf '  host strip declined: %s (%s)\n' \
            "''${f#$out/}" "$(tr '\n' ' ' < "$TMPDIR/prune-strip.err")"
        fi
      done < <(find "''${host_roots[@]}" -type f -print0)
      echo "  stripped $host_n host binary/binaries"
    fi

    # -------------------------------------- 2. strip the TARGET debug info
    # --strip-debug, NOT a full strip: the symbol tables must survive or linking
    # against these archives breaks outright. Verified by hand on sh64-elf that
    # a linked output had an identical symbol count (234) before and after.
    #
    # Scope: $out/${target} (newlib/libgloss libc.a, libm.a, crt0.o, ...) and
    # $out/lib/gcc (libgcc.a, crtbegin.o, ...), restricted to *.a and *.o. That
    # name filter is itself part of the safety scoping — it is what keeps the
    # host binutils copy under $out/${target}/bin out of the cross strip's
    # reach. $out/lib/gcc rather than all of $out/lib is load-bearing for the
    # same reason and must not be widened back: $out/lib is a host libdir, and
    # $out/lib/libiberty.a in particular is a HOST x86-64 archive that
    # ${target}-strip will happily rewrite member by member to "no machine"
    # while exiting 0 (measured: 41 "Unable to recognise the format" warnings,
    # rc=0, file changed, every member corrupted).
    strip_bin="$out/bin/${target}-strip"
    ar_bin="$out/bin/${target}-ar"
    if [ ! -x "$strip_bin" ]; then
      # Not skippable: binutils is a REQUIRED stage of this build, and this is
      # by far the largest saving (294MB -> 163MB raw / 54.0 -> 28.1MB zstd on
      # sh64-elf). Silently omitting it produces a toolchain 2-3x bigger than
      # intended that still passes CI and re-evicts the cache this change
      # exists to protect.
      echo "ERROR: \$out/bin/${target}-strip is missing even though binutils is a" >&2
      echo "required stage; the target debug strip cannot run. Refusing." >&2
      exit 1
    fi
    tgt_roots=()
    for d in "$out/${target}" "$out/lib/gcc"; do
      if [ -d "$d" ]; then tgt_roots+=("$d"); fi
    done
    if [ "''${#tgt_roots[@]}" -eq 0 ]; then
      echo "=== prune: no target lib dirs (no newlib/libgcc?); nothing to strip ==="
    else
      echo "=== prune: stripping target debug info under ''${tgt_roots[*]} ==="
      strip_tmp="$TMPDIR/prune-strip.d"
      tgt_ok=0; tgt_skip=0
      # An archive's identity: the member list, plus the architecture of its
      # first member with file(1)'s "with debug_info"/"not stripped" tail cut
      # off (those legitimately change under --strip-debug; the architecture
      # must not). Empty for anything that is not a readable archive. Taken
      # before and after the strip, this is what turns the silent-corruption
      # hazard into a caught one: a cross strip run over a host archive
      # rewrites every member to "no machine" and still exits 0.
      # Nothing here may pipe ar's output into a consumer that stops reading
      # early: the builder runs with `set -o pipefail`, so a SIGPIPE'd ar makes
      # the whole pipeline (and, through the command substitution, the build)
      # fail. That rules out `ar t | head -1` and `ar p | file -` alike — file(1)
      # reads only a prefix. Hence the shell-side first line and the temp file.
      prune_ar_identity() {
        local a="$1" list mem
        list="$("$ar_bin" t "$a" 2>/dev/null || true)"
        [ -n "$list" ] || return 0
        mem="''${list%%$'\n'*}"
        printf '%s\n' "$list"
        "$ar_bin" p "$a" "$mem" > "$TMPDIR/prune-ar-member" 2>/dev/null || true
        file -b "$TMPDIR/prune-ar-member" | cut -d, -f1-2
        return 0
      }

      while IFS= read -r -d "" f; do
        rel="''${f#$out/}"
        ar_id=""
        # `|| true` on every call: the builder runs under `set -e`, so a
        # non-zero status escaping the function (a pipeline inside it, a tool
        # that is not there) would abort the whole build from inside a command
        # substitution, with nothing on stderr to say why. An unreadable
        # archive must degrade to "no identity", never to a dead build.
        case "$rel" in
          *.a) ar_id="$(prune_ar_identity "$f" || true)" ;;
        esac
        # Belt and braces for the hazard described above: never hand an
        # x86-64 object to a cross strip. Exempt only the x86_64-linux
        # target, where host and target format coincide and the cross strip
        # writes the correct e_machine back anyway.
        if [ "${target}" != "x86_64-linux" ]; then
          case "$(file -b "$f")" in
            *x86-64*)
              printf '  refusing to cross-strip host object: %s\n' "$rel"
              continue ;;
          esac
          # file(1) describes EVERY ar archive as "current ar archive" with no
          # architecture at all, so the test above is structurally blind to a
          # host .a — which is the dangerous case, since a cross strip corrupts
          # one while still exiting 0. Look inside at the first member instead.
          # Nothing under these roots is a host archive today ($out/${target}/
          # lib/libiberty.a is a target build; the host copies live in
          # $out/lib and $out/lib64, outside the roots), so this enforces the
          # scoping invariant rather than assuming it survives future edits.
          case "''${ar_id##*$'\n'}" in
            *x86-64*)
              printf '  refusing to cross-strip host archive: %s\n' "$rel"
              continue ;;
          esac
        fi
        # Strip a COPY under $TMPDIR and write it back only on success — never
        # in place. binutils 2.21.1 explodes an archive into an mkstemp'd
        # stXXXXXX directory NEXT TO the file being stripped and unlinks it only
        # when it finishes; sh64-elf-strip segfaults (rc=139, reproducibly) on
        # the four media64 libgcc.a multilibs, which in-place would leave 8
        # randomly-named stray paths inside $out — junk shipped to the cache,
        # and a derivation whose output file names differ from build to build
        # (nix build --check would flag it). Done here, the same wreckage lands
        # in $TMPDIR and dies with the sandbox.
        #
        # Per-file rather than a batched xargs: a few matches are legitimately
        # not ELF (linker scripts named *.a, stub *.o shipped as text) and
        # strip rightly refuses them. Count and print those; do not abort.
        rm -rf "$strip_tmp"; mkdir -p "$strip_tmp"
        cp -- "$f" "$strip_tmp/obj"
        chmod u+w "$strip_tmp/obj"
        if "$strip_bin" --strip-debug "$strip_tmp/obj" 2> "$TMPDIR/prune-strip.err"; then
          # An archive whose member list or member architecture changed did not
          # get stripped, it got mangled — the "exits 0 and corrupts anyway"
          # case. This is checked on the temp copy, so the original in $out is
          # still untouched and the answer is simply to keep it: a slightly
          # bigger toolchain beats a broken one, and the log says so loudly.
          if [ -n "$ar_id" ] \
             && [ "$(prune_ar_identity "$strip_tmp/obj" || true)" != "$ar_id" ]; then
            tgt_skip=$((tgt_skip + 1))
            printf '  WARNING: --strip-debug altered the contents of %s (member list or\n' "$rel" >&2
            printf '  member architecture changed); keeping the original unstripped.\n' >&2
            continue
          fi
          # cat, not mv: keeps $f's own mode and inode and never imports the
          # temp file's permissions.
          cat "$strip_tmp/obj" > "$f"
          tgt_ok=$((tgt_ok + 1))
        else
          strip_rc=$?
          tgt_skip=$((tgt_skip + 1))
          strip_why="$(tr '\n' ' ' < "$TMPDIR/prune-strip.err")"
          # A signal death writes nothing to stderr, so without this a crash
          # logs as "not stripped: ... ()" and reads like a benign non-ELF skip.
          if [ "$strip_rc" -ge 128 ]; then
            strip_why="CRASHED, signal $((strip_rc - 128)) ''${strip_why}"
          else
            strip_why="rc=$strip_rc ''${strip_why}"
          fi
          printf '  not stripped: %s (%s)\n' "$rel" "$strip_why"
        fi
      done < <(find "''${tgt_roots[@]}" -type f \( -name '*.a' -o -name '*.o' \) -print0)
      rm -rf "$strip_tmp"
      echo "  stripped $tgt_ok target file(s), left $tgt_skip alone"
    fi

    # ------------------------------- 3. drop the libstdc++ precompiled headers
    # On a c,c++ target, $out/include/c++/3.4.6/${target}/bits/stdc++.h.gch/
    # holds two ~29.9MB precompiled copies of the same header (O0g and O2g) —
    # essentially the entire 60MB include/ tree. They are a COMPILE-SPEED cache
    # and nothing else: with them gone gcc silently parses the real stdc++.h,
    # which was verified by hand to still compile C++ for sh64-elf. Targets
    # built --enable-languages=c have none of this and the find is a no-op.
    # -prune so find does not then try to descend into what rm just deleted
    # (which is what would otherwise force an error-suppressing `|| true`).
    gch_n=$(find "$out" -name '*.gch' -prune -print | wc -l)
    if [ "$gch_n" -gt 0 ]; then
      # Count the *files* too: a .gch is a directory holding one precompiled
      # image per optimisation level, so "1 directory" is 2 x 29.9MB on
      # sh64-elf and the directory count alone reads like a partial hit.
      gch_files=$(find "$out" -path '*.gch/*' -type f | wc -l)
      gch_kib=$(find "$out" -name '*.gch' -prune -print0 \
                  | xargs -0 -r du -sk | awk '{ s += $1 } END { print s + 0 }')
      echo "=== prune: dropping $gch_n precompiled-header dir(s), $gch_files file(s), $gch_kib KiB ==="
      find "$out" -name '*.gch' -prune -exec rm -rf {} +
    else
      echo "=== prune: no precompiled headers (C-only target) ==="
    fi

    # ------------------------- 4. de-duplicate identical files via symlinks
    # binutils is installed under both prefixes, so $out/bin/${target}-ld and
    # $out/${target}/bin/ld are byte-identical, and likewise as, ar, nm,
    # objdump, ranlib and strip; gcc's multilib target libraries duplicate each
    # other too. On a normal filesystem these would be hard links and cost
    # nothing — but NAR, the archive format Nix uses for the binary cache, has
    # no concept of a hard link, so every copy is serialised in full and the
    # cache pays for each one. NAR *does* represent symlinks, so replacing the
    # duplicates with symlinks is the fix (~63.5MB raw across the family).
    #
    # Relative (ln -r), not absolute, so the links survive anything that copies
    # or relocates the tree wholesale.
    #
    # Unlike step 1/2 this deliberately covers all of $out including $out/bin,
    # and it is safe there in a way that stripping is not: the file that stays
    # is byte-for-byte the file that was removed.
    echo "=== prune: replacing duplicate files >=64KiB with relative symlinks ==="
    dup_plan="$TMPDIR/prune-dup-plan"
    # Sort by path length (then lexically, for determinism) *before* hashing, so
    # the first file in each group of identical files is the shortest path. That
    # one stays real and every later one becomes a link to it — which also means
    # a kept file is never itself demoted afterwards, so no symlink ever ends up
    # pointing at another symlink. -type f skips existing symlinks by itself.
    # LC_ALL=C on the sort so the tie-break between two equal-length paths (and
    # therefore which of the pair stays a real file) does not depend on the
    # builder's collation.
    find "$out" -type f -size +63k -printf '%s\t%p\n' \
      | awk -F'\t' '$1 >= 65536 { print length($2) "\t" $2 }' \
      | LC_ALL=C sort -t "$(printf '\t')" -k1,1n -k2,2 \
      | cut -f2- \
      | tr '\n' '\0' \
      | xargs -0 -r sha256sum -- \
      | awk '{ h = $1; sub(/^[^ ]+  /, "");
               if (h in keep) print $0 "\t" keep[h]; else keep[h] = $0 }' \
      > "$dup_plan"
    dup_n=0; dup_kib=0
    while IFS="$(printf '\t')" read -r dup orig; do
      [ -f "$dup" ] && [ -f "$orig" ] || continue
      dup_kib=$((dup_kib + $(stat -c %s "$dup") / 1024))
      rm -f "$dup"
      ln -s -r -- "$orig" "$dup"
      dup_n=$((dup_n + 1))
    done < "$dup_plan"
    echo "  linked $dup_n duplicate(s), $dup_kib KiB of uncompressed NAR"

    # -------------------------------------------------------------- verdict
    echo "=== prune: probing the toolchain AFTER pruning ==="
    for probe_lang in $probe_langs; do
      prune_rung_after[$probe_lang]="$(prune_probe after "$probe_lang" || true)"
    done
    rm -rf "$TMPDIR"/prune-probe-* "$TMPDIR/prune-strip.err" \
           "$TMPDIR/prune-ar-member" "$dup_plan"
    # Compare the rung reached, not just "did anything work" — see the probe
    # comment: a corrupted libc.a still passes a lower rung.
    prune_regressed=0
    for probe_lang in $probe_langs; do
      rung_b="''${prune_rung_before[$probe_lang]}"
      rung_a="''${prune_rung_after[$probe_lang]}"
      if [ -z "$rung_b" ]; then
        echo "note: ${target} ($probe_lang) already failed every probe rung before" \
             "pruning; treating that as a pre-existing property of this port."
      elif [ -z "$rung_a" ]; then
        echo "ERROR: ${target} ($probe_lang) reached probe rung $rung_b before pruning" >&2
        echo "and now fails every rung — the prune broke it. Refusing to install." >&2
        prune_regressed=1
      elif [ "$rung_a" -gt "$rung_b" ]; then
        echo "ERROR: ${target} ($probe_lang) reached probe rung $rung_b before pruning" >&2
        echo "and only rung $rung_a after. A higher rung is a WEAKER test (rung 3" >&2
        echo "opens no target library, rung 4 does not link at all), so this means" >&2
        echo "the prune damaged something the toolchain needs. Refusing to install." >&2
        prune_regressed=1
      fi
    done
    if [ "$prune_regressed" != 0 ]; then exit 1; fi
  ''
  + ''
    runHook postBuild
  '';

  meta = with lib; {
    description = "kozos.jp cross2 ${target} toolchain (binutils 2.21.1 + gcc 3.4.6"
      + lib.optionalString gccNewlib " + newlib 1.20.0"
      + "; gdb 7.3.1, or just its CPU simulator, when they build)"
      + lib.optionalString (!prune)
          " [unpruned: target debug info and precompiled headers kept]";
    homepage = "https://kozos.jp/books/asm/";
    license = with licenses; [ gpl2Plus gpl3Plus ];
    mainProgram = "${target}-gcc";
    platforms = platforms.linux;
  };
  };
in
mkTc { inherit prune; }
