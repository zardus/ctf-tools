# Tools that already live in nixpkgs. We re-export them verbatim so that
# `nix profile install .#<tool>` works for them with zero maintenance on our
# side. Each attribute name matches the tool's directory name in this repo.
#
# Validated present in nixpkgs-unstable (2026-08). If nixpkgs renames or drops
# one of these, move it into nix/pkgs/<tool>/default.nix as a real derivation.
{ pkgs }:

let
  py = pkgs.python3Packages;
in
{
  angr                 = py.angr;
  angr-management      = pkgs.angr-management;
  burpsuite            = pkgs.burpsuite;
  commix               = pkgs.commix;
  elfkickers           = pkgs.elfkickers;
  gdb                  = pkgs.gdb;
  gef                  = pkgs.gef;
  ghidra               = pkgs.ghidra;
  hash-identifier      = pkgs.hash-identifier;
  hashpump-partialhash = pkgs.hashpump;
  honggfuzz            = pkgs.honggfuzz;
  mitmproxy            = pkgs.mitmproxy;
  msieve               = pkgs.msieve;
  one_gadget           = pkgs.one_gadget;
  pdf-parser           = pkgs.pdf-parser;
  pkcrack              = pkgs.pkcrack;
  pwninit              = pkgs.pwninit;
  pwntools             = py.pwntools;
  qemu                 = pkgs.qemu;
  qiling               = py.qiling;      # currently marked broken upstream
  rappel               = pkgs.rappel;
  ropper               = py.ropper;
  "rp++"               = pkgs.rp;
  seccomp-tools        = pkgs.rubyPackages.seccomp-tools;
  sslsplit             = pkgs.sslsplit;
  stegsolve            = pkgs.stegsolve;
  tor-browser          = pkgs.tor-browser;
  valgrind             = pkgs.valgrind;
  volatility3          = pkgs.volatility3;
  xortool              = pkgs.xortool;
  zsteg                = pkgs.zsteg;
}
