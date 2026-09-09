# ctf-tools

This is a Nix flake packaging various security research tools.
Of course, this isn't a hard problem, but it's really nice to have them in one place that's easily deployable to new machines and so forth.
CI evaluates the catalog and builds the repository-packaged x86_64 tools every day, so breakage should be caught quickly.

The following tools are included. The first table lists tools packaged in this repo (under `nix/pkgs/`); the second lists tools taken from nixpkgs.

## NIX??????

Long-time ctf-tools users might be surprised by this development, but it is a good development.
Nix provides isolated packaging and can be deployed into a dev/hack environment, locally into a user's home directory, or globally system/container-wide.
It also happily installs alongside your normal OS and package manager (e.g., ubuntu and apt) with zero interference.
Trust me, I was as skeptical as you are for years, but it is the way.

### Packaged in this repo

| Category | Tool | Description |
|----------|------|-------------|
| binary | [angr](http://angr.io) | Next-generation binary analysis engine from Shellphish. | <!--tool-->
| binary | [angr-management](http://angr.io) | A GUI reverse engineering and decompilation tool. | <!--tool-->
| binary | [beef](https://github.com/beefproject/beef) | ![Last Build](https://img.shields.io/docker/v/ctftools/beef?label=built) Browser exploitation framework. | <!--tool-->
| binary | [crosstool](http://crosstool-ng.org/) | ![Last Build](https://img.shields.io/docker/v/ctftools/crosstool?label=built) Cross-compilers and cross-architecture tools. | <!--tool-->
| binary | [cross2](http://kozos.jp/books/asm/asm.html) | A set of cross-compilation tools from a Japanese book on C. | <!--tool-->
| binary | [decomp2dbg](https://github.com/mahaloz/decomp2dbg) | ![Last Build](https://img.shields.io/docker/v/ctftools/decomp2dbg?label=built)  A plugin to introduce interactive symbols into your debugger from your decompiler. | <!--tool-->
| binary | [deepmage](https://github.com/mmiszczyk/deepmage) | Terminal hex editor for bit-level and non-octet-oriented data. | <!--tool-->
| binary | [elfparser](https://github.com/mentebinaria/elfparser-ng) | ![Last Build](https://img.shields.io/docker/v/ctftools/elfparser?label=built) Multiplatform CLI and GUI tool to show information about ELF files. | <!--tool-->
| binary | [evilize](http://www.mathstat.dal.ca/~selinger/md5collision/) | ![Last Build](https://img.shields.io/docker/v/ctftools/evilize?label=built) Tool to create MD5 colliding binaries | <!--tool-->
| binary | [forkever](https://github.com/haxkor/forkever) | Debugger with fork-based checkpoints for exploit development. | <!--tool-->
| binary | [ida](https://hex-rays.com/ida-free) | Decompilation and reversing tool (proprietary: you download it yourself — drop the Hex-Rays tarball in `~/Downloads`, or set `IDA_HOME` to an unpacked install). | <!--tool-->
| binary | [ida-pro-mcp](https://github.com/mrexodia/ida-pro-mcp) | MCP server that drives IDA Pro (headless via idalib, or attached to a running IDA; set up with `ida --activate-idalib`). | <!--tool-->
| binary | [kuna](https://github.com/Noelo-Lab/kuna) | An agent-first decompiler in Rust, originally ported from Ghidra's decompiler. | <!--tool-->
| binary | [manticore](https://github.com/trailofbits/manticore) | ![Last Build](https://img.shields.io/docker/v/ctftools/manticore?label=built) Manticore is a prototyping tool for dynamic binary analysis, with support for symbolic execution, taint analysis, and binary instrumentation. | <!--tool-->
| binary | [patchkit](https://github.com/lunixbochs/patchkit) | Python toolkit for patching ELF binaries. | <!--tool-->
| binary | [preeny](https://github.com/zardus/preeny) | ![Last Build](https://img.shields.io/docker/v/ctftools/preeny?label=built) A collection of helpful preloads (compiled for 64- and 32-bit x86). | <!--tool-->
| binary | [pwndbg](https://github.com/pwndbg/pwndbg) | ![Last Build](https://img.shields.io/docker/v/ctftools/pwndbg?label=built) Enhanced environment for gdb. Especially for pwning. | <!--tool-->
| binary | [pwnsh](https://github.com/zardus/pwnsh) | ![Last Build](https://img.shields.io/docker/v/ctftools/pwnsh?label=built) Useful shell scripts for assembly, exploitation, etc. | <!--tool-->
| binary | [qiling](https://github.com/qilingframework/qiling) | A dynamic binary instrumentation framework. Entry point is `qltool`. | <!--tool-->
| binary | [qira](http://qira.me) | ![Last Build](https://img.shields.io/docker/v/ctftools/qira?label=built) Parallel, timeless debugger. | <!--tool-->
| binary | [reko](https://github.com/uxmal/reko) | General-purpose machine-code decompiler. Entry point is `reko`. | <!--tool-->
| binary | [shellnoob](https://github.com/reyammer/shellnoob) | ![Last Build](https://img.shields.io/docker/v/ctftools/shellnoob?label=built) Shellcode writing helper. | <!--tool-->
| binary | [taintgrind](https://github.com/wmkhoo/taintgrind) | ![Last Build](https://img.shields.io/docker/v/ctftools/taintgrind?label=built) A valgrind taint analysis tool. Builds and runs, but upstream's IR translator aborts on many binaries (`tnt_translate: expr2vbits_Unop`). | <!--tool-->
| binary | [villoc](https://github.com/wapiflapi/villoc) | ![Last Build](https://img.shields.io/docker/v/ctftools/villoc?label=built) Visualization of heap operations. | <!--tool-->
| binary | [xrop](https://github.com/acama/xrop) | ![Last Build](https://img.shields.io/docker/v/ctftools/xrop?label=built) Gadget finder. | <!--tool-->
| mobile | [frick](https://github.com/iGio90/frick) | Interactive debugger built on Frida. | <!--tool-->
| forensics | [firmware-mod-kit](https://code.google.com/p/firmware-mod-kit/) | ![Last Build](https://img.shields.io/docker/v/ctftools/firmware-mod-kit?label=built) Tools for firmware packing/unpacking. | <!--tool-->
| forensics | [origami-pdf](https://github.com/gdelugre/origami) | Ruby framework and command-line tools for parsing and manipulating PDF files. | <!--tool-->
| forensics | [peepdf](https://github.com/cert-ee/peepdf) | ![Last Build](https://img.shields.io/docker/v/ctftools/peepdf?label=built) Powerful Python tool to analyze PDF documents. | <!--tool-->
| forensics | [scrdec18](https://gist.github.com/bcse/1834878) | ![Last Build](https://img.shields.io/docker/v/ctftools/scrdec18?label=built) A decoder for encoded Windows Scripts. | <!--tool-->
| forensics | [volatility](https://github.com/volatilityfoundation/volatility) | ![Last Build](https://img.shields.io/docker/v/ctftools/volatility?label=built) Analyzer for system memory dumps (classic Python 2 version with its runtime included). | <!--tool-->
| crypto | [codext](https://github.com/dhondta/python-codext) | ![Last Build](https://img.shields.io/docker/v/ctftools/codext?label=built) Python codecs extension featuring CLI tools for encoding/decoding anything including AI-based guessing mode. | <!--tool-->
| crypto | [cribdrag](https://github.com/SpiderLabs/cribdrag) | ![Last Build](https://img.shields.io/docker/v/ctftools/cribdrag?label=built) Interactive crib dragging tool (for crypto). | <!--tool-->
| crypto | [fastcoll](https://www.win.tue.nl/hashclash/) | ![Last Build](https://img.shields.io/docker/v/ctftools/fastcoll?label=built) An md5sum collision generator. | <!--tool-->
| crypto | [foresight](https://github.com/ALSchwalm/foresight) | ![Last Build](https://img.shields.io/docker/v/ctftools/foresight?label=built) A tool for predicting the output of random number generators. To run, launch "foresee". | <!--tool-->
| crypto | [featherduster](https://github.com/nccgroup/featherduster) | ![Last Build](https://img.shields.io/docker/v/ctftools/featherduster?label=built) An automated, modular cryptanalysis tool. Its Python 2 runtime is included in the package. | <!--tool-->
| crypto | [galois](http://web.eecs.utk.edu/~plank/plank/papers/CS-07-593) | ![Last Build](https://img.shields.io/docker/v/ctftools/galois?label=built) A fast galois field arithmetic library/toolkit. | <!--tool-->
| crypto | [hashpump-partialhash](https://github.com/mheistermann/HashPump-partialhash) | Hashpump, supporting partially-unknown hashes. | <!--tool-->
| crypto | [libc-database](https://github.com/niklasb/libc-database) | ![Last Build](https://img.shields.io/docker/v/ctftools/libc-database?label=built) Build a database of libc offsets to simplify exploitation. Ships the scripts only: run `libc-database-get all` once to populate the database. | <!--tool-->
| crypto | [nonce-disrespect](https://github.com/nonce-disrespect/nonce-disrespect) | ![Last Build](https://img.shields.io/docker/v/ctftools/nonce-disrespect?label=built) Nonce-Disrespecting Adversaries: Practical Forgery Attacks on GCM in TLS. | <!--tool-->
| crypto | [pemcrack](https://github.com/robertdavidgraham/pemcrack) | ![Last Build](https://img.shields.io/docker/v/ctftools/pemcrack?label=built) SSL PEM file cracker. | <!--tool-->
| crypto | [reveng](http://reveng.sourceforge.net/) | ![Last Build](https://img.shields.io/docker/v/ctftools/reveng?label=built) CRC finder. | <!--tool-->
| crypto | [rsactftool](https://github.com/RsaCtfTool/RsaCtfTool) | ![Last Build](https://img.shields.io/docker/v/ctftools/rsactftool?label=built) RSA attack tool. | <!--tool-->
| crypto | [ssh_decoder](https://github.com/jjyg/ssh_decoder) | ![Last Build](https://img.shields.io/docker/v/ctftools/ssh_decoder?label=built) A tool for decoding SSH traffic from hosts affected by the Debian OpenSSL PRNG bug. Its Ruby runtime is included. | <!--tool-->
| crypto | [yafu](http://sourceforge.net/projects/yafu/) | ![Last Build](https://img.shields.io/docker/v/ctftools/yafu?label=built) Automated integer factorization. | <!--tool-->
| web | [burpsuite](http://portswigger.net/burp) | Web proxy to do naughty web stuff. | <!--tool-->
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
| binary | [aflplusplus](https://aflplus.plus/) | Modern coverage-guided fuzzer. | <!--tool-->
| binary | [checksec](https://github.com/slimm609/checksec) | Reports executable hardening features. | <!--tool-->
| binary | [elfkickers](http://www.muppetlabs.com/~breadbox/software/elfkickers.html) | Utilities for manipulating ELF files. | <!--tool-->
| binary | [gdb](https://www.gnu.org/software/gdb/) | GDB with Python 3 scripting and support for many targets. | <!--tool-->
| binary | [gef](https://github.com/hugsy/gef) | Enhanced environment for GDB. | <!--tool-->
| binary | [ghidra](https://ghidra-sre.org/) | Open-source reverse engineering and decompilation tool. | <!--tool-->
| binary | [grap](https://github.com/QuoSecGmbH/grap) | Defines and matches graph patterns in binaries. | <!--tool-->
| binary | [honggfuzz](https://github.com/google/honggfuzz) | General-purpose security-oriented fuzzer. | <!--tool-->
| binary | [imhex](https://imhex.werwolv.net/) | Extensible graphical hex editor. | <!--tool-->
| binary | [one_gadget](https://github.com/david942j/one_gadget) | Finds one-shot code-execution gadgets in libc. | <!--tool-->
| binary | [poke](https://www.jemarch.net/poke) | Extensible editor for structured binary data. | <!--tool-->
| binary | [pwninit](https://github.com/io12/pwninit) | Automates preparing binary-exploitation challenges. | <!--tool-->
| binary | [pwntools](https://github.com/Gallopsled/pwntools) | Python framework and utilities for exploit development. | <!--tool-->
| binary | [qemu](https://www.qemu.org/) | Full-system and user-mode machine emulator. | <!--tool-->
| binary | [radare2](https://rada.re/n/) | Reverse-engineering framework and command-line toolkit. | <!--tool-->
| binary | [rappel](https://github.com/yrp604/rappel) | Linux assembly REPL. | <!--tool-->
| binary | [rizin](https://rizin.re/) | Reverse-engineering framework forked from radare2. | <!--tool-->
| binary | [ropper](https://github.com/sashs/Ropper) | ROP gadget finder and binary analysis utility. | <!--tool-->
| binary | [rp++](https://github.com/0vercl0k/rp) | Fast ROP gadget finder. | <!--tool-->
| binary | [rr](https://rr-project.org/) | Record-and-replay debugger. | <!--tool-->
| binary | [seccomp-tools](https://github.com/david942j/seccomp-tools) | Utilities for seccomp analysis. | <!--tool-->
| binary | [upx](https://upx.github.io/) | Executable packer and unpacker. | <!--tool-->
| binary | [valgrind](https://valgrind.org/) | Dynamic instrumentation framework and debugging tools. | <!--tool-->
| binary | [wcc](https://github.com/endrazine/wcc) | Witchcraft Compiler Collection for binary analysis. | <!--tool-->
| mobile | [apktool](https://apktool.org/) | Decodes and rebuilds Android APK resources. | <!--tool-->
| mobile | [dex2jar](https://github.com/pxb1988/dex2jar) | Tools for Android DEX and Java class files. | <!--tool-->
| mobile | [frida-tools](https://frida.re/) | Command-line tools for Frida dynamic instrumentation. | <!--tool-->
| mobile | [jadx](https://github.com/skylot/jadx) | Dex-to-Java decompiler with CLI and GUI frontends. | <!--tool-->
| forensics | [autopsy](https://www.autopsy.com/) | Graphical digital-forensics platform. | <!--tool-->
| forensics | [binwalk](https://github.com/ReFirmLabs/binwalk) | Firmware and embedded-file analysis tool. | <!--tool-->
| forensics | [dislocker](https://github.com/Aorimn/dislocker) | Reads BitLocker-encrypted volumes. | <!--tool-->
| forensics | [exiftool](https://exiftool.org/) | Reads and writes file metadata. | <!--tool-->
| forensics | [foremost](https://foremost.sourceforge.net/) | File carver based on headers and footers. | <!--tool-->
| forensics | [pdf-parser](https://blog.didierstevens.com/programs/pdf-tools/) | Inspects objects and streams in PDF files. | <!--tool-->
| forensics | [sleuthkit](https://www.sleuthkit.org/) | Filesystem and disk-image analysis toolkit. | <!--tool-->
| forensics | [testdisk](https://www.cgsecurity.org/wiki/TestDisk) | Partition recovery and file undelete tools. | <!--tool-->
| forensics | [volatility3](https://github.com/volatilityfoundation/volatility3) | Current memory-forensics framework. | <!--tool-->
| forensics | [yara](https://virustotal.github.io/yara/) | Pattern-matching engine for malware and forensic artifacts. | <!--tool-->
| crypto | [hash-identifier](https://github.com/blackploit/hash-identifier) | Identifies likely hash algorithms. | <!--tool-->
| crypto | [hashcat](https://hashcat.net/hashcat/) | GPU-accelerated password recovery tool. | <!--tool-->
| crypto | [hydra](https://github.com/vanhauser-thc/thc-hydra) | Parallel network-login cracker. | <!--tool-->
| crypto | [john](https://www.openwall.com/john/) | John the Ripper password cracker. | <!--tool-->
| crypto | [msieve](https://sourceforge.net/projects/msieve/) | Integer factorization library and application. | <!--tool-->
| crypto | [pkcrack](https://www.unix-ag.uni-kl.de/~conrad/krypto/pkcrack.html) | Classic PKZIP known-plaintext attack. | <!--tool-->
| crypto | [sage](https://www.sagemath.org/) | Mathematics system useful for cryptanalysis and algebra. | <!--tool-->
| crypto | [xortool](https://github.com/hellman/xortool) | Repeating-key XOR analysis tool. | <!--tool-->
| crypto | [z3](https://github.com/Z3Prover/z3) | SMT theorem prover and constraint solver. | <!--tool-->
| networking | [bettercap](https://www.bettercap.org/) | Network reconnaissance and attack framework. | <!--tool-->
| networking | [dsniff](https://www.monkey.org/~dugsong/dsniff/) | Network auditing and traffic-analysis tools. | <!--tool-->
| networking | [nmap](https://nmap.org/) | Network discovery and port scanner. | <!--tool-->
| networking | [socat](http://www.dest-unreach.org/socat/) | Bidirectional relay for sockets and many other streams. | <!--tool-->
| networking | [sslsplit](https://github.com/droe/sslsplit) | SSL/TLS interception proxy. | <!--tool-->
| networking | [tshark](https://www.wireshark.org/docs/man-pages/tshark.html) | Command-line packet analyzer from Wireshark. | <!--tool-->
| web | [commix](https://github.com/commixproject/commix) | Command-injection discovery and exploitation tool. | <!--tool-->
| web | [dirb](https://dirb.sourceforge.net/) | Web content scanner. | <!--tool-->
| web | [dirsearch](https://github.com/maurosoria/dirsearch) | Web path scanner. | <!--tool-->
| web | [feroxbuster](https://github.com/epi052/feroxbuster) | Fast recursive content-discovery tool. | <!--tool-->
| web | [ffuf](https://github.com/ffuf/ffuf) | Fast web fuzzer. | <!--tool-->
| web | [mitmproxy](https://mitmproxy.org/) | Interactive HTTP interception proxy and Python library. | <!--tool-->
| web | [nikto](https://github.com/sullo/nikto) | Web-server scanner. | <!--tool-->
| web | [sqlmap](https://sqlmap.org/) | SQL-injection detection and exploitation engine. | <!--tool-->
| web | [tor-browser](https://www.torproject.org/download/) | Tor-enabled browser bundle. | <!--tool-->
| web | [wfuzz](https://github.com/xmendez/wfuzz) | Web application fuzzer. | <!--tool-->
| web | [xsstrike](https://github.com/s0md3v/XSStrike) | Cross-site scripting detection and exploitation suite. | <!--tool-->
| stego | [pngtools](https://launchpad.net/ubuntu/+source/pngtools) | Utilities for inspecting PNG files. | <!--tool-->
| stego | [sonic-visualizer](https://www.sonicvisualiser.org/) | Audio visualization and analysis application. | <!--tool-->
| stego | [stegsolve](http://www.caesum.com/handbook/stego.htm) | Image steganography solver. | <!--tool-->
| stego | [zsteg](https://github.com/zed-0xff/zsteg) | Detects data hidden in PNG and BMP images. | <!--tool-->
| osint | [sherlock](https://github.com/sherlock-project/sherlock) | Finds accounts by username across social networks. | <!--tool-->

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
manage-tools list -t              # list generated cross-toolchains

manage-tools install all          # every catalogued tool
manage-tools install all-toolchains
manage-tools install everything   # catalog + toolchains
```

Tools install into your Nix profile, and uninstalling removes them cleanly.
The three aggregate names install as single profile entries, so Nix shares
common dependencies and does not activate a partial set if a build fails.
`manage-tools` prints Nix's download/build plan before installing an aggregate.
On ARM, `all` contains every supported catalog tool; the generated toolchain
aggregates are x86_64-only.

### Downloads outside Nix

Package inputs are downloaded by Nix and pinned by SHA-256, including the two
legacy plain-HTTP sources (`steganabara` and `pkcrack`'s fallback mirror). A
server or network attacker can make those fetches unavailable, but cannot make
Nix accept different bytes under the recorded hash.

The exceptions are:

- `libc-database-get all` downloads the multi-gigabyte libc corpus into the
  user's data directory after installation.
- IDA itself is downloaded by the user from Hex-Rays. The `ida` wrapper can
  unpack that local archive and activate the vendor's bundled `idapro` wheel;
  activation tries an offline install first, with PyPI only as a fallback if
  that wheel declares an unavailable dependency.
- Running the `crosstool` package's `ct-ng` driver directly downloads the
  sources selected by the user's configuration. The prebuilt
  `crosstool-ng-*` flake outputs instead fetch a hash-pinned source set during
  the Nix build and compile offline.

Network scanners and clients naturally contact targets when run; that is tool
operation, not package installation.

### Platform support

The ordinary package set is available on both `x86_64-linux` and
`aarch64-linux`. Packages that nixpkgs or their upstream binary releases mark
as unsupported are omitted from the ARM package set instead of making the
whole profile fail to evaluate.

The generated `cross2-*` and `crosstool-ng-*` toolchain outputs are x86_64-only.
ARM packages are evaluated by CI, but are not built or uploaded to the
size-limited ctftools Cachix cache; ARM users build repository-packaged tools
locally. Tools forwarded unchanged from nixpkgs can still substitute from
`cache.nixos.org` on either architecture.

### Cross-compiler toolchains (`cross2`, `crosstool`)

On x86_64, two of the tools are toolchain *builders* rather than single programs, so they
expose one output per target instead of one output overall. Install only the
target you need — each is an independent package.

**`crosstool`** is the [crosstool-NG](https://crosstool-ng.github.io/) `ct-ng`
driver, and *only* the driver — unlike the old shell tool, it puts no cross
compilers on your PATH. Installing `crosstool` gives you `ct-ng` itself, ready
to build your own toolchain from a config:

```bash
nix profile install github:zardus/ctf-tools#crosstool
ct-ng list-samples
```

The compilers themselves are separate outputs: 77 of crosstool-NG's 146 samples
are prebuilt as `crosstool-ng-<sample>`, so you can install a ready-made
toolchain (say, `arm-none-eabi-gcc`) instead of spending an hour building one:

```bash
# a bare-metal ARM toolchain: arm-none-eabi-gcc, -gdb, -objdump, ...
nix profile install github:zardus/ctf-tools#crosstool-ng-arm-none-eabi

# a full Linux/musl cross toolchain, with sysroot
nix profile install github:zardus/ctf-tools#crosstool-ng-aarch64-unknown-linux-musl

# see all of them (bare-metal newlib/picolibc plus Linux
# glibc/uClibc/musl, and the mingw-w64 Windows targets)
nix flake show github:zardus/ctf-tools | grep crosstool-ng-
```

The sample name is the crosstool-NG sample id with any character outside
`[a-zA-Z0-9_-]` replaced by `-` (so `x86_64-ubuntu16.04-linux-gnu` becomes
`crosstool-ng-x86_64-ubuntu16-04-linux-gnu`).

The other 69 samples that `ct-ng list-samples` prints have no
`crosstool-ng-*` output — build them yourself with `ct-ng <sample> && ct-ng
build`, or pin one as a flake output by running
`nix/pkgs/crosstool/pin-samples.sh` and folding the hash it prints into
`nix/pkgs/crosstool/hashes.nix` (anything in there is surfaced automatically).

**`cross2`** is the companion toolchain set for the
[kozos.jp assembly book](https://kozos.jp/books/asm/) — binutils 2.21.1 +
gcc 3.4.6 + newlib 1.20.0 (+ gdb 7.3.1 where it still builds, or just its CPU
simulator, `<target>-run`, where it does not), for 34
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

CI builds the x86_64 tools packaged in this repo and pushes them to a public [Cachix](https://cachix.org) cache, so x86_64 installs download prebuilt binaries instead of compiling.
Trusted Nix users pick this up automatically from the flake's `nixConfig`; otherwise run `cachix use ctftools` once (or pass `--accept-flake-config`).

ARM outputs are deliberately not pushed to this cache. Unchanged tools in the
"From nixpkgs" table use the official `cache.nixos.org` binary cache and do not
consume space in the ctftools cache. `dirsearch` is the exception on x86_64:
our setuptools compatibility override produces a distinct output, so CI caches
it alongside the tools packaged in this repository.

## Dockerized Tools

You can get the tools packaged in this repo in prebuilt x86_64 containers from [dockerhub](https://hub.docker.com/r/ctftools).
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

The old apt-only tool list has been fully migrated to Nix outputs.

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
