# Porting status: ctf-tools → Nix flake

This repo was converted from per-distro shell `install` scripts to a Nix flake
where every tool is an individual package (`nix profile install .#<tool>`).
This file records how each tool is realized and any caveats, for reviewers.

Every tool listed below **builds**. There are no "print a message and exit"
stubs.

## Tools taken from nixpkgs (passthroughs)

Re-exported verbatim from nixpkgs (see `nix/passthrough.nix`) — 31 tools:

`angr` `angr-management` `burpsuite` `commix` `elfkickers` `gdb` `gef` `ghidra`
`hash-identifier` `hashpump-partialhash` `honggfuzz` `mitmproxy` `msieve`
`one_gadget` `pdf-parser` `pkcrack` `pwninit` `pwntools` `qemu` `qiling`
`rappel` `ropper` `rp++` `seccomp-tools` `sslsplit` `stegsolve` `tor-browser`
`valgrind` `volatility3` `xortool` `zsteg`

## Tools with hand-written derivations

45 tools under `nix/pkgs/<name>/default.nix`, each with sources pinned by hash.
All build and, where they produce a CLI, were run to confirm they work.

### Notable / non-obvious ones

- **python2** — a real CPython 2.7 (interpreter + pip + virtualenv 16.7.x),
  sourced from a pinned `nixos-23.05` nixpkgs input (the last release line with a
  maintained `python27`). It's the base the Python-2 tools build against.
- **volatility** — Volatility **2.6.1** (Python 2) built against `python27` with
  `distorm3` 3.4.4 (the last py2-compatible release, built inline) + pycrypto.
  `volatility --info` runs clean. (For new work use the `volatility3` passthrough.)
- **featherduster** — Python 2 build against `python27` (`ishell` built inline).
- **qira** — the Python-2 Flask frontend **and** the geohot/qemu QIRA tracer fork
  (built for all 7 targets). Verified tracing `/bin/ls` (473k instructions) with
  the web UI live. Caveats: the tracer uses QEMU's TCG interpreter (required by
  qira's instrumentation); `requests` is dropped (py3-only, unused on the launch
  path).
- **ida** — nonfree; can't be bundled. Shipped as an FHS wrapper (`buildFHSEnv`)
  that runs *your* IDA install (`IDA_HOME=/path/to/ida`) on Nix/NixOS.
- **cross2** — the 2006-era `binutils-2.21.1` + `gcc-3.4.6` + `newlib-1.20.0`
  toolchain, built from pinned sources (upstream book patches vendored under
  `nix/pkgs/cross2/patch/`).
- **crosstool** — pinned to the **crosstool-NG 1.28.0 release** (not a dev
  commit — master's in-progress config referenced an unpublished `gettext-0.26`,
  which broke every glibc source download). The `crosstool` output is the
  `ct-ng` driver; each crosstool-NG sample toolchain is its own output
  `crosstool-ng-<sample>`, built offline via a pinned fixed-output "sources"
  derivation feeding a sandboxed `ct-ng build`. ~77 samples are pinned and
  surfaced — bare-metal (newlib/picolibc/none) **and** Linux (glibc/uclibc/musl)
  targets — and each builds in the `toolchains` CI matrix. Add the remaining
  heavy/distro-specific samples with `pin-samples.sh` (run serially — GNU
  mirrors throttle parallel fetches), and pin from a host that can reach
  `ftp.gnu.org`: on a box that can't, the fetch silently falls back to other
  mirrors and produces a different (wrong) tarball set.

  Three things about the Nix sandbox that ct-ng does not expect, all handled in
  `ctng.nix` / `mk-toolchain.nix` — see the comments there before touching them:

  1. The stdenv exports the whole *host* binutils set (`AR`, `AS`, `LD`, `NM`,
     `OBJCOPY`, ...). ct-ng only guards `CC`/`CXX`/`CFLAGS`, so the rest leak
     into every sub-build and override the cross tools. This is what broke all
     the non-x86 glibc samples (glibc strips `libc_pic.os` with `$(OBJCOPY)`),
     mingw-w64's CRT (`BFD_RELOC_RVA` from the ELF assembler), the old-kernel
     `headers_install` samples, and `riscv64-multilib-elf`.
  2. ct-ng seeds a libc `.config` by copying a template that here lives in the
     read-only store, so the copy is unwritable and its `echo >> .config`
     fallback dies — this broke every uClibc sample.
  3. `CT_GetFile` treats a digest mismatch as fatal instead of moving to the
     next mirror, so one flaky mirror fails the whole download.
- **preeny** — builds both 64-bit **and** 32-bit i686 LD_PRELOAD modules (CTF
  binaries are frequently 32-bit), matching upstream's multi-arch build.
- **beef** — full Ruby app via `bundlerEnv` (gemset pinned).
- **manticore**, **peepdf**, **yafu** — Python 3 / prebuilt-binary builds that
  needed dependency/patching fixes.

### Known per-item caveats

- `crosstool-ng-avr` — source pins, but the toolchain build fails in avr-libc's
  configure with binutils 2.47 (an upstream incompatibility); left pinned to
  revisit.
- `crosstool-ng-arm-none-eabi` — builds, but its ~19-variant multilib libstdc++
  is very heavy.

## Distribution

CI (`.github/workflows/nix.yml`) builds every output and pushes to the
`ctftools` Cachix cache — the Nix-native replacement for the old per-tool Docker
Hub images.
