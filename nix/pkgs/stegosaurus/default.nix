{ lib
, stdenv
, fetchFromGitHub
, autoPatchelfHook
, zlib
}:

# Upstream ships a prebuilt PyInstaller-frozen ELF binary named `stegosaurus`.
# The original ctf-tools installer just clones the repo and symlinks
# `stegosaurus/stegosaurus` into bin/. We reproduce exactly that binary here,
# patched to run under Nix (interpreter + libz/libdl/libc via autoPatchelfHook).
stdenv.mkDerivation rec {
  pname = "stegosaurus";
  version = "unstable-2019-08-27";

  src = fetchFromGitHub {
    owner = "AngelKitty";
    repo = "stegosaurus";
    rev = "8d5868b1bd4aa37946a80224619133e9d7116ea2";
    hash = "sha256-3ptqinDOq0RAuDx0PRr1G3taWtmQmv/6el8+oOj9MmE=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  # Runtime libs the frozen bootloader links against (libc/libdl come from stdenv).
  buildInputs = [ zlib ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 stegosaurus $out/bin/stegosaurus
    # Keep the pure-python source alongside for reference.
    install -Dm644 stegosaurus.py $out/share/stegosaurus/stegosaurus.py

    runHook postInstall
  '';

  meta = with lib; {
    description = "Steganography tool for embedding payloads within Python bytecode";
    homepage = "https://github.com/AngelKitty/stegosaurus";
    license = licenses.mit;
    mainProgram = "stegosaurus";
    platforms = [ "x86_64-linux" ];
  };
}
