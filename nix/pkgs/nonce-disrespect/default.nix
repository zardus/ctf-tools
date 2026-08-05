{ lib, stdenv, fetchFromGitHub, gmp, ntl }:

stdenv.mkDerivation {
  pname = "nonce-disrespect";
  version = "unstable-2016-08-08";

  src = fetchFromGitHub {
    owner = "nonce-disrespect";
    repo = "nonce-disrespect";
    rev = "425524519779c27dd74c2b51d436f5d3de8d364d";
    hash = "sha256-vLqddb9qsupBKBpKxlb2hmKJ3Ql+MeU0tIiStjadS7I=";
  };

  # The upstream Makefile places $(LDLIBS) before the object files, which
  # breaks with modern binutils' --as-needed linking. The patch appends the
  # libraries again after the objects.
  patches = [ ./build.patch ];

  buildInputs = [ gmp ntl ];

  buildPhase = ''
    runHook preBuild
    make -C tool
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 tool/forge $out/bin/forge
    install -Dm755 tool/recover $out/bin/recover
    runHook postInstall
  '';

  meta = with lib; {
    description = "Tools to forge and recover AES-GCM ciphertexts from nonce reuse (nonce-disrespect)";
    homepage = "https://github.com/nonce-disrespect/nonce-disrespect";
    license = licenses.mit;
    mainProgram = "forge";
    platforms = platforms.unix;
  };
}
