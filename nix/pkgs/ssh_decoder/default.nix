{ lib, stdenv, fetchFromGitHub, ruby, makeWrapper }:

stdenv.mkDerivation {
  pname = "ssh_decoder";
  version = "unstable-2cb22f8";

  src = fetchFromGitHub {
    owner = "jjyg";
    repo = "ssh_decoder";
    rev = "2cb22f8e6d684d910cd542b67de385e9a56fb3a8";
    hash = "sha256-MFLXUDx+ckj8kR43DzrwKgTM8m3t7AZdUxLDS6zMC0E=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ ruby ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/ssh_decoder $out/bin
    cp ssh_decoder.rb $out/libexec/ssh_decoder/ssh_decoder.rb
    cp -f README COPYING $out/libexec/ssh_decoder/ 2>/dev/null || true

    makeWrapper ${ruby}/bin/ruby $out/bin/ssh_decoder \
      --add-flags $out/libexec/ssh_decoder/ssh_decoder.rb

    runHook postInstall
  '';

  meta = with lib; {
    description = "Decipher captured SSH sessions where one end uses a vulnerable Debian OpenSSL PRNG";
    homepage = "https://github.com/jjyg/ssh_decoder";
    license = licenses.gpl3Plus;
    mainProgram = "ssh_decoder";
    platforms = platforms.unix;
  };
}
