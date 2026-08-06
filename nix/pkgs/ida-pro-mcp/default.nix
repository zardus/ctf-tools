# pkgsPy2 is injected by the flake for all tools; this one is Python 3 only,
# so it is accepted and ignored here.
{ lib, python3Packages, fetchFromGitHub, pkgsPy2 ? null }:

# The pre-nix ida/install cloned mrexodia/ida-pro-mcp and activated IDA's
# `idalib` into that checkout's uv environment, giving the user an MCP server
# that drives IDA (headless via idalib, or attached to a running IDA through
# the bundled plugin). IDA itself is nonfree and stays user-supplied, but the
# MCP server is MIT, so it is packaged here as its own output.
#
# Two entry points matter:
#   ida-pro-mcp --install   install the IDA plugin + wire up MCP clients
#   idalib-mcp <binary>     headless server; needs `idapro`, which only exists
#                           inside a licensed IDA install -> `ida --activate-idalib`
#                           (see nix/pkgs/ida) builds the venv that has both.
python3Packages.buildPythonApplication rec {
  pname = "ida-pro-mcp";
  # 2.0.0 (vendored zeromcp, no `mcp` dependency) has no release tag yet; the
  # pre-nix installer tracked the default branch unpinned, so pin its tip.
  version = "2.0.0-unstable-2026-08-05";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mrexodia";
    repo = "ida-pro-mcp";
    rev = "2ca65ed8f505c912bb921fd8873e7d757bdf627b";
    hash = "sha256-SW8Dkfru+YIeTejglaprmtbHgCy0nUp3nLHPkoPKO9Y=";
  };

  build-system = [ python3Packages.setuptools ];
  dependencies = [ python3Packages.tomli-w ];

  # `idapro` is the idalib binding that ships *inside* a licensed IDA Pro
  # install (py-activate-idalib.py pip-installs it); it is not on PyPI and
  # cannot be a build input. Only the idalib_* / trace_dump modules import it —
  # the MCP server and the installer do not — so drop it from the metadata
  # instead of failing the runtime-dependency check.
  pythonRemoveDeps = [ "idapro" ];

  # The IDAPython plugin half only imports inside IDA, and the test suite wants
  # a real IDA install; import-check what can run standalone.
  doCheck = false;
  pythonImportsCheck = [ "ida_pro_mcp" "ida_pro_mcp.server" "ida_pro_mcp.installer" ];

  meta = with lib; {
    description = "MCP server for IDA Pro (headless via idalib, or attached to a running IDA)";
    homepage = "https://github.com/mrexodia/ida-pro-mcp";
    license = licenses.mit;
    mainProgram = "ida-pro-mcp";
    platforms = platforms.linux;
  };
}
