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
#   LIBC_DATABASE_PATH   working directory
#                        (default: ${XDG_DATA_HOME:-$HOME/.local/share}/libc-database)
set -euo pipefail

# One database per user, not per working directory: the ctf-tools installer
# baked a single absolute checkout into its wrappers, so a libc added (or the
# multi-GB corpus downloaded) anywhere was visible everywhere. A $PWD-relative
# default would silently re-download the corpus once per directory.
if [ -n "${LIBC_DATABASE_PATH:-}" ]; then
  workdir="$LIBC_DATABASE_PATH"
elif [ -n "${XDG_DATA_HOME:-}" ]; then
  workdir="$XDG_DATA_HOME/libc-database"
elif [ -n "${HOME:-}" ]; then
  workdir="$HOME/.local/share/libc-database"
else
  # No HOME (daemon, sandbox, `env -i`): anything else would resolve to a
  # literal /.local/share.
  workdir="${TMPDIR:-/tmp}/libc-database"
fi

mkdir -p "$workdir" "$workdir/db" "$workdir/libs"

for f in add dump find get identify download common searchengine README.md LICENSE.md; do
  if [ ! -e "$workdir/$f" ]; then
    ln -s "$LIBC_DATABASE_STORE/$f" "$workdir/$f"
  fi
done

# Unlike the ctf-tools installer, the derivation cannot download the corpus at
# build time, so the database starts out empty. The query subcommands would
# otherwise just emit a bare `grep: db/*.symbols: No such file or directory`.
case "$LIBC_DATABASE_CMD" in
  find | dump | identify)
    if [ -z "$(ls -A "$workdir/db" 2>/dev/null)" ]; then
      echo "libc-database: $workdir/db is empty; run 'libc-database-get all' (or a single source, e.g. 'libc-database-get ubuntu') to populate it. Set \$LIBC_DATABASE_PATH to use a different database location." >&2
    fi
    ;;
esac

cd "$workdir"
exec "./$LIBC_DATABASE_CMD" "$@"
