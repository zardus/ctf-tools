{ lib, stdenv, fetchFromGitHub, openssl }:

stdenv.mkDerivation {
  pname = "pemcrack";
  version = "unstable-2016-01-13";

  src = fetchFromGitHub {
    owner = "robertdavidgraham";
    repo = "pemcrack";
    rev = "66e02b8e6d04ecb8404db937c4f7854db6b5a3a3";
    hash = "sha256-gxcg0fUALk5hTx0Gor7Icnu/YtIKh9k96iDBqcvTgT8=";
  };

  buildInputs = [ openssl ];

  # Newer gcc rejects implicit declaration of isspace(); pull in ctype.h.
  env.NIX_CFLAGS_COMPILE = "-include ctype.h -Wno-implicit-function-declaration";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp bin/pemcrack $out/bin/pemcrack
    runHook postInstall
  '';

  meta = {
    description = "Cracks SSL PEM files that hold encrypted private keys";
    homepage = "https://github.com/robertdavidgraham/pemcrack";
    mainProgram = "pemcrack";
    platforms = lib.platforms.unix;
  };
}
