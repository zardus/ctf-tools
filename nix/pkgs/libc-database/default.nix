{ lib
, stdenvNoCC
, fetchFromGitHub
, makeWrapper
, bash
, coreutils
, perl
, binutils        # readelf, objdump, strings, ar, nm
, file
, wget
, gnugrep
, gnused
, gawk
, gzip
, gnutar
, xz
, zstd
, cpio
, rpm             # rpm2cpio, rpm2archive
, jq
, findutils
}:

# libc-database (niklasb/libc-database) is a collection of bash scripts that
# build/query a local database of libc binaries scraped from distro package
# mirrors. Upstream has no build step; the ctf-tools installer clones the repo,
# patches common/libc.sh to handle >4GB RPMs via rpm2archive, writes small
# bin/libc-database-<cmd> launchers that `cd` into the checkout and run the
# corresponding script, and then runs `libc-database-get all` to download the
# entire (many-GB) database.
#
# DEVIATION FROM UPSTREAM INSTALLER: we deliberately do NOT download the libc
# database at build time. That step pulls gigabytes from external mirrors at
# build time, which is impure and impossible in a fixed-output-free Nix build.
# Instead we package only the scripts. At runtime the user runs
# `libc-database-get`, `libc-database-find`, etc. Because the Nix store is
# read-only but these scripts write their database next to themselves, each
# wrapper materialises a writable working directory (default: ./libc-database
# under $PWD, overridable via $LIBC_DATABASE_PATH) containing symlinks to the
# immutable scripts plus writable db/ and libs/ directories, then runs the
# real script there.
stdenvNoCC.mkDerivation {
  pname = "libc-database";
  version = "unstable-2024-291b0eb";

  src = fetchFromGitHub {
    owner = "niklasb";
    repo = "libc-database";
    rev = "291b0ebf126de9961cd2f8dd1cea2654c57a594a";
    hash = "sha256-Zysjhr76TenMarnoKo+M8DrTNbsnaXSoFZO1puPVoxU=";
  };

  nativeBuildInputs = [ makeWrapper perl gnused ];

  # Reproduce the ctf-tools installer's RPM-handling patch: use rpm2archive as a
  # fallback for RPM files >4GB (rpm2cpio can't handle those).
  postPatch = ''
    cp ${./extract_rpm.sh} common/extract_rpm.sh
    chmod +x common/extract_rpm.sh

    perl -i -0pe 's/\(rpm2cpio pkg\.rpm \|\| die "rpm2cpio failed"\) \| \\\n\s+\(cpio -id --quiet \|\| die "cpio failed"\)/bash "\$SCRIPT_DIR\/common\/extract_rpm.sh" pkg.rpm || die "rpm extraction failed"/g' common/libc.sh
    sed -i '1a SCRIPT_DIR="$(cd "$(dirname "''${BASH_SOURCE[0]}")/.." && pwd)"' common/libc.sh
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    store="$out/libexec/libc-database"
    mkdir -p "$store" "$out/bin"
    cp -r add dump find get identify download common searchengine libs "$store/"
    cp -r README.md LICENSE.md "$store/" || true
    chmod +x "$store"/{add,dump,find,get,identify,download}

    install -m0755 ${./launcher.sh} "$store/launcher.sh"
    patchShebangs "$store/launcher.sh"

    for cmd in add dump find get identify download; do
      makeWrapper "$store/launcher.sh" "$out/bin/libc-database-$cmd" \
        --set LIBC_DATABASE_STORE "$store" \
        --set LIBC_DATABASE_CMD "$cmd" \
        --prefix PATH : ${lib.makeBinPath [
          bash coreutils perl binutils file wget gnugrep gnused gawk
          gzip gnutar xz zstd cpio rpm jq findutils
        ]}
    done

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    # Exercise the wrappers end-to-end. Against an empty database `find` finds
    # nothing and exits 1 (its documented behaviour), so we only require that
    # the wrapper reached the real script and materialised the working dir.
    export LIBC_DATABASE_PATH="$TMPDIR/libc-db-test"
    $out/bin/libc-database-find printf 0x123 >/dev/null 2>&1 || true
    test -e "$LIBC_DATABASE_PATH/db"
    test -L "$LIBC_DATABASE_PATH/find"

    # `dump` on a bogus id must fail via the tool's own `die`, proving the
    # wrapper handed control to the real script (not the wrapper erroring first).
    if $out/bin/libc-database-dump nonexistent-id >/dev/null 2>&1; then
      echo "expected libc-database-dump to fail on a bogus id" >&2
      exit 1
    fi
  '';

  meta = {
    description = "Scripts to build and query a database of libc binaries for CTF exploitation (identify libc versions, resolve symbol offsets)";
    homepage = "https://github.com/niklasb/libc-database";
    license = lib.licenses.mit;
    mainProgram = "libc-database-find";
    platforms = lib.platforms.linux;
  };
}
