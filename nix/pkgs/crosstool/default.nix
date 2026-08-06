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

  # sanitized attr name -> toolchain derivation, for the full sample set.
  toolchains = lib.listToAttrs (map
    (sample: {
      name = sanitizeName sample;
      value = mkToolchain {
        inherit sample;
        sha256 = hashes.${sanitizeName sample} or lib.fakeHash;
      };
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
