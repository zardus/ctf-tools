# angr — binary analysis platform.
#
# The pre-nix tool exposed exactly two commands, `angr-python` and
# `angr-ipython`: a Python interpreter and an IPython REPL that could
# `import angr` (angr/install did `pipx install angr` and then pip-installed
# ipython into that venv). nixpkgs only has the *library*
# `python3Packages.angr`, whose sole console script is `angr`, and installing a
# library derivation into a profile does not put angr on any interpreter's
# sys.path. So build an interpreter environment and re-export the old names,
# plus upstream's `angr` CLI.
{ lib
, callPackage
, runCommand
}:

let
  # python312 with a buildable angr — see ./python.nix.
  python = callPackage ./python.nix { };

  # angr's two extras that are actually available here: `unicorn` (the native
  # unicorn engine -- without it angr logs "unicorn support disabled" on every
  # start and falls back to VEX-only execution) and `angrDB` (the sqlalchemy
  # project database). The `llm`/`keystone`/`telemetry` extras are left out;
  # nothing in the pre-nix tool used them.
  env = python.withPackages (ps:
    [ ps.angr ps.ipython ]
    ++ ps.angr.optional-dependencies.unicorn
    ++ ps.angr.optional-dependencies.angrDB);
in
runCommand "angr-${python.pkgs.angr.version}"
{
  passthru = { inherit env; angrPython = python; };
  meta = {
    description = "Binary analysis platform, with an interpreter and IPython REPL that can import angr";
    homepage = "https://angr.io/";
    license = lib.licenses.bsd2;
    mainProgram = "angr-ipython";
    platforms = lib.platforms.unix;
  };
} ''
  mkdir -p $out/bin
  # Symlinks, not wrapProgram: these are already the wrapped entry points of a
  # python.withPackages env, so PYTHONPATH is baked in and a wrapper would only
  # add a layer.
  ln -s ${env}/bin/python3 $out/bin/angr-python
  ln -s ${env}/bin/ipython $out/bin/angr-ipython
  ln -s ${env}/bin/angr    $out/bin/angr
''
