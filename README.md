# ctf-tools

A collection of security-research / CTF tools, packaged as a **Nix flake** — a
channel-style set of packages you install individually. On any machine with Nix
you can grab exactly the tools you want, prebuilt from a binary cache, with no
global state to pollute and no per-distro install scripts to babysit.

```sh
# run a tool without installing it
nix run github:zardus/ctf-tools#pwntools

# drop into a throwaway shell with several tools on PATH
nix shell github:zardus/ctf-tools#{gdb,pwntools,gef,ropper}

# install a tool into your profile
nix profile install github:zardus/ctf-tools#angr

# see everything available
nix flake show github:zardus/ctf-tools
```

## Binary cache

CI builds every tool and pushes it to a public [Cachix](https://cachix.org)
cache (`ctftools`), so installs download prebuilt binaries instead of compiling.
Trusted Nix users pick this up automatically from the flake's `nixConfig`;
otherwise enable it once with `cachix use ctftools`, or pass
`--accept-flake-config` on a command.

## manage-tools

`bin/manage-tools` is a thin wrapper over `nix profile`, for the familiar CLI.
Every verb maps to Nix underneath:

```sh
./bin/manage-tools list               # list all tools (straight from the flake)
./bin/manage-tools install qira       # nix profile install .#qira
./bin/manage-tools uninstall qira     # nix profile remove
./bin/manage-tools reinstall qira
./bin/manage-tools upgrade all        # update the flake + upgrade everything
./bin/manage-tools search stego       # search names + descriptions
```

## Tools

| Category | Tool | Description |
|----------|------|-------------|
| binary | [angr](http://angr.io) | Next-generation binary analysis engine from Shellphish. | <!--tool-->
| binary | [angr-management](http://angr.io) | A GUI reverse engineering and decompilation tool. | <!--tool-->
| binary | [beef](https://github.com/beefproject/beef) | Browser exploitation framework. | <!--tool-->
| binary | [crosstool](http://crosstool-ng.org/) | Cross-compilers and cross-architecture tools. | <!--tool--><!--no-test-->
| binary | [cross2](http://kozos.jp/books/asm/asm.html) | A set of cross-compilation tools from a Japanese book on C. | <!--tool--><!--no-test-->
| binary | [decomp2dbg](https://github.com/mahaloz/decomp2dbg) |  A plugin to introduce interactive symbols into your debugger from your decompiler. | <!--tool-->
| binary | [elfkickers](http://www.muppetlabs.com/~breadbox/software/elfkickers.html) | A set of utilities for working with ELF files. | <!--tool-->
| binary | [elfparser](https://github.com/mentebinaria/elfparser-ng) | Multiplatform CLI and GUI tool to show information about ELF files. | <!--tool-->
| binary | [evilize](http://www.mathstat.dal.ca/~selinger/md5collision/) | Tool to create MD5 colliding binaries | <!--tool-->
| binary | [gdb](http://www.gnu.org/software/gdb/) | Up-to-date gdb with python2 bindings. | <!--tool--><!--slow-test-->
| binary | [gef](https://github.com/hugsy/gef) | Enhanced environment for gdb. | <!--tool-->
| binary | [ghidra](https://ghidra-sre.org/) | Open-source reverse engineering and decompilation tool. | <!--tool-->
| binary | [honggfuzz](https://github.com/google/honggfuzz) | A general-purpose, easy-to-use fuzzer with interesting analysis options. | <!--tool-->
| binary | [ida](https://hex-rays.com/ida-free) | Decompilation and reversing tool (requires you to download it to ~/Downloads on your own!). | <!--tool--><!--no-test-->
| binary | [manticore](https://github.com/trailofbits/manticore) | Manticore is a prototyping tool for dynamic binary analysis, with support for symbolic execution, taint analysis, and binary instrumentation. | <!--tool-->
| binary | [one_gadget](https://github.com/david942j/one_gadget) | Magic gadget search for libc. | <!--tool--> 
| binary | [preeny](https://github.com/zardus/preeny) | A collection of helpful preloads (compiled for many architectures!). | <!--tool-->
| binary | [pwninit](https://github.com/io12/pwninit) | Script to automate starting pwning challenges. | <!--tool-->
| binary | [pwndbg](https://github.com/pwndbg/pwndbg) | Enhanced environment for gdb. Especially for pwning. | <!--tool-->
| binary | [pwnsh](https://github.com/zardus/pwnsh) | Useful shell scripts for assembly, exploitation, etc. | <!--tool-->
| binary | [pwntools](https://github.com/Gallopsled/pwntools) | Useful CTF utilities. | <!--tool-->
| binary | [qemu](http://qemu.org) | Latest version of qemu! | <!--tool--><!--slow-test-->
| binary | [qiling](https://github.com/qilingframework/qiling) | A dynamic binary instrumentation framework. | <!--tool-->
| binary | [qira](http://qira.me) | Parallel, timeless debugger. | <!--tool--><!--slow-test-->
| binary | [rappel](https://github.com/yrp604/rappel) | A linux-based assembly REPL. | <!--tool-->
| binary | [ropper](https://github.com/sashs/Ropper) | Another gadget finder. | <!--tool-->
| binary | [rp++](https://github.com/0vercl0k/rp) | Another gadget finder. | <!--tool-->
| binary | [seccomp-tools](https://github.com/david942j/seccomp-tools) | Provides powerful tools for seccomp analysis | <!--tool-->
| binary | [shellnoob](https://github.com/reyammer/shellnoob) | Shellcode writing helper. | <!--tool-->
| binary | [taintgrind](https://github.com/wmkhoo/taintgrind) | A valgrind taint analysis tool. | <!--tool--><!--failing-->
| binary | [valgrind](http://valgrind.org) | A Dynamic Binary Instrumentation framework with some built-in tools. | <!--tool-->
| binary | [villoc](https://github.com/wapiflapi/villoc) | Visualization of heap operations. | <!--tool-->
| binary | [xrop](https://github.com/acama/xrop) | Gadget finder. | <!--tool--><!--failing-->
| forensics | [firmware-mod-kit](https://code.google.com/p/firmware-mod-kit/) | Tools for firmware packing/unpacking. | <!--tool-->
| forensics | [pdf-parser](http://blog.didierstevens.com/programs/pdf-tools/) | Tool for digging in PDF files | <!--tool-->
| forensics | [peepdf](https://github.com/cert-ee/peepdf) | Powerful Python tool to analyze PDF documents. | <!--tool-->
| forensics | [scrdec18](https://gist.github.com/bcse/1834878) | A decoder for encoded Windows Scripts. | <!--tool-->
| forensics | [volatility](https://github.com/volatilityfoundation/volatility) | Analyzer for system memory dumps (classic python2 version; requires python2 tool). | <!--tool-->
| forensics | [volatility3](https://github.com/volatilityfoundation/volatility3) | Analyzer for system memory dumps (latest version). | <!--tool-->
| crypto | [codext](https://github.com/dhondta/python-codext) | Python codecs extension featuring CLI tools for encoding/decoding anything including AI-based guessing mode. | <!--tool-->
| crypto | [cribdrag](https://github.com/SpiderLabs/cribdrag) | Interactive crib dragging tool (for crypto). | <!--tool-->
| crypto | [fastcoll](https://www.win.tue.nl/hashclash/) | An md5sum collision generator. | <!--tool-->
| crypto | [foresight](https://github.com/ALSchwalm/foresight) | A tool for predicting the output of random number generators. To run, launch "foresee". | <!--tool-->
| crypto | [featherduster](https://github.com/nccgroup/featherduster) |  An automated, modular cryptanalysis tool. WARNING: needs python2 (which can be installed with ctf-tools). | <!--tool-->
| crypto | [galois](http://web.eecs.utk.edu/~plank/plank/papers/CS-07-593) | A fast galois field arithmetic library/toolkit. | <!--tool-->
| crypto | [hashpump-partialhash](https://github.com/mheistermann/HashPump-partialhash) | Hashpump, supporting partially-unknown hashes. | <!--tool-->
| crypto | [hash-identifier](https://code.google.com/p/hash-identifier/source/checkout) | Simple hash algorithm identifier. | <!--tool-->
| crypto | [libc-database](https://github.com/niklasb/libc-database) | Build a database of libc offsets to simplify exploitation. | <!--tool--><!--slow-test-->
| crypto | [msieve](http://sourceforge.net/projects/msieve/) | Msieve is a C library implementing a suite of algorithms to factor large integers. | <!--tool-->
| crypto | [nonce-disrespect](https://github.com/nonce-disrespect/nonce-disrespect) | Nonce-Disrespecting Adversaries: Practical Forgery Attacks on GCM in TLS. | <!--tool-->
| crypto | [pemcrack](https://github.com/robertdavidgraham/pemcrack) | SSL PEM file cracker. | <!--tool-->
| crypto | [pkcrack](https://www.unix-ag.uni-kl.de/~conrad/krypto/pkcrack.html) | PkZip encryption cracker. | <!--tool-->
| crypto | [reveng](http://reveng.sourceforge.net/) | CRC finder. | <!--tool-->
| crypto | [rsactftool](https://github.com/RsaCtfTool/RsaCtfTool) | RSA attack tool. | <!--tool-->
| crypto | [ssh_decoder](https://github.com/jjyg/ssh_decoder) | A tool for decoding ssh traffic. You will need `ruby1.8` from `https://launchpad.net/~brightbox/+archive/ubuntu/ruby-ng` to run this. Run with `ssh_decoder --help` for help, as running it with no arguments causes it to crash. | <!--tool-->
| crypto | [sslsplit](https://github.com/droe/sslsplit) | SSL/TLS MITM. | <!--tool-->
| crypto | [xortool](https://github.com/hellman/xortool) | XOR analysis tool. | <!--tool-->
| crypto | [yafu](http://sourceforge.net/projects/yafu/) | Automated integer factorization. | <!--tool-->
| web | [burpsuite](http://portswigger.net/burp) | Web proxy to do naughty web stuff. | <!--tool--><!--failing-->
| web | [commix](https://github.com/stasinopoulos/commix) | Command injection and exploitation tool. | <!--tool-->
| web | [mitmproxy](https://mitmproxy.org/) | CLI Web proxy and python library.  | <!--tool-->
| web | [subbrute](https://github.com/TheRook/subbrute) | A DNS meta-query spider that enumerates DNS records, and subdomains. | <!--tool-->
| web | [webgrep](https://github.com/dhondta/webgrep) | `grep` for Web pages, with JS deobfuscation, CSS unminifying and OCR on images. | <!--tool-->
| stego | [steganabara](http://www.caesum.com/handbook/stego.htm) | Another image stenography solver. | <!--tool-->
| stego | [stegano-tools](https://github.com/dhondta/stegano-tools) | A collection of text and image steganography tools (incl LSB, PVD, PIT). | <!--tool-->
| stego | [stegdetect](http://www.outguess.org/) | Stenography detection/breaking tool. | <!--tool-->
| stego | [stegsolve](http://www.caesum.com/handbook/stego.htm) | Image stenography solver. | <!--tool-->
| stego | [stegosaurus](https://github.com/AngelKitty/stegosaurus) | A steganography tool for embedding arbitrary payloads in Python bytecode (pyc or pyo) files. | <!--tool-->
| stego | [zsteg](https://github.com/zed-0xff/zsteg) | detect stegano-hidden data in PNG & BMP. | <!--tool-->
| misc | [jdgui](http://jd.benow.ca/) | Java decompiler. | <!--tool-->
| misc | [python2](https://www.python.org/downloads/release/python-2718/) | For when you really need it... | <!--tool-->
| misc | [social-analyzer](https://github.com/qeeqbox/social-analyzer) | Social media reconnaissance tool... | <!--tool-->
| misc | [veles](https://codisec.com/veles/) | Binary data analysis and visualization tool. | <!--tool-->
| misc | [xspy](https://gitlab.com/kalilinux/packages/xspy) | Tiny tool to spy on X sessions. | <!--tool-->


There are also some installers for non-CTF stuff to break the monotony!

| Category | Tool | Description |
|----------|------|-------------|
| game | [df](http://www.bay12games.com/dwarves/) | Dwarf Fortress! Something to help you relax after a CTF! | <!--tool-->
| web | [tor-browser](https://www.torproject.org/projects/torbrowser.html.en) | Useful when you need to hit a web challenge from different IPs. | <!--tool-->

A few tools need context:

- **ida** — IDA is nonfree and you provide the binary yourself. The `ida` output
  is an FHS wrapper that makes your existing IDA install run on Nix/NixOS; point
  it at your install with `IDA_HOME=/path/to/ida`.
- **python2** — CPython 2.7 (end-of-life, dropped from current nixpkgs) is
  provided from a pinned older nixpkgs, so the Python-2-only tools —
  `volatility` (the v2 series), `featherduster`, and `qira` — build against a
  real interpreter rather than being stubbed out. For modern memory forensics
  prefer `volatility3`.
- **crosstool** — the `crosstool` output is the `ct-ng` driver itself. Each
  crosstool-NG sample cross-toolchain is its own output named
  `crosstool-ng-<sample>` (e.g. `crosstool-ng-riscv32-unknown-elf`), built fully
  offline and cached. New samples are pinned via `nix/pkgs/crosstool/pin-samples.sh`.

## Adding a tool

Every tool is a plain Nix derivation under `nix/pkgs/<name>/default.nix`; the
flake discovers them automatically (the output name is the directory name).

1. If the tool is already in nixpkgs, just add a line to `nix/passthrough.nix`.
2. Otherwise write `nix/pkgs/<name>/default.nix` — a `callPackage`-style
   derivation with all sources pinned by hash — and build it with
   `nix build .#<name>`.

Python-2 tools receive the pinned py2 package set as a `pkgsPy2` argument.

## License

Released under the same terms as before; see [LICENSE](LICENSE). Individual
tools are distributed under their own upstream licenses.

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
