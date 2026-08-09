# angr-management — the angr GUI.
#
# angr-management releases in lockstep with angr and pins it exactly
# (`angr[angrDB]==9.3.2`), so it moves with ../angr/python.nix: nixpkgs'
# derivation is still on 9.2.154 and would fail its runtime dependency check
# against the angr in that set. What is taken from nixpkgs is the Qt wiring
# (libxcb-cursor, the PySide6/QtAds/pyqodeng dependency web); the version, the
# source and the dependency list are ours.
{ lib
, callPackage
, fetchFromGitHub
, angr-management
}:

let
  python = callPackage ../angr/python.nix { };
  version = "9.3.2";
in
(angr-management.override { python312 = python; }).overridePythonAttrs (_: {
  inherit version;

  src = fetchFromGitHub {
    owner = "angr";
    repo = "angr-management";
    tag = "v${version}";
    hash = "sha256-wujsgD8s4RMYNfyQeFvBh+4KgdZxqIrr0s8b28uAqCU=";
  };

  # angr: pinned `==9.3.2` and satisfied exactly, but the check compares against
  # the *installed* dist name and extras, so it stays relaxed as nixpkgs had it.
  # binsync/qtawesome: upstream pins exact versions (5.7.11, 1.4.0) that nixpkgs
  # sits just above (5.11.0, 1.4.1).
  pythonRelaxDeps = [ "angr" "binsync" "qtawesome" ];

  # Upstream asks for the PyPI split-out `PySide6-Essentials`; nixpkgs ships the
  # whole of Qt for Python as one `pyside6` (dist name "PySide6"), which is a
  # superset, so the requirement can never be satisfied by name.
  pythonRemoveDeps = [ "PySide6-Essentials" ];

  dependencies = with python.pkgs; [
    angr
    bidict
    binsync
    cle
    ipython
    pyqodeng-angr
    pyside6
    pyside6-qtads
    qtawesome
    qtconsole
    qtpy
    requests
    rpyc
    thefuzz
    tomlkit
  ]
  ++ angr.optional-dependencies.angrDB
  # angr-management's own `unicorn` extra, which is just `angr[unicorn]`:
  # without it the GUI logs "unicorn support disabled" at startup and executes
  # VEX-only, the same as the `angr` tool (see ../angr/default.nix).
  ++ angr.optional-dependencies.unicorn
  ++ requests.optional-dependencies.socks
  ++ thefuzz.optional-dependencies.speedup;

  meta = angr-management.meta // {
    description = "Graphical binary analysis tool powered by the angr binary analysis platform";
  };
})
