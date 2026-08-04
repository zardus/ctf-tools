{ lib
, stdenv
, fetchFromGitHub
, libseccomp
, ding-libs
, pkgsi686Linux
, runCommand
}:

# preeny is a collection of LD_PRELOAD shared-object modules (desock, defork,
# derand, detime, ...) used to make CTF challenge binaries easier to run and
# debug. Its whole point is "compiled for many architectures" -- CTF binaries
# are very often 32-bit, so the upstream ctf-tools installer builds BOTH the
# native x86_64 modules and the 32-bit i686 modules (`PLATFORM=-m32 setarch
# i686 make`). We reproduce both here so `desock.so` etc. exist for 32-bit and
# 64-bit targets. (Upstream also builds arbitrary cross-arch copies when the
# sibling `crosstool` toolchains are present; that open-ended cross matrix is
# left to users who need it.)

let
  src = fetchFromGitHub {
    owner = "zardus";
    repo = "preeny";
    rev = "2c2743d64a42c60327b8b50ec9427f3e27eec2c2";
    hash = "sha256-QKq2l2kgT6CQ7RW9wJ69a7UJ4AaUg3dgRXB8I699MuY=";
  };

  # Build the module set with a given (arch-specific) stdenv + deps.
  buildModules = { stdenv, libseccomp, ding-libs, tag }:
    stdenv.mkDerivation {
      pname = "preeny-modules-${tag}";
      version = "0-unstable-2024";
      inherit src;
      buildInputs = [ libseccomp ding-libs ];
      buildPhase = ''
        runHook preBuild
        make -C src all
        runHook postBuild
      '';
      installPhase = ''
        runHook preInstall
        mkdir -p $out
        cp src/*.so $out/
        runHook postInstall
      '';
    };

  m64 = buildModules {
    inherit stdenv libseccomp ding-libs;
    tag = "x86_64";
  };

  # 32-bit i686 modules, built from the i686 package set. Only meaningful on the
  # x86 family; skip elsewhere (e.g. aarch64) rather than fail.
  do32 = stdenv.hostPlatform.system == "x86_64-linux";
  m32 = buildModules {
    stdenv = pkgsi686Linux.stdenv;
    libseccomp = pkgsi686Linux.libseccomp;
    ding-libs = pkgsi686Linux.ding-libs;
    tag = "i686";
  };
in
runCommand "preeny-0-unstable-2024"
  {
    meta = {
      description = "Collection of LD_PRELOAD tricks to ease CTF binary analysis (32- and 64-bit modules)";
      homepage = "https://github.com/zardus/preeny";
      license = lib.licenses.bsd2;
      platforms = lib.platforms.linux;
    };
    passthru = { inherit m64; } // lib.optionalAttrs do32 { inherit m32; };
  }
  ''
    mkdir -p $out/lib/preeny/x86_64-linux-gnu
    # 64-bit modules: arch dir + flat $out/lib for convenience/back-compat
    cp ${m64}/*.so $out/lib/preeny/x86_64-linux-gnu/
    cp ${m64}/*.so $out/lib/
    ${lib.optionalString do32 ''
      mkdir -p $out/lib/preeny/i686-linux-gnu
      cp ${m32}/*.so $out/lib/preeny/i686-linux-gnu/
    ''}
  ''
