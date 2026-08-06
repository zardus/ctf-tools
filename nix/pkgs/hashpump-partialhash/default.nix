{ lib
, stdenv
, fetchFromGitHub
, openssl
}:

# HashPump-partialhash is Martin Heistermann's fork of bwall/HashPump. nixpkgs
# ships mainline `hashpump` only, and the fork is the whole point of this
# attribute: it adds two modes mainline does not have,
#
#   -u/--unknown N   brute-force the N unknown leading bits of the original
#                    hash while extending it (main.cpp's `1 << unknown` loop)
#   -z/--sig2 SIG    the target signature that search is matched against
#
# so aliasing this to pkgs.hashpump would ship a binary that rejects `-u`.
# Both modes are labelled "EXPERIMENTAL HACK" upstream; they are still the
# reason the tool is listed separately in README.md.

stdenv.mkDerivation {
  pname = "hashpump-partialhash";
  version = "unstable-2014-04-14";   # date of rev b822764, the fork's tip

  src = fetchFromGitHub {
    owner = "mheistermann";
    repo = "HashPump-partialhash";
    rev = "b822764fa71209858c91378736d43d082c674e96";
    hash = "sha256-Te/+gaqanErU9KPV3x2C99wG/zguj9aIiqeIjdKfO4g=";
  };

  # The fork calls OpenSSL's low-level MD4_*/MD5_*/SHA*_ APIs, which are
  # deprecated (but still exported) in OpenSSL 3. The makefile compiles with
  # -Wall and no -Werror, so the deprecation warnings are harmless; if a future
  # OpenSSL drops the legacy headers this needs -DOPENSSL_API_COMPAT or an
  # older openssl.
  buildInputs = [ openssl ];

  # Upstream's file is the lowercase `makefile` (GNU make finds it) and it
  # hardcodes CC=g++ internally, so no makefile/flag overrides are needed.
  # It has no `install` target that respects $out, hence the manual install.
  installPhase = ''
    runHook preInstall
    install -Dm755 hashpump $out/bin/hashpump
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    # Guard against silently regressing to a mainline-HashPump build.
    $out/bin/hashpump -h 2>&1 | tee help.txt
    grep -q -- '--unknown' help.txt
    grep -q -- '--sig2' help.txt
    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "HashPump hash-length-extension tool, forked to support partially-unknown hashes";
    homepage = "https://github.com/mheistermann/HashPump-partialhash";
    license = licenses.mit;
    mainProgram = "hashpump";
    platforms = platforms.unix;
  };
}
