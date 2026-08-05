#!/usr/bin/env bash
# Generic launcher for the libc-database subcommands.
#
# The upstream scripts write their database (db/, libs/) into their own
# directory, which is impossible under the read-only Nix store. We therefore
# materialise a writable working directory containing symlinks to the immutable
# store scripts plus writable db/ and libs/ directories, then run the real
# subcommand from there.
#
# Wrapper-provided environment:
#   LIBC_DATABASE_STORE  path to the immutable scripts in the Nix store
#   LIBC_DATABASE_CMD    the subcommand to run (add/dump/find/get/identify/download)
# User-overridable:
#   LIBC_DATABASE_PATH   working directory (default: ./libc-database under $PWD)
set -euo pipefail

workdir="${LIBC_DATABASE_PATH:-$PWD/libc-database}"
mkdir -p "$workdir" "$workdir/db" "$workdir/libs"

for f in add dump find get identify download common searchengine README.md LICENSE.md; do
  if [ ! -e "$workdir/$f" ]; then
    ln -s "$LIBC_DATABASE_STORE/$f" "$workdir/$f"
  fi
done

cd "$workdir"
exec "./$LIBC_DATABASE_CMD" "$@"
