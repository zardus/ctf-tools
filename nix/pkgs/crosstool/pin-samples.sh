#!/usr/bin/env bash
# Trust-on-first-use pinner for crosstool-NG per-sample source-tarball sets.
#
# Each crosstool-NG sample toolchain is built fully offline from a fixed-output
# "sources" derivation (see ./mk-toolchain.nix). That FOD needs a content hash,
# which we discover by building it once with a fake hash and reading the real
# one Nix reports. This script does that for every sample missing from
# ./hashes.nix and appends the results.
#
# Usage:  ./pin-samples.sh            # pin all currently-unpinned samples
# Then review and fold the emitted lines into ./hashes.nix.
#
# Runs one sample at a time (each downloads that sample's gcc/binutils/libc
# tarball set; identical sets dedupe in the store). Samples whose toolchain
# later fails to *build* are still worth pinning so their source FOD is
# reproducible and CI can retry.
set -u

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPR='let pkgs = import (builtins.getFlake "nixpkgs") { system = builtins.currentSystem; config.allowUnfree = true; };
      c = pkgs.callPackage '"$HERE"' {}; in '

names=$(nix eval --impure --json --extra-experimental-features 'nix-command flakes' \
          --expr "${EXPR} builtins.attrNames c.sources" \
        | python3 -c 'import json,sys;print("\n".join(json.load(sys.stdin)))')

emitted=0
for n in $names; do
  if nix build --impure --no-link --extra-experimental-features 'nix-command flakes' \
       --expr "${EXPR} c.sources.\"$n\"" >/dev/null 2>/tmp/ct-pin-err; then
    continue   # already pinned / builds fine
  fi
  got=$(grep -oE 'got:[[:space:]]+sha256-[A-Za-z0-9+/=]+' /tmp/ct-pin-err \
        | head -1 | grep -oE 'sha256-[A-Za-z0-9+/=]+')
  if [ -n "$got" ]; then
    printf '  "%s" = "%s";\n' "$n" "$got"
    emitted=$((emitted + 1))
  else
    echo "# DOWNLOAD FAILED for $n (not a hash mismatch):" >&2
    grep -iE 'error' /tmp/ct-pin-err | head -1 >&2
  fi
done

echo "# pinned $emitted new sample(s); fold the above into hashes.nix" >&2
