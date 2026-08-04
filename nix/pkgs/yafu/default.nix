{ lib
, stdenv
, fetchurl
, unzip
, pkgsPy2 ? null  # unused: yafu ships a prebuilt static binary
}:

# YAFU (Yet Another Factoring Utility) — the ctf-tools installer downloads the
# prebuilt yafu-1.34.zip from SourceForge, extracts it, and drops the bundled
# `yafu` binary into bin/. The shipped Linux binary is a statically linked
# x86-64 ELF (no runtime library dependencies), so we simply fetch the zip and
# install $out/bin/yafu. We fetch the canonical SourceForge download URL
# directly (rather than the `mirror://sourceforge` scheme) because the mirror
# rotation frequently lands on dead/slow mirrors that time out in the sandbox.
stdenv.mkDerivation rec {
  pname = "yafu";
  version = "1.34";

  src = fetchurl {
    url = "https://downloads.sourceforge.net/project/yafu/${version}/yafu-${version}.zip";
    hash = "sha256-vJiQBms0ufhpAHj5ZjD82Bx0tYDgUbFthtXwUFlS2Gc=";
  };

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    runHook preUnpack
    unzip -o "$src"
    runHook postUnpack
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 yafu $out/bin/yafu
    # yafu reads its default parameters from yafu.ini in the cwd; ship it
    # alongside the binary for reference (the binary works fine without it).
    install -Dm644 yafu.ini $out/share/yafu/yafu.ini
    runHook postInstall
  '';

  meta = with lib; {
    description = "YAFU (Yet Another Factoring Utility) — automated integer factorization";
    homepage = "https://sourceforge.net/projects/yafu/";
    license = licenses.free;
    mainProgram = "yafu";
    platforms = [ "x86_64-linux" ];
  };
}
