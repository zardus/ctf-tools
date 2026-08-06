{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, coreutils
, SDL2
, SDL2_image
, SDL2_mixer
}:

# Dwarf Fortress (Bay 12 Games) — shipped as a prebuilt Linux ELF tarball.
# The ctf-tools installer downloads df_51_06_linux.tar.bz2, extracts it, and
# drops a bin/dwarf_fortress launcher that cd's into the game directory and
# runs the game binary. We reproduce that: patchelf the prebuilt binaries and
# expose a bin/dwarf_fortress launcher. The game directory it runs from has
# to be writable (see dwarf_fortress.in), so the launcher seeds a per-user
# copy instead of chdir'ing into the store.
stdenv.mkDerivation rec {
  pname = "dwarf-fortress";
  version = "51.06";

  src = fetchurl {
    url = "https://www.bay12games.com/dwarves/df_51_06_linux.tar.bz2";
    hash = "sha256-/fksG+hpS6UnNXoRIKgeU2mpGJtaBGGTChbJSLkSrzI=";
  };

  # Tarball extracts flat (no top-level directory).
  sourceRoot = ".";

  nativeBuildInputs = [ autoPatchelfHook ];

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
    # sourceRoot = "." means we are building in $NIX_BUILD_TOP, where stdenv
    # dumps the whole build environment to ./env-vars. Copying that into $out
    # would make the runtime closure reference gcc, binutils, make, tar and
    # patch — 1.4 GiB for a 48 MB game.
    rm -f env-vars
    cp -r . "$dfdir/"

    # autoPatchelfHook resolves the bundled .so files because they live
    # next to the main binary in the same output directory.
    mkdir -p "$out/bin"
    substitute ${./dwarf_fortress.in} "$out/bin/dwarf_fortress" \
      --subst-var out \
      --subst-var-by coreutils "${coreutils}"
    chmod 755 "$out/bin/dwarf_fortress"

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
