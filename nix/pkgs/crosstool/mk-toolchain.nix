{ lib
, stdenv
, ctng
, ctBuildInputs
, cacert
, fetchurl
}:

# Build a single crosstool-NG sample toolchain (binutils + gcc + libc + ...)
# entirely offline, in two derivations, so it fits the pure Nix sandbox:
#
#   1. `sources` -- a FIXED-OUTPUT derivation (network allowed). It configures
#      the sample with CT_ONLY_DOWNLOAD=y + CT_SAVE_TARBALLS=y and runs
#      `ct-ng build`, which stops right after fetching every upstream source
#      tarball into $out. Because it is fixed-output, its content hash is
#      pinned (see ./hashes.nix); this is what makes the download reproducible.
#
#   2. `toolchain` -- a normal (sandboxed, no-network) derivation. It configures
#      the same sample with CT_FORBID_DOWNLOAD=y and points
#      CT_LOCAL_TARBALLS_DIR at the `sources` output, then runs `ct-ng build`
#      to compile the real cross toolchain and installs it into $out.
#
# The resulting toolchain derivation exposes the cross compilers directly in
# $out/bin (e.g. avr-gcc, arm-none-eabi-gcc, riscv32-unknown-elf-gcc, ...),
# with the full install tree under $out (bin, lib, <target>/, ...).

let
  # Sanitize a sample name into something usable as a Nix attr / CLI-friendly
  # package name: lower-case is preserved, commas and any character outside
  # [a-zA-Z0-9_-] become '-'.
  sanitizeName = name:
    let
      chars = lib.stringToCharacters name;
      keep = c: (c >= "a" && c <= "z") || (c >= "A" && c <= "Z")
             || (c >= "0" && c <= "9") || c == "_" || c == "-";
      mapped = map (c: if keep c then c else "-") chars;
    in lib.concatStrings mapped;

  # Shared shell that configures a sample into ./.config. `$sample` must be set.
  configureSample = ''
    # crosstool-NG aborts if any of these compiler-influencing variables are
    # set -- and the Nix stdenv sets several of them (CC, CXX, ...). Clear them;
    # ct-ng finds the host gcc via PATH instead.
    # (Only the vars ct-ng explicitly forbids -- NIX_CFLAGS_COMPILE / NIX_LDFLAGS
    # are left intact so the Nix-wrapped host gcc still finds libc.)
    unset CC CXX CFLAGS CXXFLAGS \
          LD_LIBRARY_PATH LIBRARY_PATH LPATH CPATH \
          C_INCLUDE_PATH CPLUS_INCLUDE_PATH OBJC_INCLUDE_PATH \
          GREP_OPTIONS

    # The Nix stdenv also exports the whole *host* binutils set (AR=ar, AS=as,
    # LD=ld, NM=nm, OBJCOPY=objcopy, ...). ct-ng does not know about these, so
    # they leak straight through into every sub-build and silently override the
    # cross tools it just built. glibc's Makerules, for instance, strips
    # libc_pic.os with $(OBJCOPY): with the host x86_64 objcopy that happens to
    # work for x86 targets and fails for every other architecture. mingw-w64's
    # CRT hits the same thing via $(AS) ("cannot represent relocation type
    # BFD_RELOC_RVA" from the ELF assembler). Clear them all -- each ct-ng step
    # sets the right (cross-)tool for itself.
    unset AR AS LD NM OBJCOPY OBJDUMP RANLIB READELF SIZE STRINGS STRIP \
          LDFLAGS CPP HOSTCC

    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    # crosstool-NG downloads tarballs with wget, and the nixpkgs wget does NOT
    # honour $SSL_CERT_FILE -- so give it the Nix CA bundle explicitly via
    # .wgetrc (otherwise every HTTPS fetch fails cert verification in the
    # sandbox). curl (fallback agent) is covered by SSL_CERT_FILE on the FOD.
    echo "ca_certificate = ${cacert}/etc/ssl/certs/ca-bundle.crt" > "$HOME/.wgetrc"
    export CT_PREFIX="$TMPDIR/x-tools"
    cd "$TMPDIR"
    # crosstool-NG refuses to run as UID 0; the Nix sandbox may use uid 0.
    # ct-ng itself only checks `id -u`; we cannot change that here, but the
    # nixbld build users are non-root so this is fine in practice.
    ct-ng "$sample"
  '';

  # Nix-fetched copies of tarballs whose primary downloads have actually
  # flaked on CI, for the canonical-set check in the `sources` derivation
  # below to fall back on. The bytes are pinned here AND digest-checked by
  # ct-ng against its bundled checksum for this exact filename, so seeding a
  # file can never change what a source set is supposed to contain -- it only
  # changes where the bytes come from.
  seedTarballs = [
    (fetchurl {
      # downloads.uclibc-ng.org intermittently refuses the .tar.xz to the CI
      # runners (the .tar.bz2 fallback then works seconds later, so it is not
      # plain downtime); this took out all seven uclibc sample legs in one
      # night. Same sha256 as packages/uClibc-ng/1.0.54/chksum in ct-ng.
      name = "uClibc-ng-1.0.54.tar.xz";
      url = "https://downloads.uclibc-ng.org/releases/1.0.54/uClibc-ng-1.0.54.tar.xz";
      hash = "sha256-0ez2XMIhfdQRik2vwavyfFhbXLV48715kfxkC3lkP/I=";
    })
    (fetchurl {
      # ftpmirror.gnu.org hands out a rotating mirror per request; one bad
      # mirror is enough for ct-ng to fall through to the .tar.bz2. Nix's
      # mirror://gnu tries a fixed list instead. Same sha256 as
      # packages/gmp/6.3.0/chksum in ct-ng.
      name = "gmp-6.3.0.tar.xz";
      url = "mirror://gnu/gmp/gmp-6.3.0.tar.xz";
      hash = "sha256-o8K4AgG4nmhhb0rTC8Zq7kknw85Q4zkpyoGdXENTiJg=";
    })
  ];

  # ct-ng funnels every sub-build's output into build.log and prints only a
  # short banner on stderr, so a failure otherwise gives you
  # "Build failed in step 'Building C library'" and nothing else -- the actual
  # compiler/download error dies with the sandbox. Dump the tail of the log so
  # CI failures are diagnosable.
  buildLogTail = ''
    echo "=================== ct-ng build.log (tail) ==================="
    tail -n 300 "$TMPDIR/build.log" 2>/dev/null || echo "(no build.log)"
    echo "================= end of ct-ng build.log ====================="
  '';
