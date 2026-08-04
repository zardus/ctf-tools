{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, SDL2
, SDL2_image
, SDL2_mixer
}:

# Dwarf Fortress (Bay 12 Games) — shipped as a prebuilt Linux ELF tarball.
# The ctf-tools installer downloads df_51_06_linux.tar.bz2, extracts it, and
# drops a bin/dwarf_fortress launcher that cd's into the game directory and
# runs the game binary. We reproduce that: patchelf the prebuilt binaries and
# expose a bin/dwarf_fortress wrapper.
stdenv.mkDerivation rec {
  pname = "dwarf-fortress";
  version = "51.06";

  src = fetchurl {
    url = "https://www.bay12games.com/dwarves/df_51_06_linux.tar.bz2";
    hash = "sha256-/fksG+hpS6UnNXoRIKgeU2mpGJtaBGGTChbJSLkSrzI=";
  };

  # Tarball extracts flat (no top-level directory).
  sourceRoot = ".";

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_mixer
    stdenv.cc.cc.lib # libstdc++, libgcc_s
  ];

  # The game ships and dlopen's some of its own libs (libfmod.so.13,
  # libg_src_lib.so, plugins) alongside the main binary.
  installPhase = ''
    runHook preInstall

    dfdir="$out/libexec/df"
    mkdir -p "$dfdir"
    cp -r . "$dfdir/"

    # autoPatchelfHook resolves the bundled .so files because they live
    # next to the main binary in the same output directory.
    mkdir -p "$out/bin"
    makeWrapper "$dfdir/dwarfort" "$out/bin/dwarf_fortress" \
      --chdir "$dfdir"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Dwarf Fortress — single-player fantasy colony/world simulator";
    homepage = "https://www.bay12games.com/dwarves/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "dwarf_fortress";
  };
}
