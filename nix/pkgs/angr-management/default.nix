# angr-management — the angr GUI.
#
# nixpkgs' angr-management is fine in itself; it fails to build only because it
# is assembled from `python312.pkgs`, and that set's `angr` does not build (see
# ../angr/python.nix for the whole story). So take the upstream derivation and
# hand it the repaired interpreter instead of stock python312 — which also
# lines the GUI up with the angr release it was written against, since nixpkgs'
# angr-management is 9.2.154 too.
{ callPackage
, angr-management
}:

angr-management.override {
  python312 = callPackage ../angr/python.nix { };
}
