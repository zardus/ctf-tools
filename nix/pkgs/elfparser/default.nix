{ lib
, stdenv
, fetchFromGitHub
, cmake
, boost
, qt5
}:

# elfparser-ng: ELF static analysis tool. Upstream builds two executables from
# the same CMake project via an option `-D qt=[yes|no]`:
#   * qt=yes  -> elfparser-ng      (Qt GUI)   installed as elfparser-gui-ng
#   * qt=no   -> elfparser-cli-ng  (CLI)      installed as elfparser-cli-ng
# We reproduce both from two separate build trees, mirroring the ctf-tools
# installer.

stdenv.mkDerivation {
  pname = "elfparser-ng";
  version = "unstable-2024";

  src = fetchFromGitHub {
    owner = "mentebinaria";
    repo = "elfparser-ng";
    rev = "0b69343760f7a1490b04fd8227d34183651a8432";
    hash = "sha256-xdz9vVVnR1lFxiBirMZXHr6oOzmXhy9jpoRjFRD0E9c=";
  };

  nativeBuildInputs = [ cmake qt5.wrapQtAppsHook ];
  buildInputs = [ boost qt5.qtbase ];

  # Upstream hard-codes `-march=native` (non-reproducible / can fail on some
  # builders) and forces static Boost linkage (nixpkgs ships shared Boost by
  # default, so the static libs are not found). Relax both.
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "-O2 -fno-stack-protector -march=native" "-O2 -fno-stack-protector"
    substituteInPlace CMakeLists.txt \
      --replace-fail "set(Boost_USE_STATIC_LIBS ON)" "set(Boost_USE_STATIC_LIBS OFF)"
    # Boost.System is header-only in modern Boost and no longer ships a separate
    # CMake component config; drop it from the component list (linkage is fine).
    substituteInPlace CMakeLists.txt \
      --replace-fail "COMPONENTS program_options iostreams system filesystem regex" \
                     "COMPONENTS program_options iostreams filesystem regex"
  '';

  dontUseCmakeConfigure = true;

  buildPhase = ''
    runHook preBuild

    mkdir -p gui cli

    cmakeFlags="-DCMAKE_POLICY_VERSION_MINIMUM=3.5"

    echo "=== building Qt GUI (elfparser-gui-ng) ==="
    ( cd gui && cmake $cmakeFlags -D qt=yes ../ && make -j$NIX_BUILD_CORES )

    echo "=== building CLI (elfparser-cli-ng) ==="
    ( cd cli && cmake $cmakeFlags -D qt=no ../ && make -j$NIX_BUILD_CORES )

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/elfparser-ng
    install -Dm755 gui/elfparser-ng     $out/bin/elfparser-gui-ng
    install -Dm755 cli/elfparser-cli-ng $out/bin/elfparser-cli-ng
    if [ -f src/ui/assets/bug.png ]; then
      install -Dm644 src/ui/assets/bug.png $out/share/elfparser-ng/bug.png
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "Command-line and Qt GUI ELF static-analysis / scoring tool (elfparser-ng)";
    homepage = "https://github.com/mentebinaria/elfparser-ng";
    license = licenses.mit;
    mainProgram = "elfparser-cli-ng";
    platforms = platforms.linux;
  };
}
