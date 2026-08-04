{ lib, stdenv, fetchFromGitHub, boost }:

stdenv.mkDerivation {
  pname = "fastcoll";
  version = "unstable-2016-04-19";

  src = fetchFromGitHub {
    owner = "upbit";
    repo = "clone-fastcoll";
    rev = "1fd0c6ebe308a5e83391bf424578713db8d13f85";
    hash = "sha256-zOwrdPbEqnGa7kH8PNit/U8p3gQmxgBVfXi4jH+D5cM=";
  };

  buildInputs = [ boost ];

  # The upstream Makefile leaves LIB empty, so link against the boost
  # libraries the sources require (program_options / filesystem / system).
  makeFlags = [
    "LIB=-lboost_program_options -lboost_filesystem -lboost_system"
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 fastcoll $out/bin/fastcoll
    runHook postInstall
  '';

  meta = with lib; {
    description = "MD5 collision generator (fastcoll) by Marc Stevens";
    homepage = "https://github.com/upbit/clone-fastcoll";
    license = licenses.free;
    mainProgram = "fastcoll";
    platforms = platforms.unix;
  };
}
