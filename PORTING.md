# Porting status: ctf-tools → Nix flake

This repo was converted from per-distro shell `install` scripts to a Nix flake
where every tool is an individual package (`nix profile install .#<tool>`).
This file records how each tool is realized and any caveats, for reviewers.

Every tool listed below **builds**. There are no "print a message and exit"
stubs. The hand-written derivations are built by CI on every push; the nixpkgs
passthroughs inherit upstream's state and are not rebuilt here (`cache.nixos.org`
already serves them), only checked for still resolving. See *Distribution*.

## Tools taken from nixpkgs (passthroughs)

Taken from nixpkgs (see `nix/passthrough.nix`) — 26 tools. Most are re-exported
verbatim; a few carry a thin local wrapper that restores a command name the
pre-nix installer put on PATH (`commix.py`, `hash_id.py`, `pdf-parser`, `rp++`)
or repairs a runtime/build gap, each commented in that file:

`commix` `elfkickers` `gdb` `gef` `ghidra` `hash-identifier` `honggfuzz`
`mitmproxy` `msieve` `one_gadget` `pdf-parser` `pkcrack` `pwninit` `pwntools`
`qemu` `rappel` `ropper` `rp++` `seccomp-tools` `sslsplit` `stegsolve`
`tor-browser` `valgrind` `volatility3` `xortool` `zsteg`

## Tools with hand-written derivations

51 tools under `nix/pkgs/<name>/default.nix`, each with sources pinned by hash.
All build and, where they produce a CLI, were run to confirm they work.

### Notable / non-obvious ones

- **angr** / **angr-management** — no longer nixpkgs passthroughs. nixpkgs'
  `python3Packages.angr` 9.2.193 does not build (its `angr.rustylib` extension
  needs setuptools-rust, and it pins archinfo/cle/pyvex `==9.2.193` while the
  same nixpkgs rev ships those at 9.2.154). `nix/pkgs/angr/python.nix` pins the
  whole angr family down to 9.2.154 — the release nixpkgs' pyvex/archinfo/cle
  and angr-management already sit on, and one that predates the Rust extension
  entirely. `angr` restores the two pre-nix commands `angr-python` and
  `angr-ipython`; `angr-management` reuses the same repaired interpreter.
- **qiling** — built from a pinned git tag (1.4.10) rather than the PyPI sdist,
  which has been stuck at 1.4.6 since 2023, and against `python312` rather than
  the default interpreter (its `python-fx` dependency does not survive python
  3.14's PEP 649 lazy annotations). The `examples/rootfs` git submodule, which
  every example emulates against, is fetched separately and symlinked into
  `$out/share/qiling/examples/rootfs`. Entry point is `qltool`.
- **hashpump-partialhash** — built from Martin Heistermann's fork (rev
  `b822764`), *not* nixpkgs' mainline `hashpump`. Only the fork has the
  `-u/--unknown` (partially-unknown leading hash bits) and `-z/--sig2` modes the
  README advertises; mainline rejects `-u`. An `installCheck` greps `--unknown`
  out of `-h`, so a silent regression back to mainline fails the build.
