{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, runCommandCC
, gmp
, ecm
}:

# Use upstream's generic x86-64 build so the package does not require AVX2.
let
  # GMP-ECM's cached nixpkgs output only installs a static library, while
  # upstream's YAFU binary links libecm.so.1. The archive is built as PIC, so
  # relink it into the required shared object instead of rebuilding GMP-ECM.
  ecmShared = runCommandCC "ecm-shared-${ecm.version}" { } ''
    mkdir -p $out/lib
    $CC -shared -Wl,-soname,libecm.so.1 \
      -Wl,--whole-archive ${ecm}/lib/libecm.a -Wl,--no-whole-archive \
      -L${gmp}/lib -lgmp -lm \
      -o $out/lib/libecm.so.1
  '';
in
stdenv.mkDerivation rec {
  pname = "yafu";
  version = "3.1.9";

  src = fetchurl {
    url = "https://github.com/bbuhrow/yafu/releases/download/v${version}/yafu-linux-generic";
    hash = "sha256-RgqthT8U7Z2iUd0B7KL9+g3KwBRmN4al4Z2HyGRN9Zk=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ gmp ecmShared ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/yafu
    runHook postInstall
  '';

  meta = with lib; {
    description = "YAFU (Yet Another Factoring Utility) — automated integer factorization";
    homepage = "https://github.com/bbuhrow/yafu";
    license = licenses.unlicense;
    mainProgram = "yafu";
    platforms = [ "x86_64-linux" ];
  };
}
