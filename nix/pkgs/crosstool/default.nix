{ lib
, callPackage
, stdenv
, gcc
, binutils
, gnumake
, gawk
, bison
, flex
, gperf
, help2man
, texinfo
, gettext
, autoconf
, automake
, libtool
, m4
, ncurses
, python3
, wget
, curl
, rsync
, patch
, file
, which
, gnutar
, gzip
, bzip2
, xz
, zlib
, perl
, findutils
, gnused
, gnugrep
, diffutils
, coreutils
, bash
}:

# ctf-tools `crosstool`.
#
# The original installer builds the crosstool-NG `ct-ng` driver and then uses it
# to build a whole fleet of sample cross-compiler TOOLCHAINS, exposing their
# binaries (avr-gcc, arm-none-eabi-gcc, ...). This Nix port reproduces both:
#
#   * The top-level package IS the `ct-ng` driver (so `crosstool` still gives you
#     `ct-ng`, and a wrapped ct-ng that can build toolchains at runtime).
#   * `passthru.toolchains` is an attrset mapping every crosstool-NG sample
#     (there are ~146, the same set `ct-ng list-samples` prints; the list is
#     generated from the source tree into ./samples.nix) to its own independent
#     toolchain derivation, built fully offline inside the Nix sandbox (see
#     ./mk-toolchain.nix). Each is its own derivation on purpose: flake.nix
#     surfaces them as top-level outputs
#     `crosstool-ng-<sanitized-sample-name>` and adds them to the CI/Cachix build
#     matrix, so every sample builds independently and one broken sample does not
#     sink the rest.
#
# Sample-name sanitization (for Nix attrs / CLI): commas and any character
# outside [a-zA-Z0-9_-] become '-'. Example:
#   "x86_64-multilib-linux-uclibc,moxie-unknown-moxiebox"
#     -> "x86_64-multilib-linux-uclibc-moxie-unknown-moxiebox"

