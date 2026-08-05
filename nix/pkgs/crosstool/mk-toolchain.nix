{ lib
, stdenv
, ctng
, ctBuildInputs
, cacert
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
{ sample, sha256 ? lib.fakeHash }:

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

      # Retry: the upstream mirrors occasionally hand back a truncated file (CI
      # runs a dozen of these concurrently), and ct-ng treats a digest mismatch
      # as fatal -- it deletes the bad tarball and aborts the whole download.
      # Tarballs already in $out are kept, so a retry only re-fetches what
      # failed.
      for attempt in 1 2 3; do
        if ct-ng build; then break; fi
        if [ "$attempt" = 3 ]; then
          echo "source download failed after 3 attempts" >&2
          exit 1
        fi
        echo "=== download attempt $attempt failed; retrying ===" >&2
        sleep 15
      done
    '';
  };

  toolchain = stdenv.mkDerivation {
    pname = "crosstool-ng-${sanitized}";
    version = ctng.version;

    nativeBuildInputs = [ ctng ] ++ ctBuildInputs;

    dontUnpack = true;

    # The Nix stdenv enables hardening flags by default (via the cc-wrapper),
    # notably format hardening (-Werror=format-security). That breaks building
    # gcc/binutils/newlib themselves (e.g. gcc-16's libcpp/expr.cc). A toolchain
    # build must drive the host compiler without these injected flags, so turn
    # hardening off for this derivation.
    hardeningDisable = [ "all" ];

    passthru = { inherit sample sanitized sources; };

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

      ct-ng build

      # ct-ng installs into $CT_PREFIX/<target-triple>. Promote that tree to
      # $out so the cross compilers land in $out/bin.
      target="$(ls "$CT_PREFIX")"
      mkdir -p "$out"
      cp -a "$CT_PREFIX/$target/." "$out/"
      chmod -R u+w "$out"
    '';

    meta = with lib; {
      description = "crosstool-NG sample cross toolchain: ${sample}";
      homepage = "https://crosstool-ng.github.io/";
      license = licenses.gpl2Plus;
      platforms = platforms.linux;
    };
  };
in
toolchain
