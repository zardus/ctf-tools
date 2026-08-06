{ lib
, stdenv
, fetchFromGitHub
, gnumake
, zlib
, xz
, file
, makeWrapper
, bash
, coreutils
, gnused
, gnugrep
, gawk
, findutils
, gzip
, util-linux
, python3
}:

# firmware-mod-kit: a collection of shell scripts plus a large tree of C/C++
# helper tools (squashfs/cramfs/jffs2/yaffs2 pack-unpack utilities, a bundled
# binwalk 2.1.1, trx/asus/motorola firmware helpers, ...).
#
# The upstream ctf-tools installer:
#   1. clones rampageX/firmware-mod-kit and runs `make` in src/
#   2. generates a wrapper in bin/ for every top-level *.sh script that puts
#      the repo dir on PATH and execs the real script
#   3. symlinks every ELF executable found at depth 1 & 2 under src/ into bin/
#      as `fmk-<path-with-slashes-turned-to-dashes>`
#   4. neuters the scripts' `SUDO="sudo"` so nothing tries to escalate
#
# We reproduce exactly those bin/ entries.

let
  # binwalk 2.1.1 (bundled in the tree) needs python + python-magic at runtime.
  pythonEnv = python3.withPackages (ps: [ ps.python-magic ]);

  runtimeDeps = [
    bash
    coreutils
    gnused
    gnugrep
    gawk
    findutils
    gzip
    file
    util-linux # hexdump, used by the extract scripts
    pythonEnv
  ];
in
stdenv.mkDerivation {
  pname = "firmware-mod-kit";
  version = "unstable-2024";

  src = fetchFromGitHub {
    owner = "rampageX";
    repo = "firmware-mod-kit";
    rev = "c72f45d7a062156125ae00cb867d8a614b50b963";
    hash = "sha256-g+v571U3rifwsgD8jvysSZEpjU3NNFClQ5ylGnuKyJo=";
  };

  nativeBuildInputs = [ gnumake file makeWrapper ];
  buildInputs = [ zlib xz ];

  # extract-firmware.sh / footer.sh dump a scratch hexdump into ./footer.txt
  # while their cwd is the (read-only) install directory. Under the ctf-tools
  # installer that directory was a writable checkout; in the store the write
  # fails, FOOTER_SIZE stays 0, no footer.img is emitted and the footer bytes
  # end up inside rootfs.img. Redirect the scratch file to $TMPDIR.
  patches = [ ./footer-scratch-file.patch ];

  # Several of the bundled, decade-old C sources use `printf(var)` and similar,
  # which trips the default format-security hardening. Relax just that.
  hardeningDisable = [ "format" ];

  # The upstream tree ships a few relative symlinks that are already dangling
  # (e.g. src/others/squashfs-3.4-cisco/lzma/Makefile). They are harmless build
  # cruft; don't fail packaging over them.
  dontCheckForBrokenSymlinks = true;

  postPatch = ''
    # This sub-Makefile hard-checks for /usr/include/zlib.h, which does not
    # exist under Nix even though zlib headers are on the compiler search path.
    substituteInPlace src/others/squashfs-2.0-nb4/nb4-mksquashfs/Makefile \
      --replace-fail 'if [ ! -e /usr/include/zlib.h ]; then' 'if false; then'

    # Mirror the ctf-tools installer: never attempt to sudo.
    sed -i 's/SUDO="sudo"/SUDO=""/' ./*.sh

    # footer.sh is the only top-level script that sources shared-ng.inc without
    # first cd'ing into its own directory, so the include silently fails and
    # $FOOTER_IMAGE stays empty -- the `dd ... of=""` at the end then writes
    # nothing. Resolve the include (and create the output directory) so a
    # standalone `footer.sh <image>` actually produces fmk/image_parts/footer.img.
    substituteInPlace footer.sh \
      --replace-fail '. ./shared-ng.inc' \
                     '. "$(dirname "$(readlink -f "$0")")/shared-ng.inc"'
    substituteInPlace footer.sh \
      --replace-fail 'dd if="''${IMG}" bs=1 skip=''${FOOTER_FIRST}' \
                     'mkdir -p "''${IMAGE_PARTS}"
	dd if="''${IMG}" bs=1 skip=''${FOOTER_FIRST}'
  '';

  buildPhase = ''
    runHook preBuild
    # Several bundled sub-Makefiles have missing inter-target dependencies
    # (e.g. a `strip` target that races the build), so build serially.
    make -C src -j1
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    fmk=$out/share/firmware-mod-kit
    mkdir -p "$fmk" "$out/bin"
    cp -r . "$fmk"

    # Point the bundled binwalk (and any other scripts) at a real interpreter.
    patchShebangs "$fmk"

    # A launcher for each top-level *.sh, matching the installer's wrappers.
    # (A couple of the *.sh files ship without the exec bit; the installer
    # wraps them regardless, so mark them executable for makeWrapper.)
    chmod +x "$fmk"/*.sh
    for i in "$fmk"/*.sh; do
      name=$(basename "$i")
      makeWrapper "$i" "$out/bin/$name" \
        --prefix PATH : ${lib.makeBinPath runtimeDeps}
    done

    # fmk-* symlinks for every ELF executable at depth 1 & 2 under src/.
    ( cd "$fmk"
      for p in $(file src/* src/*/* 2>/dev/null | grep "ELF.*executable" | cut -d: -f1); do
        rel=''${p#src/}
        ln -s "$fmk/$p" "$out/bin/fmk-''${rel//\//-}"
      done
    )

    runHook postInstall
  '';

  meta = with lib; {
    description = "Firmware Mod Kit: extract and rebuild router/embedded firmware images";
    homepage = "https://github.com/rampageX/firmware-mod-kit";
    license = licenses.gpl2Plus;
    mainProgram = "extract-firmware.sh";
    platforms = platforms.linux;
  };
}
