{ lib
, stdenv
, fetchFromGitHub
, autoPatchelfHook
, zlib
, bison
, flex
, texinfo
, pkgsPy2 ? null  # accepted (workflow injects it) but xrop needs no Python 2
}:

# xrop (https://github.com/acama/xrop) is a multi-architecture ROP gadget
# finder. Its upstream build is deliberately self-contained: it vendors a whole
# disassembler stack through nested git submodules and compiles it all from
# source:
#
#   acama/xrop
#     └─ src/libxdisasm            (acama/libxdisasm)
#          ├─ src/binutils         (sourceware binutils-gdb, pinned commit
#          │                        0014c67d3bc3030af2d98be90c21e6ac1b15c6d8)
#          └─ src/zstd             (facebook/zstd)
#
# libxdisasm configures and statically builds bfd/opcodes/libiberty/libsframe
# out of that exact binutils-gdb checkout with ~24 targets enabled, then links
# libxdisasm.so (and xrop) against it.
#
# The pinned binutils-gdb commit lives ONLY on sourceware (it is one of the
# daily "Automatic date update in version.in" auto-commits and is absent from
# the GitHub bminor mirror). sourceware rate-limits its https/gitweb endpoints
# (HTTP 429), but the git:// protocol serves it fine, and `.gitmodules` already
# points the binutils submodule at git://sourceware.org/git/binutils-gdb.git.
# So a recursive submodule fetch (fetchSubmodules = true) obtains every piece
# reproducibly, and we build the real thing.

stdenv.mkDerivation {
  pname = "xrop";
  version = "unstable-2024";

  src = fetchFromGitHub {
    owner = "acama";
    repo = "xrop";
    rev = "0083e9464218e709df70477579965fbf3dd46fd4";
    fetchSubmodules = true;
    hash = "sha256-3EMZRmE0TKr25/Z/gXvQnb2NIdLzQ+ItIIlXL23SJeQ=";
  };

  # bison/flex/texinfo: the vendored binutils bfd/opcodes configure+build may
  # regenerate a few parser/lexer/doc stubs. zlib: libxdisasm links -lz and the
  # final xrop rpath needs libz at runtime.
  nativeBuildInputs = [ autoPatchelfHook bison flex texinfo ];
  buildInputs = [ zlib ];

  # The build is tuned to the author's older toolchain; a modern nixpkgs gcc
  # needs three adjustments, none of which change any source:
  #
  #  1. libxdisasm and xrop compile with -Werror -> newer gcc warnings abort the
  #     build. Drop -Werror in both of xrop's own Makefiles.
  #  2. The vendored binutils bfd/opcodes/libiberty/libsframe are configured
  #     with binutils' own default -Werror; new gcc trips e.g.
  #     -Werror=calloc-transposed-args. Configure them with --disable-werror.
  #  3. This binutils vintage uses `static_assert` as an ordinary identifier
  #     (typedef char static_assert[...]) in opcodes/mips-formats.h, which is a
  #     reserved keyword under the gcc default C standard here. Build the
  #     vendored binutils as -std=gnu11 so the identifier is legal again.
  postPatch = ''
    substituteInPlace src/Makefile \
      --replace-fail "-O3 -Wall -Werror" "-O3 -Wall"
    substituteInPlace src/libxdisasm/src/Makefile \
      --replace-fail "-fPIC -O3 -Wall -Werror" "-fPIC -O3 -Wall" \
      --replace-fail "./configure" "./configure --disable-werror" \
      --replace-fail 'CFLAGS="-fPIC"' 'CFLAGS="-fPIC -std=gnu11"'
  '';

  # Upstream explicitly warns that a parallel top-level build fails; build -j1.
  enableParallelBuilding = false;

  buildPhase = ''
    runHook preBuild
    make -j1
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 xrop $out/bin/xrop
    install -Dm755 lib/libxdisasm.so $out/lib/libxdisasm.so
    runHook postInstall
  '';

  meta = {
    description = "Multi-architecture ROP gadget finder (x86/ARM/MIPS/PPC/RISC-V/SPARC/SH4)";
    homepage = "https://github.com/acama/xrop";
    license = lib.licenses.gpl3Plus;
    mainProgram = "xrop";
    platforms = lib.platforms.linux;
  };
}