in

# `sample`  : the crosstool-NG sample id (== directory name under samples/)
# `sha256`  : the fixed-output hash of the downloaded tarball set
# `strip`   : strip the debug info out of the *target* libraries (step 1 of the
#             prune block in the toolchain buildCommand below). Defaults on; the
#             `.unstripped` passthru variant is the same toolchain with
#             `strip = false`, for anyone who wants full target DWARF locally.
#             The rest of the prune -- dropping dev-only tools, de-duplicating
#             the twice-installed binutils, and the before/after link probe --
#             runs either way, so `.unstripped` differs from the default build
#             in exactly the one thing its name promises.
# `localPatches`: per-sample source fixes, as { <ct-ng package name> = [ patch
#             files ]; }, applied through ct-ng's own local-patches mechanism
#             (CT_PATCH_ORDER="bundled,local") after its bundled set, whatever
#             version of that package the sample selects. Only the toolchain
#             derivation is affected: patching happens at extraction, so the
#             `sources` FOD and its pinned hash never move. See ./patch/ for
#             what each patch fixes and default.nix for who gets which.
# `configTweak`: bash run right after the sample is configured, in both
#             derivations' terms a toolchain-only concern (it runs only in the
#             toolchain build) -- for .config edits that patches can't express,
#             e.g. per-package configure flags. Keep it to seds over .config.
{ sample, sha256 ? lib.fakeHash, strip ? true, localPatches ? {}
, configTweak ? "" }:

let
  sanitized = sanitizeName sample;

  sources = stdenv.mkDerivation {
    name = "crosstool-ng-sources-${sanitized}";

    nativeBuildInputs = [ ctng ] ++ ctBuildInputs;

    dontUnpack = true;

    # Fixed-output derivation: network access is permitted, content is pinned.
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = sha256;

    # crosstool-NG fetches tarballs over HTTPS; the sandbox has no system trust
    # store, so point curl/wget at the Nix CA bundle.
    SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

    failureHook = buildLogTail;

    buildCommand = ''
      sample='${sample}'
      ${configureSample}

      # Download-only: fetch every source tarball into $out and stop.
      mkdir -p "$out"
      sed -i 's/# CT_ONLY_DOWNLOAD is not set/CT_ONLY_DOWNLOAD=y/' .config
      sed -i "s#^CT_LOCAL_TARBALLS_DIR=.*#CT_LOCAL_TARBALLS_DIR=\"$out\"#" .config
      grep -q '^CT_SAVE_TARBALLS=y' .config || echo 'CT_SAVE_TARBALLS=y' >> .config

      # ct-ng's downloader tries each archive format of a component in the
      # package's preference order and, within a format, every mirror. So a
      # flaky or geo-blocking mirror does not fail the fetch -- it silently
      # switches the set from e.g. uClibc-ng-1.0.54.tar.xz to the .tar.bz2 of
      # the very same release. Every byte is still digest-verified by ct-ng,
      # but the *set* no longer matches the pinned output hash; one night of
      # that took out seven toolchain legs. Since ct-ng carries a checksum for
      # every (component, format) pair, pinning the filenames back to the
      # preferred formats pins the bytes: this walks $out, finds each file's
      # package by its checksum entry, and demands the first format listed in
      # the package's descriptor that has a checksum. Anything else is deleted
      # so the retry loop can re-fetch it -- from a Nix-fetched seed copy when
      # we ship one (see seedTarballs above), from the mirrors otherwise.
      # (If a pin was ever *made* from a non-preferred format, this turns that
      # sample's nightly into a clear "non-canonical" failure instead of a
      # random hash mismatch -- fix by re-pinning, see ./pin-samples.sh.)
      pkgdb="${ctng}/share/crosstool-ng/packages"
      canonical_set() {
        local ok=0 f name chk fmts base want e
        for f in "$out"/*; do
          name="''${f##*/}"
          chk="$(grep -rlF "sha512 $name " "$pkgdb"/*/*/chksum 2>/dev/null \
                 | head -1)" || true
          [ -n "$chk" ] || continue     # no checksum entry: not ours to judge
          fmts="$(sed -n "s/^archive_formats='\(.*\)'$/\1/p" \
                    "''${chk%/*/chksum}/package.desc")"
          [ -n "$fmts" ] || continue
          base="$name"
          for e in $fmts; do base="''${base%"$e"}"; done
          want=""
          for e in $fmts; do
            if grep -qF "sha512 $base$e " "$chk"; then want="$base$e"; break; fi
          done
          [ -n "$want" ] && [ "$name" != "$want" ] || continue
          echo "=== non-canonical archive format: got $name, want $want" >&2
          rm -f "$f"
          case "$want" in
          ${lib.concatMapStrings (s: ''
            ${s.name}) cp ${s} "$out/${s.name}"
                         echo "    seeded the pinned copy of ${s.name}" >&2 ;;
          '') seedTarballs}
            *) echo "    no seed for $want; leaving it to the retry" >&2 ;;
          esac
          ok=1
        done
        return $ok
      }

      # Retry: the upstream mirrors occasionally hand back a truncated file (CI
      # runs a dozen of these concurrently), and ct-ng treats a digest mismatch
      # as fatal -- it deletes the bad tarball and aborts the whole download.
      # Tarballs already in $out are kept (canonical_set above prunes any that
      # came down in the wrong format), so a retry only re-fetches what failed.
      for attempt in 1 2 3; do
        if ct-ng build && canonical_set; then break; fi
        if [ "$attempt" = 3 ]; then
          echo "source download failed after 3 attempts" >&2
          exit 1
        fi
        echo "=== download attempt $attempt failed; retrying ===" >&2
        sleep 15
      done
    '';
  };

  # The toolchain proper. Parameterised on `strip` only: `sources` above is
  # shared verbatim by both variants, so the (expensive, network-fetching)
  # tarball download is never duplicated and its store path never moves.
  mkTc = { strip }: stdenv.mkDerivation {
    pname = "crosstool-ng-${sanitized}" + lib.optionalString (!strip) "-unstripped";
    version = ctng.version;

    nativeBuildInputs = [ ctng ] ++ ctBuildInputs;

    dontUnpack = true;

    # The Nix stdenv enables hardening flags by default (via the cc-wrapper),
    # notably format hardening (-Werror=format-security). That breaks building
    # gcc/binutils/newlib themselves (e.g. gcc-16's libcpp/expr.cc). A toolchain
    # build must drive the host compiler without these injected flags, so turn
    # hardening off for this derivation.
    hardeningDisable = [ "all" ];

    # `.unstripped` is the same build with step 1 of the prune switched off, so
    # a developer who needs target DWARF can `nix build .#crosstool-ng-<name>.unstripped`
    # without editing anything. It still gets steps 2-4 and, importantly, the
    # same before/after link probe, so the escape hatch is not an untested code
    # path. The `optionalAttrs strip` guard is what makes this terminate: the
    # recursive call is `mkTc { strip = false; }`, and for that derivation the
    # guard is false, so it gets no `unstripped` attribute of its own and the
    # recursion stops one level down. (Nix's laziness alone would not save us --
    # an unguarded `unstripped = mkTc { strip = ... }` would still be an
    # infinite chain the moment anything traversed it, as `nix flake show` and
    # `nix search` do.)
    passthru = { inherit sample sanitized sources; }
      // lib.optionalAttrs strip { unstripped = mkTc { strip = false; }; };

    failureHook = buildLogTail;

    buildCommand = ''
      sample='${sample}'
      ${configureSample}

      # Offline build: forbid any download, take tarballs from the pinned FOD.
      sed -i 's/# CT_FORBID_DOWNLOAD is not set/CT_FORBID_DOWNLOAD=y/' .config
      sed -i "s#^CT_LOCAL_TARBALLS_DIR=.*#CT_LOCAL_TARBALLS_DIR=\"${sources}\"#" .config
      sed -i 's/^CT_SAVE_TARBALLS=y/# CT_SAVE_TARBALLS is not set/' .config
      # Don't chmod the install tree read-only; we still need to copy it to $out.
      sed -i 's/^CT_PREFIX_DIR_RO=y/# CT_PREFIX_DIR_RO is not set/' .config
      sed -i 's/^CT_INSTALL_DIR_RO=y/# CT_INSTALL_DIR_RO is not set/' .config
    ''
      + lib.optionalString (localPatches != {}) ''

      # Per-sample source fixes, routed through ct-ng's own local-patches
      # mechanism: with CT_PATCH_ORDER="bundled,local", ct-ng applies
      # $CT_LOCAL_PATCH_DIR/<package>/*.patch right after its bundled set for
      # that package -- the un-versioned <package>/ directory applies to
      # whichever version the sample selects. Extraction happens only in this
      # derivation, so the sources FOD and its pinned hash are unaffected.
      ${lib.concatStrings (lib.mapAttrsToList (pkg: patches: ''
      mkdir -p "$TMPDIR/local-patches/${pkg}"
      ${lib.concatMapStrings (p: ''
      cp ${p} "$TMPDIR/local-patches/${pkg}/${baseNameOf (toString p)}"
      '') patches}'') localPatches)}
      sed -i 's/^CT_PATCH_ORDER="bundled"$/CT_PATCH_ORDER="bundled,local"/' .config
      grep -q '^CT_PATCH_ORDER="bundled,local"$' .config   # the sed must land
      echo "CT_LOCAL_PATCH_DIR=\"$TMPDIR/local-patches\"" >> .config
    ''
      + lib.optionalString (configTweak != "") ''

      ${configTweak}
    ''
      + ''

      ct-ng build

      # ct-ng installs into $CT_PREFIX/<target-triple>. Promote that tree to
      # $out so the cross compilers land in $out/bin.
      target="$(ls "$CT_PREFIX")"
      mkdir -p "$out"
      cp -a "$CT_PREFIX/$target/." "$out/"
      chmod -R u+w "$out"
    '' + ''

      # ======================================================================
      # Prune: shrink the installed tree without changing what it can do.
      #
      # crosstool-NG strips the *host* executables it installs but never the
      # *target* side, so every libc.a / libstdc++.a / libgcc.a ships full
      # DWARF. Multilib multiplies that: arm-none-eabi builds 30 library
      # variants and lands at 3.5GB, 3479MB of which is .a files. With a 5GB
      # Cachix cache and a 111-toolchain fleet needing 12.78GB, the cache
      # evicts constantly and CI rebuilds about half the fleet every night.
      #
      # Measured by running exactly this block over the two extremes of the
      # fleet (raw = `du -sm`, compressed = `tar cf - . | zstd -3 | wc -c`,
      # which is what the cache actually pays for):
      #   aarch64-rpi3 (glibc, single-lib)
      #     488MB raw / 153.7MB zstd-3 -> 313MB raw /  99.5MB  (35% off)
      #   arm-none-eabi (bare metal, 30 multilib variants)
      #     3547MB raw / 838.5MB zstd-3 -> 727MB raw / 152.5MB  (82% off)
      #
      # Everything here is runtime-neutral: nothing that affects compiling,
      # linking or running target code is removed.
      #
      # NOT done, deliberately: the target locale data (sysroot usr/lib/gconv,
      # usr/share/i18n, usr/share/locale) is another few hundred MB and is
      # tempting, but `qemu-user -L <sysroot>` is a standard way to run
      # cross-compiled binaries, which makes the sysroot a *runtime* root.
      # Deleting the 255 gconv modules breaks iconv() and setlocale() for
      # anything run that way. Do not add it back.
      # ======================================================================

      # ---------------------------------------------------------------- probe
      # A prune bug can produce a toolchain that still looks fine (right files,
      # right sizes) but cannot link at all -- see the host/target strip hazard
      # below. So: compile+link a trivial program before pruning and again
      # after, and fail on a before->after *regression*.
      #
      # The fleet is heterogeneous (bare metal, mingw, bpf, picolibc, ancient
      # ports, some with no sysroot at all), so a single fixed command line
      # cannot possibly work everywhere. Instead we walk a ladder of flag sets
      # from most to least demanding and take the first rung that yields an
      # output file; the last rung is compile-only, which any working gcc can
      # do.
      #
      # *** The rung NUMBER is the result, not "did any rung pass". *** Rung 4
      # is `-c`, which never invokes ld, so every link-time breakage this prune
      # can cause -- a corrupted liblto_plugin.so, a gutted libgcc.a -- falls
      # through to it and a pass/fail probe reports "ok". Comparing rungs makes
      # "linked before, only compiles after" (1 -> 4) the hard error it is,
      # while a target that was already compile-only stays tolerated: that is a
      # pre-existing property of the target, not a regression from the prune.
      #
      # prune_probe <label> <compiler> <source>: prints the rung it succeeded
      # on, or 99 for "not even compile-only" / compiler absent. Everything
      # else goes to stderr so the caller can capture just the number.
      prune_probe() {
        local label="$1" cc="$2" src="$3" name
        name="''${2##*/}"
        if [ ! -x "$cc" ]; then
          echo "  probe ($label, $name): not present in \$out/bin; skipping" >&2
          echo 99
          return 0
        fi
        local dir="$TMPDIR/prune-probe-$label-$name"
        rm -rf "$dir"
        mkdir -p "$dir"
        local rung n=0
        for rung in "" "--specs=nosys.specs" "-nostdlib -nostartfiles" "-c"; do
          n=$((n + 1))
          rm -f "$dir/probe.out"
          # $rung is intentionally unquoted: it carries multiple flags.
          if "$cc" $rung "$src" -o "$dir/probe.out" \
               > "$dir/rung$n.log" 2>&1 && [ -s "$dir/probe.out" ]; then
            echo "  probe ($label, $name): ok on rung $n [$name $rung]" >&2
            echo "$n"
            return 0
          fi
        done
        echo "  probe ($label, $name): every rung failed; tail of the last one:" >&2
        tail -n 20 "$dir/rung$n.log" | sed 's/^/    /' >&2
        echo 99
        return 0
      }

      # A trivial main() can still link while an archive we stripped has been
      # mangled, so check a handful of representative archives too: `ar t`
      # walks the member headers and `nm -s` needs a live armap. Comparative
      # again -- we require that no archive that was readable before the prune
      # has become unreadable.
      probe_arcs="$TMPDIR/prune-probe-archives"
      : > "$probe_arcs"
      for a in "$out"/lib/gcc/"$target"/*/libgcc.a \
               "$out/$target/lib/libc.a" "$out/$target/lib/libstdc++.a" \
               "$out/$target/sysroot/usr/lib/libc.a" \
               "$out/$target/sysroot/usr/lib/libstdc++.a"; do
        if [ -f "$a" ]; then printf '%s\n' "$a" >> "$probe_arcs"; fi
      done
      prune_probe_ar() {
        local label="$1" ar="$out/bin/$target-ar" nm="$out/bin/$target-nm" a n=0
        if [ ! -x "$ar" ] || [ ! -x "$nm" ]; then echo 0; return 0; fi
        while IFS= read -r a; do
          if "$ar" t "$a" > /dev/null 2>&1 && "$nm" -s "$a" > /dev/null 2>&1; then
            n=$((n + 1))
          fi
        done < "$probe_arcs"
        echo "  archives ($label): $n of $(wc -l < "$probe_arcs") readable" >&2
        echo "$n"
      }

      probe_src_c="$TMPDIR/prune-probe.c"
      probe_src_cxx="$TMPDIR/prune-probe.cc"
      printf 'int main(void){return 0;}\n' > "$probe_src_c"
      printf 'struct P { int v; };\nint main(){ P p{0}; return p.v; }\n' > "$probe_src_cxx"

      echo "=== prune: probing the toolchain before pruning ==="
      cc_before=$(prune_probe before "$out/bin/$target-gcc" "$probe_src_c")
      cxx_before=$(prune_probe before "$out/bin/$target-g++" "$probe_src_cxx")
      ar_before=$(prune_probe_ar before)

      # --------------------------------------------- 1. strip target debug info
      # --strip-debug, NOT a full strip: the symbol tables have to survive or
      # linking against these archives breaks outright, and target backtraces
      # stop resolving names. (--strip-debug also drops GCC's .gnu.lto_*
      # sections, so an archive built as LTO IR would be gutted. ct-ng does not
      # build the target libraries with -flto in any pinned sample; if one ever
      # does, the C rung of the probe above regresses and the build fails.)
      #
      # *** Which files reach $target-strip is a safety constraint. ***
      # A toolchain tree mixes host x86_64 objects in with the target ones, and
      # running the *target's* strip over a host object does not fail -- it
      # silently rewrites the ELF header's e_machine to "no machine", after
      # which liblto_plugin.so can no longer be loaded and every single link
      # dies with "error loading plugin ...: cannot open shared object file".
      # This mistake has already been made here once by hand.
      #
      # Directory names cannot express that boundary, so do not try: even
      # $out/lib/gcc, which looks target-side by definition, holds host shared
      # objects at lib/gcc/<triple>/<ver>/plugin/lib{cc1,cp1}plugin.so.0.0.0
      # (GDB's `compile` plugins) that match '*.so.*'. The rule enforced here
      # is per-file instead: read the ELF machine of a known-good target object
      # once, then hand strip only the files that report exactly that machine.
      # That is what makes it safe to point the find at whole target prefixes,
      # which in turn is what makes the strip worth doing -- ct-ng only creates
      # <triple>/sysroot for hosted libcs (glibc/uclibc/musl). Bare metal has
      # no sysroot at all: newlib puts the libraries in <triple>/lib and ships
      # a second prefix next to it ($out/newlib-nano is 1.6GB of the 3.5GB on
      # arm-none-eabi). Restricted to sysroot + lib/gcc, this step reached 373
      # of arm-none-eabi's 3321MB of target archives -- 11%.
      strip_bin="$out/bin/$target-strip"
      readelf_bin="$out/bin/$target-readelf"
    ''
      + lib.optionalString (!strip) ''
      # `.unstripped` variant: keep the target DWARF, run the rest of the prune.
      strip_bin=""
      echo "=== prune: keeping target debug info (unstripped variant) ==="
    ''
      + ''
      if [ -z "$strip_bin" ]; then
        :
      elif [ ! -x "$strip_bin" ] || [ ! -x "$readelf_bin" ]; then
        # Fail closed: without readelf we cannot tell host objects from target
        # ones, and guessing is how the e_machine corruption happened.
        echo "=== prune: no $target-strip or $target-readelf; skipping the debug-info strip ==="
      else
        # e_machine of an ELF file, or of the first member of an archive;
        # empty for anything that is not ELF. readelf rather than objdump on
        # purpose: readelf decodes the raw header, so it reports the true
        # machine even for a format this binutils has no BFD support for --
        # exactly the files that must not be stripped. (objdump would answer
        # "UNKNOWN!" for those, but it also answers with the specific CPU
        # variant -- armv7 vs armv8-m.main -- for target objects that all share
        # one e_machine, so it cannot be compared against a single reference.)
        # The sed quits at the first match, which SIGPIPEs readelf out of a
        # multi-thousand-member archive instead of letting it walk the lot.
        elf_machine() {
          "$readelf_bin" -h "$1" 2>/dev/null \
            | sed -n '/Machine:/{s/.*Machine: *//;s/ *$//;p;q}' || true
        }

        strip_roots=()
        if [ -d "$out/lib/gcc" ]; then strip_roots+=("$out/lib/gcc"); fi
        # Every top-level directory that is a target prefix: $out/<triple>
        # (sysroot when there is one, <triple>/lib when there is not) plus any
        # sibling libc prefix such as $out/newlib-nano. $out/lib itself is
        # deliberately NOT a root -- it holds host objects (bfd-plugins/
        # liblto_plugin.so, lib64/libcc1.so) -- but $out/lib/gcc above is.
        for d in "$out"/*/; do
          d="''${d%/}"
          case "''${d##*/}" in
            bin|libexec|share|include|lib|lib32|lib64|libx32) continue ;;
          esac
          strip_roots+=("$d")
        done

        # The reference target object. crt*.o / libgcc.a / libc.a are built by
        # the toolchain for the toolchain's own target by definition; the
        # plugin directory is excluded because that is where the host objects
        # that motivated all this live.
        ref_src=""
        for d in "''${strip_roots[@]}"; do
          ref_src="$(find "$d" -type f -not -path '*/plugin/*' \
                       \( -name 'crt*.o' -o -name 'libgcc.a' -o -name 'libc.a' \) \
                       -print -quit)"
          if [ -n "$ref_src" ]; then break; fi
        done

        if [ "''${#strip_roots[@]}" -eq 0 ] || [ -z "$ref_src" ]; then
          echo "=== prune: no target objects found under $out; nothing to strip ==="
        else
          ref_machine="$(elf_machine "$ref_src")"
          echo "=== prune: stripping target debug info in ''${strip_roots[*]} ==="
          if [ -n "$ref_machine" ]; then
            echo "  target machine is \"$ref_machine\" (per ''${ref_src#$out/})"
          else
            # mingw and friends: the target objects are PE/COFF, not ELF. The
            # comparison below then keeps exactly the non-ELF files, which is
            # the right answer -- the host objects mixed in are all ELF.
            echo "  target objects are not ELF (per ''${ref_src#$out/}); ELF files will be left alone"
          fi
          if [ ! -d "$out/$target/sysroot" ]; then
            echo "  note: no $target/sysroot -- bare-metal layout, target libs expected under $target/lib"
          fi
          strip_ok=0
          strip_skip=0
          strip_host=0
          while IFS= read -r -d "" f; do
            # Per-file rather than a batched xargs: every file has to be
            # machine-checked first, and the answer splits three ways.
            fm="$(elf_machine "$f")"
            if [ -n "$fm" ] && [ "$fm" != "$ref_machine" ]; then
              # A host (or otherwise foreign) object that happened to live in a
              # target tree. THIS is the file that must never reach strip.
              strip_host=$((strip_host + 1))
              printf '  foreign object (%s), left alone: %s\n' "$fm" "''${f#$out/}"
              continue
            fi
            if [ "$fm" != "$ref_machine" ]; then
              # Not an ELF and not what the target's own objects look like:
              # glibc installs sysroot/usr/lib/libc.so as an ASCII linker
              # script and libpthread.a etc. as empty archives, some ports ship
              # *.o stubs that are really scripts. Nothing to strip in any of
              # them, and strip would only answer "file format not recognized".
              strip_skip=$((strip_skip + 1))
              printf '  no target objects in: %s\n' "''${f#$out/}"
              continue
            fi
            if "$strip_bin" --strip-debug "$f" 2> "$TMPDIR/strip.err"; then
              strip_ok=$((strip_ok + 1))
            else
              # A real strip failure on a file we positively identified as
              # target-side. Report it rather than swallowing it.
              strip_skip=$((strip_skip + 1))
              printf '  not stripped: %s (%s)\n' \
                "''${f#$out/}" "$(tr '\n' ' ' < "$TMPDIR/strip.err")"
            fi
          done < <(find "''${strip_roots[@]}" -type f \
                        \( -name '*.a' -o -name '*.o' \
                           -o -name '*.so' -o -name '*.so.*' \) -print0)
          echo "  stripped $strip_ok file(s), skipped $strip_skip with no target" \
               "objects, left $strip_host foreign object(s) alone"
          # Residual size of the target archives, so that a fleet-wide
          # regression in *coverage* (which no probe can catch, because
          # under-stripping is not a functional failure) is visible in the log
          # rather than inferred from the cache bill months later.
          echo "  target archives now total $(find "$out" -type f -name '*.a' \
                 -printf '%s\n' | awk '{ s += $1 } END { printf "%d", s / 1048576 }')MB"
        fi
      fi

      # ------------------------------------------------ 2. drop dev-only tools
      # lto-dump is a 33-43MB GCC development tool for dumping the internals of
      # LTO object files. It is NOT part of the LTO pipeline -- lto1,
      # lto-wrapper and liblto_plugin.so all stay, and -flto was verified to
      # still work without it. build.log.bz2 is ct-ng's own build transcript.
      echo "=== prune: removing lto-dump and the ct-ng build log ==="
      rm -f "$out"/bin/*-lto-dump "$out/$target/bin/lto-dump" "$out/build.log.bz2"

      # ------------------------------------- 3. de-duplicate the binutils copies
      # binutils is installed twice, under both prefixes: $out/bin/$target-ld
      # and $out/$target/bin/ld are byte-identical, and so are as, objdump, nm,
      # ar, ranlib and strip. On a normal install these would be hard links and
      # cost nothing -- but NAR, the archive format Nix uses for the binary
      # cache, has no concept of a hard link, so every copy is serialised in
      # full and the cache pays for each one. NAR *does* represent symlinks, so
      # replacing the duplicates with relative symlinks is the fix: 16 files /
      # 30MB of NAR on aarch64-rpi3, 94 files / 76MB on multilib arm-none-eabi.
      #
      # Relative (ln -r), not absolute: the link then survives anything that
      # relocates or copies the tree wholesale.
      #
      # Unlike step 1 this deliberately covers all of $out including $out/bin,
      # since that is where the duplicates are. It is safe there in a way that
      # stripping is not: the surviving file is byte-for-byte the one that was
      # removed. That does mean the rule is content-general rather than
      # binutils-specific, and it catches the GCC drivers too --
      # $out/bin/<triple>-g++ becomes a link to <triple>-c++, and
      # <triple>-gcc-<ver> to <triple>-gcc. That is fine because GCC computes
      # its exec prefix from argv[0] and PATH (libiberty's make_relative_prefix)
      # rather than from realpath(/proc/self/exe), so the indirection is
      # invisible to -print-prog-name and friends; both C and C++ rungs of the
      # probe below run after this step and would catch it if a future driver
      # ever did resolve its own path.
      #
      # Two constraints on which copy survives:
      #   * $out/bin wins. "$out/bin/<triple>-ld" and "$out/<triple>/bin/ld"
      #     are always the *same length*, so a pure length sort leaves the
      #     choice to the lexical tiebreak of "bin" against the triple -- which
      #     silently flips halfway through the alphabet and turns the
      #     user-facing $out/bin entries into links for every target sorting
      #     before "b". Rank $out/bin first and the outcome is the same on
      #     every target, and anything that copies $out/bin alone still works.
      #   * No link crosses the sysroot boundary. The "NOT done" note at the top
      #     of this block treats the sysroot as a runtime root (`qemu-user -L
      #     <sysroot>`); a relative link from inside it to a duplicate outside
      #     would resolve here but dangle the moment the sysroot is extracted or
      #     bind-mounted on its own. In practice nothing has ever crossed it --
      #     the counter is a tripwire, not a workaround.
      echo "=== prune: replacing duplicate files >=64KiB with relative symlinks ==="
      dup_plan="$TMPDIR/prune-dup-plan"
      # Sort candidates by rank, then path length, then lexically (to stay
      # deterministic) *before* hashing, so the first file seen in each group
      # of identical files is the one to keep. That one stays real and every
      # later one becomes a link to it -- which also means a kept file is never
      # itself demoted later, so no symlink this step creates ever points at
      # another symlink.
      find "$out" -type f -size +63k -printf '%s\t%p\n' \
        | awk -F'\t' -v bindir="$out/bin/" \
            '$1 >= 65536 { print (index($2, bindir) == 1 ? 0 : 1) "\t" \
                                 length($2) "\t" $2 }' \
        | sort -t $'\t' -k1,1n -k2,2n -k3,3 \
        | cut -f3- \
        | tr '\n' '\0' \
        | xargs -0 -r sha256sum -- \
        | awk '{ h = $1; sub(/^[^ ]+  /, "");
                 if (h in keep) print $0 "\t" keep[h]; else keep[h] = $0 }' \
        > "$dup_plan"
      dup_n=0
      dup_kib=0
      dup_cross=0
      sysroot="$out/$target/sysroot"
      while IFS=$'\t' read -r dup orig; do
        [ -f "$dup" ] && [ -f "$orig" ] || continue
        in_dup=0
        in_orig=0
        case "$dup" in "$sysroot"/*) in_dup=1 ;; esac
        case "$orig" in "$sysroot"/*) in_orig=1 ;; esac
        if [ "$in_dup" != "$in_orig" ]; then
          dup_cross=$((dup_cross + 1))
          continue
        fi
        dup_kib=$((dup_kib + $(stat -c %s "$dup") / 1024))
        rm -f "$dup"
        ln -s -r -- "$orig" "$dup"
        dup_n=$((dup_n + 1))
      done < "$dup_plan"
      echo "  linked $dup_n duplicate(s), $dup_kib KiB of uncompressed NAR" \
           "($dup_cross left alone to keep the sysroot self-contained)"

      # ------------------------------------------------------------- verdict
      echo "=== prune: probing the toolchain after pruning ==="
      cc_after=$(prune_probe after "$out/bin/$target-gcc" "$probe_src_c")
      cxx_after=$(prune_probe after "$out/bin/$target-g++" "$probe_src_cxx")
      ar_after=$(prune_probe_ar after)
      prune_failed=0
      if [ "$cc_after" -gt "$cc_before" ]; then
        echo "ERROR: C probe regressed from rung $cc_before to rung $cc_after." >&2
        prune_failed=1
      fi
      if [ "$cxx_after" -gt "$cxx_before" ]; then
        echo "ERROR: C++ probe regressed from rung $cxx_before to rung $cxx_after." >&2
        prune_failed=1
      fi
      if [ "$ar_after" -lt "$ar_before" ]; then
        echo "ERROR: $ar_before target archive(s) were readable before the prune," \
             "only $ar_after after." >&2
        prune_failed=1
      fi
      if [ "$prune_failed" = 1 ]; then
        echo "This toolchain could do more before pruning than after -- the" >&2
        echo "prune broke it. Refusing to install." >&2
        exit 1
      fi
      if [ "$cc_before" = 99 ]; then
        echo "note: this toolchain already failed every C probe rung before" \
             "pruning; treating that as a pre-existing property of the target," \
             "not a regression."
      fi
    '';

    meta = with lib; {
      description = "crosstool-NG sample cross toolchain: ${sample}"
        + lib.optionalString (!strip) " (with target debug info kept)";
      homepage = "https://crosstool-ng.github.io/";
      license = licenses.gpl2Plus;
      platforms = platforms.linux;
    };
  };
in
mkTc { inherit strip; }
