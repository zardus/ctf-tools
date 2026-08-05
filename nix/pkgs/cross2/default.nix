{ lib
, callPackage
, symlinkJoin
, fetchurl
  # Accepted for interface-compatibility with the flake's callPackage (which
  # offers the Python-2 package set to every tool); cross2 does not use it.
, pkgsPy2 ? null
}:

# `cross2` from ctf-tools is the companion toolchain builder for the Japanese
# assembly-language book at kozos.jp. Upstream downloads cross2-20130826.tgz and
# runs build/build-install-all.sh, which builds binutils-2.21.1 -> gcc-3.4.6
# (combined-tree with newlib-1.20.0, hosted C library) -> gdb-7.3.1 for a large
# fleet of bare-metal ELF targets.
#
# Rather than one monolithic derivation (too heavy for a single CI runner), each
# target is its OWN derivation (see ./mk-target.nix), exactly like the crosstool
# per-sample toolchains: flake.nix surfaces them as `cross2-<target>` outputs and
# the toolchains CI matrix builds each independently. The `cross2` output here is
# a convenience bundle of the "major architecture" toolchains.
#
# gcc-3.4.6 (2006) only builds with a pre-14 gcc, so mk-target uses gcc13Stdenv
# with hardening disabled. Language set / newlib / gdb mode per target come
# verbatim from build/{gcc,gdb}/targets.sh.

let
  # Byte-stable mirror of the kozos.jp cross2 tarballs. kozos re-gzips its .tar.gz
  # on every request, so a fixed-output hash on those URLs is non-deterministic
  # (CI fetches a differently-compressed but identical-content file and the FOD
  # fails). These GitHub-release copies are byte-stable. (binutils is .tar.bz2 and
  # was already stable; mirrored too for consistency.)
  base = "https://github.com/zardus/ctf-tools/releases/download/cross2-sources-20130826";
  binutilsSrc = fetchurl { url = "${base}/binutils-2.21.1.tar.bz2"; sha256 = "sha256-zez6afAqp7BfvN9njjMTcVHzYTE7Lz5Iq6kl9k6r9lQ="; };
  gccSrc      = fetchurl { url = "${base}/gcc-3.4.6.tar.gz";        sha256 = "sha256-QbJVEKz6Dvu5QRr6NU/tX5RlmtefNh3/7DBo0tPtzUQ="; };
  newlibSrc   = fetchurl { url = "${base}/newlib-1.20.0.tar.gz";    sha256 = "sha256-xkSyhHJEJ4xXvsLd2mnY+rWnx2fzua9pqnqj2oI/9pI="; };
  gdbSrc      = fetchurl { url = "${base}/gdb-7.3.1.tar.gz";        sha256 = "sha256-19kJtLiuCTK6bBYC8vHzK+9g8McccvHdgzq2yxXg01c="; };

  allTargets = import ./targets.nix;

  # Per-target build recipe, from build/{gcc,gdb}/targets.sh:
  #   gcc built freestanding (no newlib), --enable-languages=c
  gccNoNewlib = [ "sh-elf" "avr-elf" "fr30-elf" "hppa-linux" "pdp11-aout" "xtensa-elf" ];
  #   gcc built with newlib, --enable-languages=c,c++
  gccCpp = [
    "arm-elf" "i386-elf" "mips-elf" "powerpc-elf" "frv-elf" "m32r-elf"
    "m6811-elf" "m68k-elf" "mips64-elf" "mmix-elf" "mn10300-elf" "sh64-elf"
    "sparc-elf" "strongarm-elf" "v850-elf" "xscale-elf" "xstormy16-elf" "i960-elf"
  ];
  #   (everything else in allTargets: gcc with newlib, --enable-languages=c)
  # gdb is attempted opportunistically for every target (see mk-target.nix).

  mkTarget = callPackage ./mk-target.nix {
    inherit binutilsSrc gccSrc newlibSrc gdbSrc;
    patchDir = ./patch;
  };

  targetInfo = t: {
    target = t;
    gccLang = if lib.elem t gccCpp then "c,c++" else "c";
    gccNewlib = !(lib.elem t gccNoNewlib);
    # i960 is an obsoleted gcc target; v850's v850e multilib hits a mid-end
    # 64-bit-HOST_WIDE_INT stack-adjust bug (a malformed unsigned frame offset
    # that only the v850e+no-app-regs variant triggers), so build v850 with a
    # single (base-ABI) multilib -- the base toolchain + newlib build cleanly.
    gccOpt = if t == "i960-elf" then "--enable-obsolete"
             else if t == "v850-elf" then "--disable-multilib"
             else "";
  };

  # attr name == target name (valid Nix attr / CLI token already)
  targets = lib.listToAttrs (map (t: lib.nameValuePair t (mkTarget (targetInfo t))) allTargets);

  # The book's "major architectures" — the reliably-building core, bundled as the
  # default `cross2` output.
  coreTargets = [ "arm-elf" "h8300-elf" "i386-elf" "mips-elf" "powerpc-elf" "sh-elf" ];
in
symlinkJoin {
  name = "cross2-20130826";
  paths = map (t: targets.${t}) coreTargets;

  passthru = {
    inherit targets;
    targetNames = lib.attrNames targets;
  };

  meta = with lib; {
    description = "kozos.jp cross2 bare-metal ELF cross toolchains (binutils 2.21.1 + gcc 3.4.6 + newlib 1.20.0 + gdb 7.3.1); major-arch bundle. Per-target: cross2-<target>";
    homepage = "https://kozos.jp/books/asm/";
    license = with licenses; [ gpl2Plus gpl3Plus ];
    platforms = platforms.linux;
  };
}
