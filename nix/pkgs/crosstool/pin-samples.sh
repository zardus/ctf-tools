#!/usr/bin/env bash
# Trust-on-first-use pinner for crosstool-NG per-sample source-tarball sets,
# and generator for the sample-id list.
#
# Each crosstool-NG sample toolchain is built fully offline from a fixed-output
# "sources" derivation (see ./mk-toolchain.nix). That FOD needs a content hash,
# which we discover by building it once with a fake hash and reading the real
# one Nix reports. This script does that for every sample missing from
# ./hashes.nix and appends the results.
#
# It first rewrites ./samples.nix from the pinned crosstool-NG source. That file
# has to be checked in (rather than read with builtins.readDir at eval time)
# because reading it from the fetched source is an import-from-derivation, which
# `nix flake show` and `nix search` refuse — see ./samples.nix. Regenerating it
# first also means a ctng.nix version bump picks up new samples here.
#
# Usage:  ./pin-samples.sh            # refresh samples.nix, pin unpinned samples
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

# --- regenerate ./samples.nix from the pinned crosstool-NG source -----------
# The directory name under samples/ *is* the id accepted by `ct-ng <id>`.
# LC_ALL=C so the order matches Nix's own (byte-wise) string sort.
src=$(nix build --impure --no-link --print-out-paths \
        --extra-experimental-features 'nix-command flakes' \
        --expr "${EXPR} c.src") || { echo "could not fetch ct-ng source" >&2; exit 1; }
{
  cat <<'EOF'
# Sample ids shipped by the pinned crosstool-NG release (see ./ctng.nix). The
# directory name under the source tree's samples/ *is* the id accepted by
# `ct-ng <id>`; this file is just that listing, checked in.
#
# It exists so the package set can be *enumerated* without building anything:
# reading the list out of the fetched source would be an import-from-derivation,
# which `nix flake show` and `nix search` disable unconditionally (they would
# fail for everyone, whatever the user's allow-import-from-derivation setting).
#
# Generated — do not edit by hand. Regenerate after bumping ctng.nix's version
# with ./pin-samples.sh (which rewrites this file before pinning new hashes).
EOF
  echo '['
  (cd "$src/samples" && LC_ALL=C ls -1p) | grep '/$' | sed 's,/$,,' \
    | LC_ALL=C sort | sed 's/^/  "/; s/$/"/'
  echo ']'
} > "$HERE/samples.nix.new"
mv "$HERE/samples.nix.new" "$HERE/samples.nix"
echo "# samples.nix: $(grep -c '^  "' "$HERE/samples.nix") sample(s) from $src" >&2

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
