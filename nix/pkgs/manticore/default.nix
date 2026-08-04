{ lib
, python312Packages
, z3
, pkgsPy2 ? null
}:

let
  py = python312Packages;

  # `wasm` — pure-python WebAssembly parser; not packaged in nixpkgs.
  wasm = py.buildPythonPackage rec {
    pname = "wasm";
    version = "1.2";
    format = "setuptools";
    src = py.fetchPypi {
      inherit pname version;
      extension = "tar.gz";
      sha256 = "sha256-KA8Z0to4OlzhNByVG9iZv/rf+UTFJ7fAfL0M5mxkPZ0=";
    };
    # wasm 1.2 predates the removal of the collections.abc aliases in py3.10+.
    postPatch = ''
      for abc in Callable Iterable Mapping MutableMapping Sequence; do
        find . -name '*.py' -exec sed -i \
          "s/collections\.$abc/collections.abc.$abc/g" {} +
      done
    '';
    doCheck = false;
    pythonImportsCheck = [ "wasm" ];
  };

  # nixpkgs' intervaltree pulls a docs toolchain (sphinx) that no longer
  # evaluates on python3.11; build the (pure-python) package directly.
  intervaltree = py.buildPythonPackage rec {
    pname = "intervaltree";
    version = "3.1.0";
    format = "setuptools";
    src = py.fetchPypi {
      inherit pname version;
      extension = "tar.gz";
      sha256 = "sha256-kCsbiJNpGPmyoZ4OXrfMtDCuRc3k856ks2kykg0zlS0=";
    };
    propagatedBuildInputs = [ py.sortedcontainers ];
    doCheck = false;
    pythonImportsCheck = [ "intervaltree" ];
  };

  # manticore imports `sha3` (keccak). Upstream `pysha3` fails to build on
  # modern CPython; `safe-pysha3` is the maintained drop-in fork.
  safe-pysha3 = py.buildPythonPackage rec {
    pname = "safe-pysha3";
    version = "1.0.4";
    format = "setuptools";
    src = py.fetchPypi {
      inherit pname version;
      extension = "tar.gz";
      sha256 = "sha256-5CkUax7dGYssqTSiBGplZWxdMbDsiUu9YFUSf03q/xc=";
    };
    doCheck = false;
    pythonImportsCheck = [ "sha3" ];
  };

in
py.buildPythonApplication rec {
  pname = "manticore";
  version = "0.3.7";
  format = "setuptools";

  src = py.fetchPypi {
    inherit pname version;
    extension = "tar.gz";
    sha256 = "sha256-p1iP0uqdkDtnHUXXy/R8mDAxkC/w/brsGHxYh1DHuPw=";
  };

  # Upstream pins ancient exact versions (capstone==4.0.2, unicorn==1.0.2,
  # crytic-compile==0.2.2, protobuf<4, ...). Relax so we can use nixpkgs.
  pythonRelaxDeps = true;

  # setuptools >=81 dropped the vendored `pkg_resources`; manticore only uses
  # it to look up its own version. Route that through importlib.metadata.
  postPatch = ''
    for f in manticore/__main__.py manticore/ethereum/verifier.py; do
      substituteInPlace "$f" \
        --replace 'import pkg_resources' 'from importlib.metadata import version as _mcore_version' \
        --replace 'pkg_resources.get_distribution("manticore").version' '_mcore_version("manticore")'
    done
  '';

  propagatedBuildInputs = with py; [
    pyyaml
    protobuf
    safe-pysha3
    prettytable
    ply
    rlp
    pydantic
    intervaltree
    crytic-compile
    wasm
    pyevmasm
    z3-solver
    setuptools
    # native extra
    capstone
    pyelftools
    unicorn
  ];

  # manticore 0.3.7 ships protobuf-generated *_pb2.py built with an ancient
  # protoc that the C++ descriptor implementation in protobuf>=3.20 refuses to
  # load. The upstream sdist does not ship the *.proto sources, so we cannot
  # regenerate them; fall back to the pure-python protobuf parser, which
  # accepts the legacy generated code.
  #
  # Manticore shells out to an external SMT solver executable (it does not use
  # the z3 python bindings for solving); put the `z3` binary on its PATH.
  makeWrapperArgs = [
    "--set PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION python"
    "--prefix PATH : ${lib.makeBinPath [ z3 ]}"
  ];

  # The test suite needs network / solc and heavy fixtures.
  doCheck = false;

  # A full import graph pulls in EVM/solidity machinery; just make sure the
  # console entry points resolve.
  pythonImportsCheck = [ ];

  meta = with lib; {
    description = "Symbolic execution tool for analysis of smart contracts and binaries";
    homepage = "https://github.com/trailofbits/manticore";
    license = licenses.agpl3Only;
    mainProgram = "manticore";
  };
}