- **burpsuite** — nixpkgs ships Burp inside a bubblewrap FHS env, which dies
  with `bwrap: setting up uid map: Permission denied` wherever unprivileged user
  namespaces are restricted (the Ubuntu 24.04+ default,
  `kernel.apparmor_restrict_unprivileged_userns=1`). Burp is a plain JVM app, so
  we reuse nixpkgs' pinned jar + JDK and run `java -jar` directly; no bubblewrap
  in the closure. (Contrast `ida`, which genuinely needs `buildFHSEnv`.)
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
- **ida** — nonfree; can't be bundled. Shipped as a launcher that runs *your*
  IDA install, located via `IDA_HOME=/path/to/ida`, else `~/.idapro`, `~/ida*`,
  an `ida` already on `$PATH`, or a `~/Downloads/{ida,IDA}*.tar.?z` tarball it
  unpacks into `~/.cache/ctf-tools/ida` on first run (the pre-nix drop-in
  contract). `ida` dispatches between two launch modes: `ida-fhs`
  (`buildFHSEnv`/bubblewrap, required on NixOS, needs unprivileged user
  namespaces) and `ida-native` (plain exec with the same libraries behind the
  host's on `LD_LIBRARY_PATH`). It probes for a usable user namespace and falls
  back to native with a one-line hint on hosts that block them (Ubuntu 24.04+
  defaults to `kernel.apparmor_restrict_unprivileged_userns=1`, which affects
  *every* bwrap-based package here); force either mode with
  `CTF_TOOLS_IDA_MODE=fhs|native`. `ida --activate-idalib [--force]` reproduces
  the pre-nix `py-activate-idalib.py` step into a venv under
  `~/.local/share/ctf-tools/ida` — explicit and idempotent, not implicit on
  every start.
- **ida-pro-mcp** — the MCP server the pre-nix `ida/install` cloned, now its own
  output (`ida-pro-mcp --install` for the IDA plugin + MCP clients,
  `idalib-mcp` for headless). The `idapro` binding it needs for headless mode
  only exists inside a licensed IDA install and comes from
  `ida --activate-idalib`.
- **cross2** — the 2006-era `binutils-2.21.1` + `gcc-3.4.6` + `newlib-1.20.0`
  toolchain, built from pinned sources (upstream book patches vendored under
  `nix/pkgs/cross2/patch/`).
- **crosstool** — pinned to the **crosstool-NG 1.28.0 release** (not a dev
  commit — master's in-progress config referenced an unpublished `gettext-0.26`,
  which broke every glibc source download). The `crosstool` output is the
  `ct-ng` driver; each crosstool-NG sample toolchain is its own output
  `crosstool-ng-<sample>`, built offline via a pinned fixed-output "sources"
  derivation feeding a sandboxed `ct-ng build`. 77 of the 146 samples are pinned
  and surfaced — bare-metal (newlib/picolibc/none) **and** Linux
  (glibc/uclibc/musl) targets — and each builds in the `toolchains` CI matrix.
  The other 69 have no output; `ct-ng <sample>` still builds them locally. Add
  the remaining heavy/distro-specific samples with `pin-samples.sh` (run
  serially — GNU mirrors throttle parallel fetches), and pin from a host that
  can reach `ftp.gnu.org`: on a box that can't, the fetch falls back silently to
  other mirrors and produces a different (wrong) tarball set.

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
  4. There is no `/usr/bin/env` in the sandbox, so `#!/usr/bin/env` shebangs in
     extracted sources fail (gcc's riscv `multilib-generator`); shebangs are
     rewritten as each package is extracted.
  5. There is no `/bin/pwd`, which kernels up to 4.x hardcode in their top-level
     Makefile — this broke `headers_install` for every sample pinning an old
     kernel (centos7, ubuntu14.04/16.04, sparc-leon).
  6. `localedef` is built for the *build* machine and so compiles against the
     host's kernel headers; with headers newer than glibc expects, `sys/mount.h`
     and `linux/mount.h` both define `OPEN_TREE_CLONE` and glibc's default
     `-Werror` makes it fatal. That build now passes `--disable-werror`, as the
     target libc build already did.

  Note when debugging these locally: a Nix installation whose sandbox is
  degraded (no user namespaces, e.g. inside some containers) exposes the host's
  `/bin` and `/usr/bin` to builds, so all of the "missing path" failures above
  silently pass locally and only show up in CI. Check `ls /bin` inside a
  throwaway derivation before trusting a local reproduction.
- **preeny** — builds both 64-bit **and** 32-bit i686 LD_PRELOAD modules (CTF
  binaries are frequently 32-bit), matching upstream's own multi-arch build
  script. The pre-nix installer additionally rebuilt the modules once per
  `crosstool/bin/*-gcc` triple, but only for users who had separately installed
  `crosstool` first (CI and the published docker images shipped x86_64 + i686
  only). That opt-in cross matrix is not carried over; the cross toolchains
  themselves are still available as `crosstool-ng-<sample>` outputs.
- **beef** — full Ruby app via `bundlerEnv` (gemset pinned). BeEF insists on a
  writable application directory (it refuses to start until `config.yaml`'s
  password is changed, opens the sqlite DB at a cwd-relative path, and rebuilds
  the admin-UI JS bundle at startup), so `bin/beef` seeds a per-user copy of the
  app tree into `$BEEF_HOME` (default `$XDG_DATA_HOME/beef`) on first run and
  runs from there.
- **df** — Dwarf Fortress creates `save/` and `mods/` relative to its cwd, so
  `bin/dwarf_fortress` seeds a per-user copy of the game tree into `$DF_HOME`
  (default `$XDG_DATA_HOME/dwarf-fortress`) the same way. Delete that directory
  to reset to a stock install.
- **manticore**, **peepdf**, **yafu** — Python 3 / prebuilt-binary builds that
  needed dependency/patching fixes.

### Known per-item caveats

- `crosstool-ng-avr` — source pins, but the toolchain build fails in avr-libc's
  configure with binutils 2.47 (an upstream incompatibility); left pinned to
  revisit.
- `crosstool-ng-arm-none-eabi` — builds, but its ~19-variant multilib libstdc++
  is very heavy.
- **libc-database** — ships the scripts only. The upstream ctf-tools installer
  finished by running `libc-database-get all`, which downloads gigabytes from
  distro mirrors; a Nix build cannot do that, so the database starts empty and
  you must run `libc-database-get all` (or a single source, e.g.
  `libc-database-get ubuntu`) once before `libc-database-find` will match
  anything. The database lives in
  `${XDG_DATA_HOME:-$HOME/.local/share}/libc-database` and is shared across
  every working directory, matching the single checkout the old installer baked
  into its wrappers; set `$LIBC_DATABASE_PATH` to put it elsewhere. The query
  subcommands print a one-line hint while it is still empty.
- **villoc** — upstream's `tracers/pintool` is not built: it needs Intel Pin,
  which is nonfree and non-redistributable. `tracers/dynamorio` is not built
  either — DynamoRIO is not in nixpkgs, and that tracer's CMakeLists hard-fails
  without it. The supported input is ltrace output, which is villoc's primary
  documented workflow: `setarch x86_64 -R ltrace -o trace ./target` then
  `villoc trace out.html`.
- **taintgrind** — builds and installs cleanly, and its Valgrind tree now lives
  under `libexec/taintgrind` so it no longer collides with the `valgrind`
  passthrough. Upstream's IR translator is still incomplete, though: on many
  ordinary binaries it aborts with `the 'impossible' happened: tnt_translate:
  expr2vbits_Unop`. That predates the Nix conversion (the pre-nix README marked
  the tool failing) and is not something the packaging can fix.
- **decomp2dbg** — nixpkgs' gdb embeds its own Python, which cannot see this
  package's site-packages, so the gdb half is loaded via a sys.path-repairing
  shim: `source <decomp2dbg>/share/decomp2dbg/d2d.py` (the packaged
  `decomp2dbg --install` writes exactly that line into `~/.gdbinit`).

## Distribution

CI (`.github/workflows/nix.yml`) builds this repo's own derivations
(`.#ciTargets`), the heavy toolchain fleet (`.#ciToolchainTargets`) and the
`.#default` profile, and pushes them to the `ctftools` Cachix cache — the
Nix-native replacement for the old per-tool Docker Hub images.

Two things it deliberately does not build. The nixpkgs passthroughs:
`cache.nixos.org` already serves them, so CI only forces their `drvPath`s, which
catches a nixpkgs rename or removal arriving via a `flake.lock` bump. And
`burpsuite`: its jar is an unfree, non-redistributable PortSwigger download, and
everything CI builds is pushed to a public cache. The `cross2` bundle is skipped
too, since its per-target derivations build in the toolchain matrix.

A `listcheck` job diffs the README's `<!--tool-->` rows against
`.#readmeTargets` (every hand-written derivation plus every passthrough), so the
tool table cannot drift away from what the flake actually ships.
