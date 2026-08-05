{ lib, stdenv, fetchurl }:

# pwndbg is shipped upstream as a fully self-contained "portable" release
# bundle: it carries its own ld-linux loader, libpython, gdb, gdbserver and
# all supporting shared libraries under lib/. The two entrypoints in bin/
# (pwndbg and gdbserver) are POSIX-sh wrappers that locate the bundle relative
# to themselves (via realpath) and exec the bundled loader on the bundled gdb.
#
# Because the bundle is relocatable and self-contained we simply unpack it and
# keep the tree intact; autoPatchelf is intentionally NOT used, as that would
# fight the bundle's own loader/library resolution mechanism.
stdenv.mkDerivation rec {
  pname = "pwndbg";
  version = "2025.02.19";

  src = fetchurl {
    url = "https://github.com/pwndbg/pwndbg/releases/download/${version}/pwndbg_${version}_x86_64-portable.tar.xz";
    hash = "sha256-Vta4sD70jEhcusWoHlmRI0pHltN9gctfXCJJ7kbTpGQ=";
  };

  # The tarball root is ./pwndbg/{bin,exe,lib,share}; strip that one component.
  sourceRoot = "pwndbg";

  dontConfigure = true;
  dontBuild = true;
  # The bundle is a prebuilt portable blob with its own loader; do not strip,
  # patchelf, or otherwise rewrite the ELF binaries.
  dontStrip = true;
  dontPatchELF = true;
  dontAutoPatchelf = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -a bin exe lib share "$out"/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Exploit development and reverse engineering plugin for GDB (portable bundle)";
    homepage = "https://github.com/pwndbg/pwndbg";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "pwndbg";
  };
}
