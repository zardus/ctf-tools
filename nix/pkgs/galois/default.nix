{ lib, stdenv, fetchurl }:

stdenv.mkDerivation {
  pname = "galois";
  version = "2007-04-05";

  # Plank's home directory moved from ~plank to ~jplank. The old URL still
  # redirects, but the chain detours through plain http, and the department's
  # server answers 403 to the final hop for some clients — CI among them. Ask
  # for the current location directly, and keep a Wayback snapshot of the same
  # (hash-identical) tarball as a mirror: this is a 2007 paper artifact on one
  # university web server, with no upstream left to fix it if that goes away.
  src = fetchurl {
    urls = [
      "https://web.eecs.utk.edu/~jplank/plank/papers/CS-07-593/galois.tar"
      "https://web.archive.org/web/20141117051901id_/http://web.eecs.utk.edu/~plank/plank/papers/CS-07-593/galois.tar"
    ];
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
    homepage = "https://web.eecs.utk.edu/~jplank/plank/papers/CS-07-593/";
    license = licenses.lgpl21Plus;
    platforms = platforms.unix;
    mainProgram = "gf_mult";
  };
}
