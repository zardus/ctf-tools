{ lib, stdenv, fetchurl }:

stdenv.mkDerivation {
  pname = "galois";
  version = "2007-04-05";

  src = fetchurl {
    url = "https://web.eecs.utk.edu/~plank/plank/papers/CS-07-593/galois.tar";
    hash = "sha256-JWVJYvDhh63wr5JSGCLMmXSjWCAHprPROmhzMPICTbE=";
  };

  sourceRoot = ".";

  # The tarball extracts its files directly into the current directory.
  unpackPhase = ''
    runHook preUnpack
    tar xf $src
    runHook postUnpack
  '';

  buildPhase = ''
    runHook preBuild
    # This 2007 code relies on K&R-style empty prototypes (`()` meaning
    # "unspecified args"); build under gnu17 so it is not rejected as C23.
    make CC=${stdenv.cc.targetPrefix}cc \
      CFLAGS="-O3 -std=gnu17 -Wno-implicit-int -Wno-implicit-function-declaration -Wno-error=implicit-int -Wno-error=implicit-function-declaration -Wno-return-mismatch"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    for b in gf_basic_tester gf_div gf_ilog gf_inverse gf_log gf_mult gf_xor gf_xor_tester; do
      install -Dm755 "$b" "$out/bin/$b"
    done
    runHook postInstall
  '';

  meta = with lib; {
    description = "James S. Plank's fast Galois Field arithmetic library command-line tools (gf_mult, gf_div, gf_log, etc.)";
    homepage = "https://web.eecs.utk.edu/~plank/plank/papers/CS-07-593/";
    license = licenses.lgpl21Plus;
    platforms = platforms.unix;
    mainProgram = "gf_mult";
  };
}
