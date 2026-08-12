# Tools that already live in nixpkgs. Most are re-exported verbatim so that
# `nix profile install .#<tool>` works for them with zero maintenance on our
# side. Each attribute name matches the tool's directory name in this repo.
#
# A handful are no longer verbatim: they carry a thin local wrapper that puts a
# missing runtime dependency on PATH, restores a command name the pre-nix
# installer put on PATH, or re-enables a build feature that upstream's
# autodetection silently loses inside the Nix sandbox. Each one is commented
# below with what it repairs; the long-term fix for all of them is to land the
# same change in nixpkgs and shrink the entry back to a bare re-export.
#
# Validated present in nixpkgs-unstable (2026-08). If nixpkgs renames or drops
# one of these, move it into nix/pkgs/<tool>/default.nix as a real derivation --
# but then delete the entry here: flake.nix computes `passthrough // custom`, so
# a name defined in both places resolves to nix/pkgs and the attribute here
# becomes dead, misleading code.
{ pkgs }:

let
  inherit (pkgs) lib;
  py = pkgs.python3Packages;

  # nixpkgs pins `exes = [ "zsteg" ]`, which drops zsteg-mask, zsteg-reflow and
  # zpng -- the pre-nix installer symlinked every gem binstub onto PATH, so all
  # four were available. bundlerApp's *result* is not overridable, so the seam
  # is package.nix's `bundlerApp` argument.
  zstegExes = [ "zsteg" "zsteg-mask" "zsteg-reflow" "zpng" ];
  zstegUnwrapped = pkgs.zsteg.override (prev: {
    bundlerApp = args: prev.bundlerApp (args // { exes = zstegExes; });
  });
in
{
  # Restores `commix.py`, the only name the pre-nix installer put on PATH.
  # symlinkJoin rather than overrideAttrs so the nixpkgs build still substitutes
  # from cache.nixos.org; it drops meta/version unless they are passed through.
  commix = pkgs.symlinkJoin {
    name = "commix-${pkgs.commix.version}";
    paths = [ pkgs.commix ];
    postBuild = "ln -s commix $out/bin/commix.py";
    inherit (pkgs.commix) meta version;
  };

  elfkickers           = pkgs.elfkickers;

  # Deliberately *not* `.override { withGuile = true; }`. The pre-nix
  # gdb/install configured --with-guile=guile-2.2, and nixpkgs builds
  # --without-guile, so .scm scripting is a real (accepted) drop: nothing in
  # this repo ships Guile scripts, the override would force every user to
  # compile gdb from source instead of substituting it, and it would not reach
  # gef/pwndbg/decomp2dbg anyway (they pull stock pkgs.gdb). Python scripting
  # and --enable-targets=all, the parts we advertise, are already in this build.
  gdb                  = pkgs.gdb;

  gef                  = pkgs.gef;
  ghidra               = pkgs.ghidra;

  # `hash_id.py` was the only name the pre-nix installer put on PATH. postFixup,
  # not postInstall: it runs after wrapPythonPrograms, so the alias points at
  # the finished wrapper instead of being wrapped itself.
  hash-identifier = pkgs.hash-identifier.overrideAttrs (o: {
    postFixup = (o.postFixup or "") + ''
      ln -s hash-identifier $out/bin/hash_id.py
    '';
  });

  honggfuzz            = pkgs.honggfuzz;
  mitmproxy            = pkgs.mitmproxy;
  msieve               = pkgs.msieve;
  one_gadget           = pkgs.one_gadget;

  # Upstream ships `pdf-parser.py`; the pre-nix installer renamed it to
  # `pdf-parser`. Keep both. See the commix note on symlinkJoin and meta.
  pdf-parser = pkgs.symlinkJoin {
    name = "pdf-parser-${pkgs.pdf-parser.version}";
    paths = [ pkgs.pdf-parser ];
    postBuild = "ln -s pdf-parser.py $out/bin/pdf-parser";
    meta = pkgs.pdf-parser.meta // { mainProgram = "pdf-parser"; };
    inherit (pkgs.pdf-parser) version;
  };

  # Peter Conrad's server still serves this tarball, but — exactly like galois
  # (see nix/pkgs/galois) — it answers the CI runners' IP range with a refusal,
  # so `nix build .#default` goes red on `pkcrack` whenever cache.nixos.org has
  # evicted the built path and the source has to be fetched. Add FreeBSD's
  # ports distfiles mirror as a fallback: it serves the byte-identical tarball
  # (same sha256 nixpkgs already pins, re-listed here so the override is
  # self-contained and a drift shows up as a hash mismatch on our copy). The
  # upstream URL stays first, so nothing changes for anyone who can reach it.
  # overrideAttrs on src alone: the C build is untouched and still substitutes.
  pkcrack = pkgs.pkcrack.overrideAttrs (o: {
    src = pkgs.fetchurl {
      urls = [
        "https://www.unix-ag.uni-kl.de/~conrad/krypto/pkcrack/pkcrack-1.2.3.tar.gz"
        "http://distcache.freebsd.org/ports-distfiles/pkcrack-1.2.3.tar.gz"
      ];
      hash = "sha256-j0n6OHlio3oUyavVSQFnIaY0JREFv0uDfMcvC61BPTg=";
    };
  });

  # pwninit's whole point is patching the challenge binary to use the provided
  # libc/ld, and it does that by shelling out to `patchelf` (patch_bin.rs runs a
  # bare `Command::new("patchelf")`). nixpkgs wraps it with elfutils only and
  # keeps patchelf out of the closure entirely, so on a host without patchelf
  # the default code path exits with "patchelf failed to start". Wrapping the
  # finished nixpkgs binary rather than overriding postInstall keeps the Rust
  # build substitutable from cache.nixos.org.
  pwninit = pkgs.runCommand "pwninit-${pkgs.pwninit.version}"
    {
      nativeBuildInputs = [ pkgs.makeWrapper ];
      meta = pkgs.pwninit.meta // { mainProgram = "pwninit"; };
      inherit (pkgs.pwninit) version;
    }
    ''
      mkdir -p $out/bin
      makeWrapper ${lib.getExe pkgs.pwninit} $out/bin/pwninit \
        --prefix PATH : ${lib.makeBinPath [ pkgs.patchelf ]}
    '';

  pwntools             = py.pwntools;
  qemu                 = pkgs.qemu;
  rappel               = pkgs.rappel;
  ropper               = py.ropper;

  # nixpkgs installs the binary as `rp` (and sets mainProgram to match); `rp++`
  # was the only name pre-nix. Keep both. Plain runCommand rather than the
  # symlinkJoin used above because pkgs.rp's output is nothing but bin/rp, so
  # there is no other tree to carry over.
  "rp++" = pkgs.runCommand "rp++-${pkgs.rp.version}"
    {
      meta = pkgs.rp.meta // { mainProgram = "rp++"; };
      inherit (pkgs.rp) version;
    }
    ''
      mkdir -p $out/bin
      ln -s ${lib.getExe pkgs.rp} $out/bin/rp++
      ln -s ${lib.getExe pkgs.rp} $out/bin/rp
    '';

  seccomp-tools        = pkgs.rubyPackages.seccomp-tools;

  # sslsplit's GNUmakefile picks its NAT engines by wildcard-testing the literal
  # path /usr/include/linux/netfilter.h, which no buildInput can satisfy inside
  # the sandbox -- so the stock nixpkgs build reports "NAT engines: -" and every
  # transparent/TPROXY proxyspec aborts at startup, which is sslsplit's primary
  # mode. Pre-nix it built against a distro's linux-libc-dev and always got the
  # feature. Nothing else appends to FEATURES on the Linux path, so setting it
  # outright is safe.
  sslsplit = pkgs.sslsplit.overrideAttrs (o: {
    makeFlags = (o.makeFlags or [ ]) ++ [ "FEATURES=-DHAVE_NETFILTER" ];
  });

  stegsolve            = pkgs.stegsolve;
  tor-browser          = pkgs.tor-browser;
  valgrind             = pkgs.valgrind;
  volatility3          = pkgs.volatility3;
  xortool              = pkgs.xortool;

  # Two repairs in one derivation: expose all four binstubs (see zstegUnwrapped
  # above), and put file(1) on PATH -- zsteg runs `file` on every candidate by
  # default and otherwise dies with a raw Ruby backtrace (Errno::ENOENT out of
  # ZSteg::FileCmd#start!). makeWrapper against the original store paths, *not*
  # wrapProgram or symlinkJoin+wrapProgram: zsteg picks its CLI class from
  # File.basename($0), so a `.zsteg-wrapped` rename makes it
  # `require 'zsteg/cli/wrapped'` and die with a LoadError. --prefix rather than
  # --set so a user's own newer `file` still wins.
  zsteg = pkgs.runCommand "zsteg-${pkgs.zsteg.version}"
    {
      nativeBuildInputs = [ pkgs.makeWrapper ];
      meta = pkgs.zsteg.meta // { mainProgram = "zsteg"; };
      inherit (pkgs.zsteg) version;
    }
    ''
      mkdir -p $out/bin
      for exe in ${lib.escapeShellArgs zstegExes}; do
        makeWrapper ${zstegUnwrapped}/bin/$exe $out/bin/$exe \
          --prefix PATH : ${lib.makeBinPath [ pkgs.file ]}
      done
    '';
}