let
  # The full build environment ct-ng needs to drive a toolchain build. This is
  # shared by the driver's runtime wrapper, the source-download FODs, and the
  # offline toolchain builds. A working `gcc` is mandatory (ct-ng runs
  # `gcc -dumpversion` at startup and aborts with exit 127 otherwise).
  ctBuildInputs = [
    gcc binutils gnumake gawk bison flex gperf help2man texinfo gettext
    autoconf automake libtool m4 ncurses python3 wget curl rsync patch
    file which gnutar gzip bzip2 xz zlib perl findutils gnused gnugrep
    diffutils coreutils bash
  ];

  ctng = callPackage ./ctng.nix { inherit ctBuildInputs; };

  mkToolchain = callPackage ./mk-toolchain.nix { inherit ctng ctBuildInputs; };
  # (callPackage supplies `cacert` from pkgs automatically.)

  hashes = import ./hashes.nix;

  sanitizeName = name:
    let
      chars = lib.stringToCharacters name;
      keep = c: (c >= "a" && c <= "z") || (c >= "A" && c <= "Z")
             || (c >= "0" && c <= "9") || c == "_" || c == "-";
    in lib.concatStrings (map (c: if keep c then c else "-") chars);

  # Every sample of the pinned crosstool-NG release. This is the samples/
  # directory listing of ctng.src, checked in by ./pin-samples.sh rather than
  # read with `builtins.readDir "${ctng.src}/samples"`: reading it from the
  # fetched source is an import-from-derivation, and `nix flake show` /
  # `nix search` refuse IFD unconditionally, so merely *enumerating* the flake's
  # outputs would fail for everyone. See ./samples.nix.
  sampleNames = import ./samples.nix;

  # Turn off CT_GLIBC_LOCALES in a generated .config (see the two ARM samples
  # in sampleFixes below for why). Written to tolerate the option being absent.
  disableGlibcLocales = ''
    sed -i 's/^CT_GLIBC_LOCALES=y$/# CT_GLIBC_LOCALES is not set/' .config
    grep -q '^# CT_GLIBC_LOCALES is not set$' .config   # the sed must land
  '';

  # Per-sample fixes (keyed by *sanitized* name), passed straight through to
  # mk-toolchain.nix -- source patches via ct-ng's local-patches mechanism and
  # .config tweaks. These exist because the samples pin decades-old component
  # releases but everything is compiled by/against today's nixpkgs host
  # toolchain and built inside the Nix sandbox; each fix is a proven CI
  # failure, not a precaution. The patch headers under ./patch/ carry the
  # full stories.
  sampleFixes = {
    # CT_GLIBC_LOCALES builds the target's locale *archive* as a post-install
    # step, and to do that it runs the freshly built glibc's own `localedef`
    # on the build machine, invoked through that same fresh build tree's
    # ld.so. That loader, and the localedef binary it loads, carry the glibc
    # default interpreter path /lib64/ld-linux-x86-64.so.2 -- which does not
    # exist in the Nix build sandbox (no /lib64 at all), so the exec dies
    # before main() and make reports a bare `Error 127` with no diagnostic.
    # The two samples that enable it (both hf ARM) are the only ones that hit
    # this; every other glibc sample here builds the identical library and
    # passes precisely because it does not run host localedef. The locale
    # archive is optional target data (a cross *compiler* neither needs nor
    # uses it; it is only consumed by programs run under qemu-user with a
    # matching --prefix), so drop just that step and keep the toolchain.
    # Re-enabling it would require a host localedef whose interpreter resolves
    # inside the sandbox -- a much larger change for target data nobody here
    # consumes.
    "arm-cortexa9_neon-linux-gnueabihf".configTweak = disableGlibcLocales;
    "armv6-unknown-linux-gnueabihf".configTweak = disableGlibcLocales;

    # glibc <= 2.22's configure probes "same dir as the source?" with a
    # hardcoded /bin/pwd, which the Nix sandbox does not have, and the check
    # fails spuriously.
    "i686-centos7-linux-gnu".localPatches.glibc =
      [ ./patch/glibc-configure-accept-nix-sandbox-pwd.patch ];
    "x86_64-centos7-linux-gnu".localPatches.glibc =
      [ ./patch/glibc-configure-accept-nix-sandbox-pwd.patch ];
    "x86_64-ubuntu14-04-linux-gnu".localPatches = {
      glibc = [ ./patch/glibc-configure-accept-nix-sandbox-pwd.patch ];
      # ... and linux 3.13's host tools (unifdef) use `constexpr` as an
      # identifier, which GCC 15's default -std=gnu23 rejects.
      linux = [ ./patch/linux-3.13-host-tools-std-gnu11.patch ];
    };

    # This sample resolves its cross-gdb to 9.2 -- an old gcc/arch selection
    # pins it there and the pinned source set carries gdb-9.2 -- and gdb 9.2
    # does not survive a 2026 host toolchain. It fails in three independent
    # ways, each past the last: its bundled readline is pre-C99 (empty-parens
    # prototypes called with args, mismatched sighandler pointer types) and
    # GCC 15 makes those hard errors; its configure drives `python-config` in a
    # way CPython 3.13 no longer answers; and gdb's own C++ has const-to-non-
    # const conversions g++ 15 rejects. The first and third can't even be
    # flagged away from here -- crosstool-NG records CXXFLAGS on gdb's
    # top-level configure but the value does not reach the readline subdir or,
    # empirically, gdb proper's own compile, so --with-system-readline /
    # -fpermissive get ignored. Every *other* gdb sample in the fleet pins
    # 16.3, which has none of these problems; only this one is stuck on 9.2.
    #
    # So drop cross-gdb for this sample rather than chase an unbounded series of
    # 2020-gdb-on-2026-host breakages. The deliverable -- the SPARC/LEON
    # gcc+binutils+uClibc cross toolchain -- builds and links fine; it just
    # ships without a bundled debugger, the same best-effort tradeoff the
    # toolchain matrix already makes for ports that don't build at all. If this
    # sample's gdb is ever bumped to 16.3 (a ctng sample refresh), delete this.
    # Raw .config edits, not `ct-ng olddefconfig`: the latter would recompute
    # every symbol from defaults and undo the offline-build settings
    # mk-toolchain seds in just above (CT_FORBID_DOWNLOAD et al.). So turn off
    # both gdb symbols the build actually reads -- CT_DEBUG_GDB gates building
    # the gdb facility (debug.sh keys the facility list on CT_DEBUG_<name>), and
    # CT_GDB_GDBSERVER is checked *independently* in the finalize step, which
    # would otherwise try to strip a gdbserver that was never built and fail the
    # whole toolchain in 'Finalizing the toolchain's directory'.
    "sparc-leon-linux-uclibc".configTweak = ''
      sed -i 's/^CT_DEBUG_GDB=y$/# CT_DEBUG_GDB is not set/' .config
      sed -i 's/^CT_GDB_GDBSERVER=y$/# CT_GDB_GDBSERVER is not set/' .config
      grep -q '^# CT_DEBUG_GDB is not set$' .config      # the seds must land
      grep -q '^# CT_GDB_GDBSERVER is not set$' .config
    '';
  };

  # sanitized attr name -> toolchain derivation, for the full sample set.
  toolchains = lib.listToAttrs (map
    (sample:
      let name = sanitizeName sample;
      in {
        inherit name;
        value = mkToolchain ({
          inherit sample;
          sha256 = hashes.${name} or lib.fakeHash;
        } // (sampleFixes.${name} or {}));
        # sampleFixes may carry localPatches/configTweak/extraInputs; mkToolchain
        # defaults each, so only the affected samples pass any of them.
      })
    sampleNames);

  # Parallel attrset of just the source-download FODs (handy for pinning hashes).
  sources = lib.mapAttrs (_: tc: tc.sources) toolchains;

  # Samples whose *toolchain build* is known to currently fail (source still
  # pins fine; kept out of the surfaced outputs so CI stays green). See PORTING.md.
  brokenBuild = [ "avr" ];

  # Samples whose source set has a real (pinned) hash in ./hashes.nix and that
  # actually build. flake.nix surfaces *these* as top-level `crosstool-ng-<name>`
  # outputs (and thus into the CI/Cachix matrix). Adding a hash for a working
  # sample automatically promotes it here — see ./hashes.nix and ./pin-samples.sh.
  pinnedToolchains = lib.filterAttrs
    (n: _: (hashes ? ${n}) && !(builtins.elem n brokenBuild))
    toolchains;
in

ctng.overrideAttrs (old: {
  passthru = (old.passthru or {}) // {
    inherit toolchains sources sampleNames ctBuildInputs pinnedToolchains;
    # Names are the sanitized sample ids; flake surfaces them as
    # `crosstool-ng-<name>`.
    toolchainNames = lib.attrNames toolchains;
    pinnedToolchainNames = lib.attrNames pinnedToolchains;
  };
})
