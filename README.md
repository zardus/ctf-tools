# ctf-tools

This is a Nix flake packaging various security research tools.
Of course, this isn't a hard problem, but it's really nice to have them in one place that's easily deployable to new machines and so forth.
The packages are checked every once in a while, so things should hopefully have a decent chance of working!

The following tools are included. The first table lists tools packaged in this repo (under `nix/pkgs/`); the second lists tools re-exported from nixpkgs.

## NIX??????

Long-time ctf-tools users might be surprised by this development, but it is a good development.
Nix provides isolated packaging and can be deployed into a dev/hack environment, locally into a user's home directory, or globally system/container-wide.
It also happily installs alongside your normal OS and package manager (e.g., ubuntu and apt) with zero interference.
Trust me, I was as skeptical as you are for years, but it is the way.

### Packaged in this repo

| Category | Tool | Description |
|----------|------|-------------|
| binary | [beef](https://github.com/beefproject/beef) | ![Last Build](https://img.shields.io/docker/v/ctftools/beef?label=built) Browser exploitation framework. | <!--tool-->
| binary | [crosstool](http://crosstool-ng.org/) | ![Last Build](https://img.shields.io/docker/v/ctftools/crosstool?label=built) Cross-compilers and cross-architecture tools. | <!--tool--><!--no-test-->
| binary | [cross2](http://kozos.jp/books/asm/asm.html) | ![Last Build](https://img.shields.io/docker/v/ctftools/cross2?label=built) A set of cross-compilation tools from a Japanese book on C. | <!--tool--><!--no-test-->
| binary | [decomp2dbg](https://github.com/mahaloz/decomp2dbg) | ![Last Build](https://img.shields.io/docker/v/ctftools/decomp2dbg?label=built)  A plugin to introduce interactive symbols into your debugger from your decompiler. | <!--tool-->
| binary | [elfparser](https://github.com/mentebinaria/elfparser-ng) | ![Last Build](https://img.shields.io/docker/v/ctftools/elfparser?label=built) Multiplatform CLI and GUI tool to show information about ELF files. | <!--tool-->
| binary | [evilize](http://www.mathstat.dal.ca/~selinger/md5collision/) | ![Last Build](https://img.shields.io/docker/v/ctftools/evilize?label=built) Tool to create MD5 colliding binaries | <!--tool-->
| binary | [ida](https://hex-rays.com/ida-free) | Decompilation and reversing tool (requires you to download it to ~/Downloads on your own!). | <!--tool--><!--no-test-->
| binary | [manticore](https://github.com/trailofbits/manticore) | ![Last Build](https://img.shields.io/docker/v/ctftools/manticore?label=built) Manticore is a prototyping tool for dynamic binary analysis, with support for symbolic execution, taint analysis, and binary instrumentation. | <!--tool-->
| binary | [preeny](https://github.com/zardus/preeny) | ![Last Build](https://img.shields.io/docker/v/ctftools/preeny?label=built) A collection of helpful preloads (compiled for many architectures!). | <!--tool-->
| binary | [pwndbg](https://github.com/pwndbg/pwndbg) | ![Last Build](https://img.shields.io/docker/v/ctftools/pwndbg?label=built) Enhanced environment for gdb. Especially for pwning. | <!--tool-->
| binary | [pwnsh](https://github.com/zardus/pwnsh) | ![Last Build](https://img.shields.io/docker/v/ctftools/pwnsh?label=built) Useful shell scripts for assembly, exploitation, etc. | <!--tool-->
| binary | [qira](http://qira.me) | ![Last Build](https://img.shields.io/docker/v/ctftools/qira?label=built) Parallel, timeless debugger. | <!--tool--><!--slow-test-->
| binary | [shellnoob](https://github.com/reyammer/shellnoob) | ![Last Build](https://img.shields.io/docker/v/ctftools/shellnoob?label=built) Shellcode writing helper. | <!--tool-->
| binary | [taintgrind](https://github.com/wmkhoo/taintgrind) | ![Last Build](https://img.shields.io/docker/v/ctftools/taintgrind?label=built) A valgrind taint analysis tool. | <!--tool--><!--failing-->
| binary | [villoc](https://github.com/wapiflapi/villoc) | ![Last Build](https://img.shields.io/docker/v/ctftools/villoc?label=built) Visualization of heap operations. | <!--tool-->
| binary | [xrop](https://github.com/acama/xrop) | ![Last Build](https://img.shields.io/docker/v/ctftools/xrop?label=built) Gadget finder. | <!--tool--><!--failing-->
| forensics | [firmware-mod-kit](https://code.google.com/p/firmware-mod-kit/) | ![Last Build](https://img.shields.io/docker/v/ctftools/firmware-mod-kit?label=built) Tools for firmware packing/unpacking. | <!--tool-->
| forensics | [peepdf](https://github.com/cert-ee/peepdf) | ![Last Build](https://img.shields.io/docker/v/ctftools/peepdf?label=built) Powerful Python tool to analyze PDF documents. | <!--tool-->
| forensics | [scrdec18](https://gist.github.com/bcse/1834878) | ![Last Build](https://img.shields.io/docker/v/ctftools/scrdec18?label=built) A decoder for encoded Windows Scripts. | <!--tool-->
| forensics | [volatility](https://github.com/volatilityfoundation/volatility) | ![Last Build](https://img.shields.io/docker/v/ctftools/volatility?label=built) Analyzer for system memory dumps (classic python2 version; requires python2 tool). | <!--tool-->
| crypto | [codext](https://github.com/dhondta/python-codext) | ![Last Build](https://img.shields.io/docker/v/ctftools/codext?label=built) Python codecs extension featuring CLI tools for encoding/decoding anything including AI-based guessing mode. | <!--tool-->
| crypto | [cribdrag](https://github.com/SpiderLabs/cribdrag) | ![Last Build](https://img.shields.io/docker/v/ctftools/cribdrag?label=built) Interactive crib dragging tool (for crypto). | <!--tool-->
| crypto | [fastcoll](https://www.win.tue.nl/hashclash/) | ![Last Build](https://img.shields.io/docker/v/ctftools/fastcoll?label=built) An md5sum collision generator. | <!--tool-->
| crypto | [foresight](https://github.com/ALSchwalm/foresight) | ![Last Build](https://img.shields.io/docker/v/ctftools/foresight?label=built) A tool for predicting the output of random number generators. To run, launch "foresee". | <!--tool-->
| crypto | [featherduster](https://github.com/nccgroup/featherduster) | ![Last Build](https://img.shields.io/docker/v/ctftools/featherduster?label=built)  An automated, modular cryptanalysis tool. WARNING: needs python2 (which can be installed with ctf-tools). | <!--tool-->
| crypto | [galois](http://web.eecs.utk.edu/~plank/plank/papers/CS-07-593) | ![Last Build](https://img.shields.io/docker/v/ctftools/galois?label=built) A fast galois field arithmetic library/toolkit. | <!--tool-->
| crypto | [libc-database](https://github.com/niklasb/libc-database) | ![Last Build](https://img.shields.io/docker/v/ctftools/libc-database?label=built) Build a database of libc offsets to simplify exploitation. | <!--tool--><!--slow-test-->
| crypto | [nonce-disrespect](https://github.com/nonce-disrespect/nonce-disrespect) | ![Last Build](https://img.shields.io/docker/v/ctftools/nonce-disrespect?label=built) Nonce-Disrespecting Adversaries: Practical Forgery Attacks on GCM in TLS. | <!--tool-->
| crypto | [pemcrack](https://github.com/robertdavidgraham/pemcrack) | ![Last Build](https://img.shields.io/docker/v/ctftools/pemcrack?label=built) SSL PEM file cracker. | <!--tool-->
| crypto | [reveng](http://reveng.sourceforge.net/) | ![Last Build](https://img.shields.io/docker/v/ctftools/reveng?label=built) CRC finder. | <!--tool-->
| crypto | [rsactftool](https://github.com/RsaCtfTool/RsaCtfTool) | ![Last Build](https://img.shields.io/docker/v/ctftools/rsactftool?label=built) RSA attack tool. | <!--tool-->
| crypto | [ssh_decoder](https://github.com/jjyg/ssh_decoder) | ![Last Build](https://img.shields.io/docker/v/ctftools/ssh_decoder?label=built) A tool for decoding ssh traffic. You will need `ruby1.8` from `https://launchpad.net/~brightbox/+archive/ubuntu/ruby-ng` to run this. Run with `ssh_decoder --help` for help, as running it with no arguments causes it to crash. | <!--tool-->
| crypto | [yafu](http://sourceforge.net/projects/yafu/) | ![Last Build](https://img.shields.io/docker/v/ctftools/yafu?label=built) Automated integer factorization. | <!--tool-->
| web | [subbrute](https://github.com/TheRook/subbrute) | ![Last Build](https://img.shields.io/docker/v/ctftools/subbrute?label=built) A DNS meta-query spider that enumerates DNS records, and subdomains. | <!--tool-->
| web | [webgrep](https://github.com/dhondta/webgrep) | ![Last Build](https://img.shields.io/docker/v/ctftools/webgrep?label=built) `grep` for Web pages, with JS deobfuscation, CSS unminifying and OCR on images. | <!--tool-->
| stego | [steganabara](http://www.caesum.com/handbook/stego.htm) | ![Last Build](https://img.shields.io/docker/v/ctftools/steganabara?label=built) Another image stenography solver. | <!--tool-->
| stego | [stegano-tools](https://github.com/dhondta/stegano-tools) | ![Last Build](https://img.shields.io/docker/v/ctftools/stegano-tools?label=built) A collection of text and image steganography tools (incl LSB, PVD, PIT). | <!--tool-->
| stego | [stegdetect](http://www.outguess.org/) | ![Last Build](https://img.shields.io/docker/v/ctftools/stegdetect?label=built) Stenography detection/breaking tool. | <!--tool-->
| stego | [stegosaurus](https://github.com/AngelKitty/stegosaurus) | ![Last Build](https://img.shields.io/docker/v/ctftools/stegosaurus?label=built) A steganography tool for embedding arbitrary payloads in Python bytecode (pyc or pyo) files. | <!--tool-->
| misc | [jdgui](http://jd.benow.ca/) | ![Last Build](https://img.shields.io/docker/v/ctftools/jdgui?label=built) Java decompiler. | <!--tool-->
| misc | [python2](https://www.python.org/downloads/release/python-2718/) | ![Last Build](https://img.shields.io/docker/v/ctftools/python2?label=built) For when you really need it... | <!--tool-->
| misc | [social-analyzer](https://github.com/qeeqbox/social-analyzer) | ![Last Build](https://img.shields.io/docker/v/ctftools/social-analyzer?label=built) Social media reconnaissance tool... | <!--tool-->
| misc | [veles](https://codisec.com/veles/) | ![Last Build](https://img.shields.io/docker/v/ctftools/veles?label=built) Binary data analysis and visualization tool. | <!--tool-->
| misc | [xspy](https://gitlab.com/kalilinux/packages/xspy) | ![Last Build](https://img.shields.io/docker/v/ctftools/xspy?label=built) Tiny tool to spy on X sessions. | <!--tool-->
| game | [df](http://www.bay12games.com/dwarves/) | ![Last Build](https://img.shields.io/docker/v/ctftools/df?label=built) Dwarf Fortress! Something to help you relax after a CTF! | <!--tool-->

### From nixpkgs

| Category | Tool | Description |
|----------|------|-------------|
| binary | [angr](http://angr.io) | Next-generation binary analysis engine from Shellphish. | <!--tool-->
| binary | [angr-management](http://angr.io) | A GUI reverse engineering and decompilation tool. | <!--tool-->
| binary | [elfkickers](http://www.muppetlabs.com/~breadbox/software/elfkickers.html) | A set of utilities for working with ELF files. | <!--tool-->
| binary | [gdb](http://www.gnu.org/software/gdb/) | Up-to-date gdb with python2 bindings. | <!--tool--><!--slow-test-->
| binary | [gef](https://github.com/hugsy/gef) | Enhanced environment for gdb. | <!--tool-->
| binary | [ghidra](https://ghidra-sre.org/) | Open-source reverse engineering and decompilation tool. | <!--tool-->
| binary | [honggfuzz](https://github.com/google/honggfuzz) | A general-purpose, easy-to-use fuzzer with interesting analysis options. | <!--tool-->
| binary | [one_gadget](https://github.com/david942j/one_gadget) | Magic gadget search for libc. | <!--tool--> 
| binary | [pwninit](https://github.com/io12/pwninit) | Script to automate starting pwning challenges. | <!--tool-->
| binary | [pwntools](https://github.com/Gallopsled/pwntools) | Useful CTF utilities. | <!--tool-->
| binary | [qemu](http://qemu.org) | Latest version of qemu! | <!--tool--><!--slow-test-->
| binary | [qiling](https://github.com/qilingframework/qiling) | A dynamic binary instrumentation framework. | <!--tool-->
| binary | [rappel](https://github.com/yrp604/rappel) | A linux-based assembly REPL. | <!--tool-->
| binary | [ropper](https://github.com/sashs/Ropper) | Another gadget finder. | <!--tool-->
| binary | [rp++](https://github.com/0vercl0k/rp) | Another gadget finder. | <!--tool-->
| binary | [seccomp-tools](https://github.com/david942j/seccomp-tools) | Provides powerful tools for seccomp analysis | <!--tool-->
| binary | [valgrind](http://valgrind.org) | A Dynamic Binary Instrumentation framework with some built-in tools. | <!--tool-->
| forensics | [pdf-parser](http://blog.didierstevens.com/programs/pdf-tools/) | Tool for digging in PDF files | <!--tool-->
| forensics | [volatility3](https://github.com/volatilityfoundation/volatility3) | Analyzer for system memory dumps (latest version). | <!--tool-->
| crypto | [hashpump-partialhash](https://github.com/mheistermann/HashPump-partialhash) | Hashpump, supporting partially-unknown hashes. | <!--tool-->
| crypto | [hash-identifier](https://code.google.com/p/hash-identifier/source/checkout) | Simple hash algorithm identifier. | <!--tool-->
| crypto | [msieve](http://sourceforge.net/projects/msieve/) | Msieve is a C library implementing a suite of algorithms to factor large integers. | <!--tool-->
| crypto | [pkcrack](https://www.unix-ag.uni-kl.de/~conrad/krypto/pkcrack.html) | PkZip encryption cracker. | <!--tool-->
| crypto | [sslsplit](https://github.com/droe/sslsplit) | SSL/TLS MITM. | <!--tool-->
| crypto | [xortool](https://github.com/hellman/xortool) | XOR analysis tool. | <!--tool-->
| web | [burpsuite](http://portswigger.net/burp) | Web proxy to do naughty web stuff. | <!--tool--><!--failing-->
| web | [commix](https://github.com/stasinopoulos/commix) | Command injection and exploitation tool. | <!--tool-->
| web | [mitmproxy](https://mitmproxy.org/) | CLI Web proxy and python library.  | <!--tool-->
| stego | [stegsolve](http://www.caesum.com/handbook/stego.htm) | Image stenography solver. | <!--tool-->
| stego | [zsteg](https://github.com/zed-0xff/zsteg) | detect stegano-hidden data in PNG & BMP. | <!--tool-->
| web | [tor-browser](https://www.torproject.org/projects/torbrowser.html.en) | Useful when you need to hit a web challenge from different IPs. | <!--tool-->

## Usage

Every tool is a flake output. To use, do:

```bash
# install a tool into your Nix profile
nix profile install github:zardus/ctf-tools#gdb

# run a tool without installing it
nix run github:zardus/ctf-tools#ropper

# run a shell with a tool in it
nix shell github:zardus/ctf-tools#ropper

# list every available tool
nix flake show github:zardus/ctf-tools
```

A `bin/manage-tools` wrapper around `nix profile` is also provided, for the familiar CLI:

```bash
# (once) configure Nix + the binary cache
/path/to/ctf-tools/bin/manage-tools setup

manage-tools list                 # list the available tools
manage-tools install pwntools
manage-tools uninstall gdb
manage-tools search preload
```

Tools install into your Nix profile, and uninstalling removes them cleanly.

### Cross-compiler toolchains (`cross2`, `crosstool`)

Two of the tools are toolchain *builders* rather than single programs, so they
expose one output per target instead of one output overall. Install only the
target you need — each is an independent package.

**`crosstool`** is the [crosstool-NG](https://crosstool-ng.github.io/) `ct-ng`
driver. Installing `crosstool` gives you `ct-ng` itself, ready to build your own
toolchain from a config:

```bash
nix profile install github:zardus/ctf-tools#crosstool
ct-ng list-samples
```

Every crosstool-NG sample is *also* prebuilt as its own output, named
`crosstool-ng-<sample>`, so you can install a ready-made toolchain instead of
spending an hour building one:

```bash
# a bare-metal ARM toolchain: arm-none-eabi-gcc, -gdb, -objdump, ...
nix profile install github:zardus/ctf-tools#crosstool-ng-arm-none-eabi

# a full Linux/glibc cross toolchain, with sysroot
nix profile install github:zardus/ctf-tools#crosstool-ng-aarch64-unknown-linux-musl

# see all of them (77 samples: bare-metal newlib/picolibc plus
# Linux glibc/uClibc/musl, and the mingw-w64 Windows targets)
nix flake show github:zardus/ctf-tools | grep crosstool-ng-
```

The sample name is the crosstool-NG sample id with any character outside
`[a-zA-Z0-9_-]` replaced by `-` (so `x86_64-ubuntu16.04-linux-gnu` becomes
`crosstool-ng-x86_64-ubuntu16-04-linux-gnu`).

**`cross2`** is the companion toolchain set for the
[kozos.jp assembly book](https://kozos.jp/books/asm/) — binutils 2.21.1 +
gcc 3.4.6 + newlib 1.20.0 (+ gdb 7.3.1 where it still builds), for 34
mostly-retro bare-metal targets. Installing `cross2` gives you the book's six
"major architecture" toolchains (arm, h8300, i386, mips, powerpc, sh); the other
targets are individual `cross2-<target>` outputs:

```bash
# the major-architecture bundle
nix profile install github:zardus/ctf-tools#cross2

# or just one target, e.g. mmix or vax
nix profile install github:zardus/ctf-tools#cross2-mmix-elf
nix profile install github:zardus/ctf-tools#cross2-vax-netbsdelf
```

These are large, from-source gcc builds, so install them with the [binary
cache](#binary-cache) configured — otherwise Nix will build the whole toolchain
locally (tens of minutes to hours each).

## Help!

Something not working?
I didn't write (almost) any of these tools, but hit up [the discord](https://discord.gg/KRcjyn4pBH) if you're desperate.
Maybe some kind soul will help!

## Binary cache

CI builds the tools packaged in this repo and pushes them to a public [Cachix](https://cachix.org) cache, so installs download prebuilt binaries instead of compiling.
Trusted Nix users pick this up automatically from the flake's `nixConfig`; otherwise run `cachix use ctftools` once (or pass `--accept-flake-config`).

## Dockerized Tools

You can get the tools packaged in this repo in prebuilt containers from [dockerhub](https://hub.docker.com/r/ctftools).
For example:

```console
$ echo hi | docker run -i ctftools/taintgrind taintgrind --taint-stdin=yes /bin/cat
```

The images are generated by CI, which installs the tool into a `nixos/nix` base with `nix profile install`.

## Adding Tools

To add a tool (say, named *toolname*):

1. If it is already in nixpkgs, add a line to `nix/passthrough.nix`.
2. Otherwise, create `nix/pkgs/toolname/default.nix` — a `callPackage`-style derivation with its sources pinned by hash — and build it with `nix build .#toolname`.
3. Add it to the README.

The flake discovers `nix/pkgs/*` automatically; the output name is the directory name.

## License

The individual tools are all licensed under their own licenses.
As for ctf-tools itself, it is licensed under BSD 2-Clause License.
If you find it useful, star it on GitHub (https://github.com/zardus/ctf-tools).

Good luck!

# See Also

There's a curated list of CTF tools, but without installers, here: https://github.com/apsdehal/aWEsoMe-cTf.

There's a Vagrant config with a lot of the bigger frameworks here: https://github.com/thebarbershopper/epictreasure.

## Useful CTF tools in apt repos

As tools get officially packaged, we switch to just suggesting that you apt install them!

| Category | Source | Tool | Description |
|----------|--------|------|-------------|
| binary | apt | [aflplusplus](https://github.com/AFLplusplus/AFLplusplus) | State-of-the-art fuzzer. |
| binary | apt | [checksec](https://github.com/slimm609/checksec.sh) | Check binary hardening settings. |
| binary | apt | [radare2](http://www.radare.org/) | Some crazy thing crowell likes. |
| binary | apt | [rr](http://rr-project.org) | Record and Replay Debugging Framework |
| binary | apt | [wcc](https://github.com/endrazine/wcc) |  The Witchcraft Compiler Collection is a collection of compilation tools to perform binary black magic on the GNU/Linux and other POSIX platforms. |
| forensics | apt | [binwalk](https://github.com/ReFirmLabs/binwalk) | Firmware (and arbitrary file) analysis tool. |
| forensics | apt | [foremost](http://foremost.sourceforge.net/) | File carver. |
| forensics | apt | [dislocker](http://www.hsc.fr/ressources/outils/dislocker/) | Tool for reading Bitlocker encrypted partitions. |
| forensics | apt | [origami-pdf](http://github.com/gdelugre/origami) | PDF manipulator. |
| forensics | apt | [testdisk](http://www.cgsecurity.org/wiki/TestDisk) | Testdisk and photorec for file recovery. |
| web | apt | [dirb](http://dirb.sourceforge.net/) | Web path scanner. |
| web | apt | [dirsearch](https://github.com/maurosoria/dirsearch) | Web path scanner. |
| web | apt | [sqlmap](http://sqlmap.org/) | SQL injection automation engine. |
| stego | apt | [pngtools](https://launchpad.net/ubuntu/+source/pngtools) | PNG's analysis tool. |
| stego | apt | [sonic-visualizer](http://www.sonicvisualiser.org/) | Audio file visualization. |
| networking | apt | [dsniff](http://www.monkey.org/~dugsong/dsniff/) | Grabs passwords and other data from pcaps/network streams. |
| networking | apt | [bettercap](https://www.bettercap.org/) | Network shenanigans swiss army knife. |
| misc | apt | [z3](https://github.com/Z3Prover/z3) | Theorem prover from Microsoft Research. |
| osint | apt | [sherlock](https://github.com/sherlock-project/sherlock) | Tools for Hunt down social media accounts by username across 400+ social networks . |

## Useful CTF tools in docker images

Previously, this repository included some scripts that were wrappers around `docker pull`.
We trust that you can do that yourself :-)

| Category | Source | Tool | Description |
|----------|--------|------|-------------|
| binary | docker | [panda](https://github.com/panda-re/panda) | Platform for Architecture-Neutral Dynamic Analysis. |
| stego | Docker | [stego-toolkit](https://github.com/DominicBreuker/stego-toolkit) | A docker image with dozens of steg tools. |

## Useful CTF Libraries

Previously, this repository included library installers.
Because of how bespoke library install preferences are (e.g., unlike a tool, it's not clear if per-library venvs are a desired thing), we've stopped shipping them, and link them here for posterity.

| Category | Source | Tool | Description |
|----------|--------|------|-------------|
| binary | Library | [capstone](http://www.capstone-engine.org) | Multi-architecture disassembly framework. |
| binary | Library | [keystone](http://www.keystone-engine.org) | Lightweight multi-architecture assembler framework. |
| binary | Library | [lief](https://lief.quarkslab.com/) | Library to Instrument Executable Formats. |
| binary | Library | [miasm](https://github.com/cea-sec/miasm) | Reverse engineering framework in Python. |
| binary | Library | [unicorn](http://www.unicorn-engine.org) | Multi-architecture CPU emulator framework. |
| binary | Library | [virtualsocket](https://github.com/antoniobianchi333/virtualsocket) | A nice library to interact with binaries. |
| crypto | Library | [cryptanalib3](https://github.com/unicornsasfuel/cryptanalib3) |  The surviving core of featherduster cryptanalysis tool, updated for python3. |
| crypto | Library | [python-paddingoracle](https://github.com/mwielgoszewski/python-paddingoracle) | Padding oracle attack automation. |
