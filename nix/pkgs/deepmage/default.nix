{ lib
, pkgsPy2
, fetchFromGitHub
}:

let
  # Deepmage's Hy sources use the legacy language syntax. Hy 0.20 is the last
  # compatible release and understands the Python AST used by this package set.
  py = pkgsPy2.python3Packages;

  hy = py.buildPythonPackage rec {
    pname = "hy";
    version = "0.20.0";
    format = "setuptools";

    src = py.fetchPypi {
      inherit pname version;
      hash = "sha256-G3KGN1T7V+LdJ1qXdb9iHLUKVl52czoudOmVTn+7Bg4=";
    };

    propagatedBuildInputs = with py; [ astor colorama funcparserlib rply ];
    postPatch = ''
      # Python 3.10 requires source locations on import aliases. The generated
      # tree already carries parent locations, so let the stdlib fill children.
      substituteInPlace hy/compiler.py \
        --replace 'return compile(a, filename, mode, hy_ast_compile_flags)' \
                  'return compile(ast.fix_missing_locations(a), filename, mode, hy_ast_compile_flags)'
      sed -i '7i import ast' hy/importer.py
      substituteInPlace hy/importer.py \
        --replace 'data = hy_compile(hy_tree, module)' \
                  'data = ast.fix_missing_locations(hy_compile(hy_tree, module))'
    '';
    preBuild = ''
      export HOME=$TMPDIR
    '';
    doCheck = false;
  };
in
py.buildPythonApplication rec {
  pname = "deepmage";
  version = "0.2.1";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "mmiszczyk";
    repo = "deepmage";
    rev = version;
    hash = "sha256-a4EEl8WAMVpl9zr9DEr1MuDIC3V5Y/+n2HndkeSGVlU=";
  };

  propagatedBuildInputs = with py; [
    asciimatics
    bitstring
    hy
  ];

  postPatch = ''
    # Modern setuptools correctly rejects the string where package_data has
    # always required a list; preserve the intended Hy source inclusion.
    sed -i 's/package_data={.*\*.hy.*}/package_data={"": ["*.hy"]}/' setup.py

    # BitString was the old name of bitstring's mutable BitArray class.
    substituteInPlace libdeepmage/deepmage.py \
      --replace 'bitstring.BitString' 'bitstring.BitArray'

    # Hy 0.20 expands a macro invoked directly, but not an anaphoric macro
    # emitted by another macro. Spell out the two affected loops so `it`
    # cannot escape into runtime code as an unbound name.
    grep -Fq '(defn save [self]  (for-each-chunk' libdeepmage/bitstream_reader.hy
    sed -i '165,172c\(defn save [self] (for [chunk self.chunks] (when chunk.modified (.save chunk))))\n(defn purge [self] (for [chunk self.chunks] (unless (or chunk.modified chunk.in-view (not chunk.loaded)) (.unload chunk))))' \
      libdeepmage/bitstream_reader.hy
  '';

  doCheck = false;

  pythonImportsCheck = [ "libdeepmage.deepmage" ];

  postFixup = ''
    test_file=$TMPDIR/deepmage-smoke.bin
    printf '\x41\x42' > "$test_file"
    $out/bin/deepmage-hexdump "$test_file" | grep -q '41 42'
    $out/bin/deepmage-hexparse --help >/dev/null
  '';

  meta = {
    description = "Terminal hex editor for non-octet-oriented data";
    homepage = "https://github.com/mmiszczyk/deepmage";
    license = lib.licenses.gpl3Only;
    mainProgram = "deepmage";
    platforms = lib.platforms.unix;
  };
}
