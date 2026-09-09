{ lib
, stdenvNoCC
, fetchFromGitHub
, pkgsPy2
, makeWrapper
, gcc
, binutils
}:

let
  # patchkit is Python 2 code. Unicorn 2.x advertises Python 2 support but its
  # module contains Python-3-only syntax, so retain the last genuinely
  # Python-2-compatible release from PyPI.
  unicorn = pkgsPy2.python27Packages.buildPythonPackage rec {
    pname = "unicorn";
    version = "1.0.3";
    format = "setuptools";

    src = pkgsPy2.python27Packages.fetchPypi {
      inherit pname version;
      hash = "sha256-CP02Ft5K2X/8vd08QNOvsL14mVa1oeiQW+kAQrlwZUE=";
    };

    UNICORN_ARCHS = "x86";

    doCheck = false;
    pythonImportsCheck = [ "unicorn" ];
  };

  python = pkgsPy2.python27.withPackages (ps: [
    ps.capstone
    ps.keystone-engine
    unicorn
  ]);
in
stdenvNoCC.mkDerivation {
  pname = "patchkit";
  version = "unstable-2020-05-14";

  src = fetchFromGitHub {
    owner = "lunixbochs";
    repo = "patchkit";
    rev = "95dc699b7f95fcca9a190cf1be6cb3ae20e09c4f";
    hash = "sha256-WHEFZR33HmfytNnn+MQTxkUpyfRGQX0GD2OSdO/nYsU=";
  };

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    # Modern ELF binaries contain PT_GNU_PROPERTY. Patchkit's enum predates it
    # and otherwise aborts while merely reading a current executable.
    sed -i "/PT('PT_GNU_RELRO'/a PT('PT_GNU_PROPERTY', 0x6474e553, 'GNU property note')" \
      util/elffile.py
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/patchkit $out/bin
    cp -r . $out/libexec/patchkit/

    for command in patch run explore bindiff; do
      makeWrapper ${python}/bin/python $out/bin/$command \
        --add-flags $out/libexec/patchkit/$command \
        --prefix PATH : ${lib.makeBinPath [ gcc binutils ]}
    done

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/patch --help >/dev/null
    ${python}/bin/python -c 'import capstone, keystone, unicorn'

    printf 'int main(void) { return 0; }\n' > "$TMPDIR/fixture.c"
    ${gcc}/bin/gcc -no-pie -o "$TMPDIR/fixture" "$TMPDIR/fixture.c"
    $out/bin/patch -o "$TMPDIR/patched" "$TMPDIR/fixture" \
      $out/libexec/patchkit/samples/x86/hello/hello64.py >/dev/null
    "$TMPDIR/patched" | grep -q 'hello world'
  '';

  meta = {
    description = "Python toolkit for patching ELF binaries";
    homepage = "https://github.com/lunixbochs/patchkit";
    license = lib.licenses.mit;
    mainProgram = "patch";
    platforms = [ "x86_64-linux" ];
  };
}
