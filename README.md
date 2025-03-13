# ctf-tools

This is a collection of setup scripts to create an install of various security research tools.
Of course, this isn't a hard problem, but it's really nice to have them in one place that's easily deployable to new machines and so forth.
The install-scripts for these tools are checked every once in a while, so things should hopefully have a decent chance of working!

Installers for the following tools are included:

| Category | Tool | Description |
|----------|------|-------------|
| binary | [angr](http://angr.io) | ![Last Build](https://img.shields.io/docker/v/ctftools/angr?label=built) Next-generation binary analysis engine from Shellphish. | <!--tool-->
| binary | [angr-management](http://angr.io) | ![Last Build](https://img.shields.io/docker/v/ctftools/angr-management?label=built) A GUI reverse engineering and decompilation tool. | <!--tool-->
| binary | [beef](https://github.com/beefproject/beef) | ![Last Build](https://img.shields.io/docker/v/ctftools/beef?label=built) Browser exploitation framework. | <!--tool-->
| binary | [crosstool](http://crosstool-ng.org/) | ![Last Build](https://img.shields.io/docker/v/ctftools/crosstool?label=built) Cross-compilers and cross-architecture tools. | <!--tool--><!--no-test-->
| binary | [cross2](http://kozos.jp/books/asm/asm.html) | ![Last Build](https://img.shields.io/docker/v/ctftools/cross2?label=built) A set of cross-compilation tools from a Japanese book on C. | <!--tool--><!--no-test-->
| binary | [decomp2dbg](https://github.com/mahaloz/decomp2dbg) | ![Last Build](https://img.shields.io/docker/v/ctftools/decomp2dbg?label=built)  A plugin to introduce interactive symbols into your debugger from your decompiler. | <!--tool-->
| binary | [elfkickers](http://www.muppetlabs.com/~breadbox/software/elfkickers.html) | ![Last Build](https://img.shields.io/docker/v/ctftools/elfkickers?label=built) A set of utilities for working with ELF files. | <!--tool-->
| binary | [elfparser](https://github.com/mentebinaria/elfparser-ng) | ![Last Build](https://img.shields.io/docker/v/ctftools/elfparser?label=built) Multiplatform CLI and GUI tool to show information about ELF files. | <!--tool-->
| binary | [evilize](http://www.mathstat.dal.ca/~selinger/md5collision/) | ![Last Build](https://img.shields.io/docker/v/ctftools/evilize?label=built) Tool to create MD5 colliding binaries | <!--tool-->
| binary | [gdb](http://www.gnu.org/software/gdb/) | ![Last Build](https://img.shields.io/docker/v/ctftools/gdb?label=built) Up-to-date gdb with python2 bindings. | <!--tool--><!--slow-test-->
| binary | [gef](https://github.com/hugsy/gef) | ![Last Build](https://img.shields.io/docker/v/ctftools/gef?label=built) Enhanced environment for gdb. | <!--tool-->
| binary | [ghidra](https://ghidra-sre.org/) | ![Last Build](https://img.shields.io/docker/v/ctftools/ghidra?label=built) Open-source reverse engineering and decompilation tool. | <!--tool-->
| binary | [honggfuzz](https://github.com/google/honggfuzz) | ![Last Build](https://img.shields.io/docker/v/ctftools/honggfuzz?label=built) A general-purpose, easy-to-use fuzzer with interesting analysis options. | <!--tool-->
| binary | [IDA Free](https://hex-rays.com/ida-free) | Decompilation and reversing tool (requires you to download it to ~/Downloads on your own!). | <!--tool--><!--no-test-->
| binary | [manticore](https://github.com/trailofbits/manticore) | ![Last Build](https://img.shields.io/docker/v/ctftools/manticore?label=built) Manticore is a prototyping tool for dynamic binary analysis, with support for symbolic execution, taint analysis, and binary instrumentation. | <!--tool-->
| binary | [one_gadget](https://github.com/david942j/one_gadget) | ![Last Build](https://img.shields.io/docker/v/ctftools/one_gadget?label=built) Magic gadget search for libc. | <!--tool--> 
| binary | [preeny](https://github.com/zardus/preeny) | ![Last Build](https://img.shields.io/docker/v/ctftools/preeny?label=built) A collection of helpful preloads (compiled for many architectures!). | <!--tool-->
| binary | [pwninit](https://github.com/io12/pwninit) | ![Last Build](https://img.shields.io/docker/v/ctftools/pwninit?label=built) Script to automate starting pwning challenges. | <!--tool-->
| binary | [pwndbg](https://github.com/pwndbg/pwndbg) | ![Last Build](https://img.shields.io/docker/v/ctftools/pwndbg?label=built) Enhanced environment for gdb. Especially for pwning. | <!--tool-->
| binary | [pwnsh](https://github.com/zardus/pwnsh) | ![Last Build](https://img.shields.io/docker/v/ctftools/pwnsh?label=built) Useful shell scripts for assembly, exploitation, etc. | <!--tool-->
| binary | [pwntools](https://github.com/Gallopsled/pwntools) | ![Last Build](https://img.shields.io/docker/v/ctftools/pwntools?label=built) Useful CTF utilities. | <!--tool-->
| binary | [qemu](http://qemu.org) | ![Last Build](https://img.shields.io/docker/v/ctftools/qemu?label=built) Latest version of qemu! | <!--tool--><!--slow-test-->
| binary | [qiling](https://github.com/qilingframework/qiling) | ![Last Build](https://img.shields.io/docker/v/ctftools/qiling?label=built) A dynamic binary instrumentation framework. | <!--tool-->
| binary | [qira](http://qira.me) | ![Last Build](https://img.shields.io/docker/v/ctftools/qira?label=built) Parallel, timeless debugger. | <!--tool--><!--slow-test-->
| binary | [rappel](https://github.com/yrp604/rappel) | ![Last Build](https://img.shields.io/docker/v/ctftools/rappel?label=built) A linux-based assembly REPL. | <!--tool-->
| binary | [ropper](https://github.com/sashs/Ropper) | ![Last Build](https://img.shields.io/docker/v/ctftools/ropper?label=built) Another gadget finder. | <!--tool-->
| binary | [rp++](https://github.com/0vercl0k/rp) | ![Last Build](https://img.shields.io/docker/v/ctftools/rp?label=built) Another gadget finder. | <!--tool-->
| binary | [seccomp-tools](https://github.com/david942j/seccomp-tools) | ![Last Build](https://img.shields.io/docker/v/ctftools/seccomp-tools?label=built) Provides powerful tools for seccomp analysis | <!--tool-->
| binary | [shellnoob](https://github.com/reyammer/shellnoob) | ![Last Build](https://img.shields.io/docker/v/ctftools/shellnoob?label=built) Shellcode writing helper. | <!--tool-->
| binary | [taintgrind](https://github.com/wmkhoo/taintgrind) | ![Last Build](https://img.shields.io/docker/v/ctftools/taintgrind?label=built) A valgrind taint analysis tool. | <!--tool--><!--failing-->
| binary | [valgrind](http://valgrind.org) | ![Last Build](https://img.shields.io/docker/v/ctftools/valgrind?label=built) A Dynamic Binary Instrumentation framework with some built-in tools. | <!--tool-->
| binary | [villoc](https://github.com/wapiflapi/villoc) | ![Last Build](https://img.shields.io/docker/v/ctftools/villoc?label=built) Visualization of heap operations. | <!--tool-->
| binary | [xrop](https://github.com/acama/xrop) | ![Last Build](https://img.shields.io/docker/v/ctftools/xrop?label=built) Gadget finder. | <!--tool--><!--failing-->
| forensics | [firmware-mod-kit](https://code.google.com/p/firmware-mod-kit/) | ![Last Build](https://img.shields.io/docker/v/ctftools/firmware-mod-kit?label=built) Tools for firmware packing/unpacking. | <!--tool-->
| forensics | [pdf-parser](http://blog.didierstevens.com/programs/pdf-tools/) | ![Last Build](https://img.shields.io/docker/v/ctftools/pdf-parser?label=built) Tool for digging in PDF files | <!--tool-->
| forensics | [peepdf](https://github.com/cert-ee/peepdf) | ![Last Build](https://img.shields.io/docker/v/ctftools/peepdf?label=built) Powerful Python tool to analyze PDF documents. | <!--tool-->
| forensics | [scrdec18](https://gist.github.com/bcse/1834878) | ![Last Build](https://img.shields.io/docker/v/ctftools/scrdec18?label=built) A decoder for encoded Windows Scripts. | <!--tool-->
| forensics | [volatility](https://github.com/volatilityfoundation/volatility) | ![Last Build](https://img.shields.io/docker/v/ctftools/volatility?label=built) Analyzer for system memory dumps (classic python2 version; requires python2 tool). | <!--tool-->
| forensics | [volatility3](https://github.com/volatilityfoundation/volatility3) | ![Last Build](https://img.shields.io/docker/v/ctftools/volatility3?label=built) Analyzer for system memory dumps (latest version). | <!--tool-->
| crypto | [codext](https://github.com/dhondta/python-codext) | ![Last Build](https://img.shields.io/docker/v/ctftools/codext?label=built) Python codecs extension featuring CLI tools for encoding/decoding anything including AI-based guessing mode. | <!--tool-->
| crypto | [cribdrag](https://github.com/SpiderLabs/cribdrag) | ![Last Build](https://img.shields.io/docker/v/ctftools/cribdrag?label=built) Interactive crib dragging tool (for crypto). | <!--tool-->
| crypto | [fastcoll](https://www.win.tue.nl/hashclash/) | ![Last Build](https://img.shields.io/docker/v/ctftools/fastcoll?label=built) An md5sum collision generator. | <!--tool-->
| crypto | [foresight](https://github.com/ALSchwalm/foresight) | ![Last Build](https://img.shields.io/docker/v/ctftools/foresight?label=built) A tool for predicting the output of random number generators. To run, launch "foresee". | <!--tool-->
| crypto | [featherduster](https://github.com/nccgroup/featherduster) | ![Last Build](https://img.shields.io/docker/v/ctftools/featherduster?label=built)  An automated, modular cryptanalysis tool. WARNING: needs python2 (which can be installed with ctf-tools). | <!--tool-->
| crypto | [galois](http://web.eecs.utk.edu/~plank/plank/papers/CS-07-593) | ![Last Build](https://img.shields.io/docker/v/ctftools/galois?label=built) A fast galois field arithmetic library/toolkit. | <!--tool-->
| crypto | [hashpump-partialhash](https://github.com/mheistermann/HashPump-partialhash) | ![Last Build](https://img.shields.io/docker/v/ctftools/hashpump-partialhash?label=built) Hashpump, supporting partially-unknown hashes. | <!--tool-->
| crypto | [hash-identifier](https://code.google.com/p/hash-identifier/source/checkout) | ![Last Build](https://img.shields.io/docker/v/ctftools/hash-identifier?label=built) Simple hash algorithm identifier. | <!--tool-->
| crypto | [libc-database](https://github.com/niklasb/libc-database) | ![Last Build](https://img.shields.io/docker/v/ctftools/libc-database?label=built) Build a database of libc offsets to simplify exploitation. | <!--tool--><!--slow-test-->
| crypto | [msieve](http://sourceforge.net/projects/msieve/) | ![Last Build](https://img.shields.io/docker/v/ctftools/msieve?label=built) Msieve is a C library implementing a suite of algorithms to factor large integers. | <!--tool-->
| crypto | [nonce-disrespect](https://github.com/nonce-disrespect/nonce-disrespect) | ![Last Build](https://img.shields.io/docker/v/ctftools/nonce-disrespect?label=built) Nonce-Disrespecting Adversaries: Practical Forgery Attacks on GCM in TLS. | <!--tool-->
| crypto | [pemcrack](https://github.com/robertdavidgraham/pemcrack) | ![Last Build](https://img.shields.io/docker/v/ctftools/pemcrack?label=built) SSL PEM file cracker. | <!--tool-->
| crypto | [pkcrack](https://www.unix-ag.uni-kl.de/~conrad/krypto/pkcrack.html) | ![Last Build](https://img.shields.io/docker/v/ctftools/pkcrack?label=built) PkZip encryption cracker. | <!--tool-->
| crypto | [reveng](http://reveng.sourceforge.net/) | ![Last Build](https://img.shields.io/docker/v/ctftools/reveng?label=built) CRC finder. | <!--tool-->
| crypto | [rsactftool](https://github.com/RsaCtfTool/RsaCtfTool) | ![Last Build](https://img.shields.io/docker/v/ctftools/rsactftool?label=built) RSA attack tool. | <!--tool-->
| crypto | [ssh_decoder](https://github.com/jjyg/ssh_decoder) | ![Last Build](https://img.shields.io/docker/v/ctftools/ssh_decoder?label=built) A tool for decoding ssh traffic. You will need `ruby1.8` from `https://launchpad.net/~brightbox/+archive/ubuntu/ruby-ng` to run this. Run with `ssh_decoder --help` for help, as running it with no arguments causes it to crash. | <!--tool-->
| crypto | [sslsplit](https://github.com/droe/sslsplit) | ![Last Build](https://img.shields.io/docker/v/ctftools/sslsplit?label=built) SSL/TLS MITM. | <!--tool-->
| crypto | [xortool](https://github.com/hellman/xortool) | ![Last Build](https://img.shields.io/docker/v/ctftools/xortool?label=built) XOR analysis tool. | <!--tool-->
| crypto | [yafu](http://sourceforge.net/projects/yafu/) | ![Last Build](https://img.shields.io/docker/v/ctftools/yafu?label=built) Automated integer factorization. | <!--tool-->
| web | [burpsuite](http://portswigger.net/burp) | ![Last Build](https://img.shields.io/docker/v/ctftools/burpsuite?label=built) Web proxy to do naughty web stuff. | <!--tool--><!--failing-->
| web | [commix](https://github.com/stasinopoulos/commix) | ![Last Build](https://img.shields.io/docker/v/ctftools/commix?label=built) Command injection and exploitation tool. | <!--tool-->
| web | [mitmproxy](https://mitmproxy.org/) | ![Last Build](https://img.shields.io/docker/v/ctftools/mitmproxy?label=built) CLI Web proxy and python library.  | <!--tool-->
| web | [subbrute](https://github.com/TheRook/subbrute) | ![Last Build](https://img.shields.io/docker/v/ctftools/subbrute?label=built) A DNS meta-query spider that enumerates DNS records, and subdomains. | <!--tool-->
| web | [webgrep](https://github.com/dhondta/webgrep) | ![Last Build](https://img.shields.io/docker/v/ctftools/webgrep?label=built) `grep` for Web pages, with JS deobfuscation, CSS unminifying and OCR on images. | <!--tool-->
| stego | [steganabara](http://www.caesum.com/handbook/stego.htm) | ![Last Build](https://img.shields.io/docker/v/ctftools/steganabara?label=built) Another image stenography solver. | <!--tool-->
| stego | [stegano-tools](https://github.com/dhondta/stegano-tools) | ![Last Build](https://img.shields.io/docker/v/ctftools/stegano-tools?label=built) A collection of text and image steganography tools (incl LSB, PVD, PIT). | <!--tool-->
| stego | [stegdetect](http://www.outguess.org/) | ![Last Build](https://img.shields.io/docker/v/ctftools/stegdetect?label=built) Stenography detection/breaking tool. | <!--tool-->
| stego | [stegsolve](http://www.caesum.com/handbook/stego.htm) | ![Last Build](https://img.shields.io/docker/v/ctftools/stegsolve?label=built) Image stenography solver. | <!--tool-->
| stego | [stegosaurus](https://github.com/AngelKitty/stegosaurus) | ![Last Build](https://img.shields.io/docker/v/ctftools/stegosaurus?label=built) A steganography tool for embedding arbitrary payloads in Python bytecode (pyc or pyo) files. | <!--tool-->
| stego | [zsteg](https://github.com/zed-0xff/zsteg) | ![Last Build](https://img.shields.io/docker/v/ctftools/zsteg?label=built) detect stegano-hidden data in PNG & BMP. | <!--tool-->
| misc | [jdgui](http://jd.benow.ca/) | ![Last Build](https://img.shields.io/docker/v/ctftools/jdgui?label=built) Java decompiler. | <!--tool-->
| misc | [python2](https://www.python.org/downloads/release/python-2718/) | ![Last Build](https://img.shields.io/docker/v/ctftools/python2?label=built) For when you really need it... | <!--tool-->
| misc | [social-analyzer](https://github.com/qeeqbox/social-analyzer) | ![Last Build](https://img.shields.io/docker/v/ctftools/social-analyzer?label=built) Social media reconnaisance tool... | <!--tool-->
| misc | [veles](https://codisec.com/veles/) | ![Last Build](https://img.shields.io/docker/v/ctftools/veles?label=built) Binary data analysis and visualization tool. | <!--tool-->
| misc | [xspy](https://gitlab.com/kalilinux/packages/xspy) | ![Last Build](https://img.shields.io/docker/v/ctftools/xspy?label=built) Tiny tool to spy on X sessions. | <!--tool-->

There are also some installers for non-CTF stuff to break the monotony!

| Category | Tool | Description |
|----------|------|-------------|
| game | [df](http://www.bay12games.com/dwarves/) | ![Last Build](https://img.shields.io/docker/v/ctftools/df?label=built) Dwarf Fortress! Something to help you relax after a CTF! | <!--tool-->
| web | [tor-browser](https://www.torproject.org/projects/torbrowser.html.en) | ![Last Build](https://img.shields.io/docker/v/ctftools/tor-browser?label=built) Useful when you need to hit a web challenge from different IPs. | <!--tool-->

## Usage

To use, do:

```bash
# set up the path
/path/to/ctf-tools/bin/manage-tools setup
source ~/.bashrc

# list the available tools
manage-tools list

# install gdb, allowing it to try to sudo install dependencies
manage-tools -s install gdb

# install pwntools, but don't let it sudo install dependencies
manage-tools install pwntools

# install qemu, but use "nice" to avoid degrading performance during compilation
manage-tools -n install qemu

# uninstall gdb
manage-tools uninstall gdb

# uninstall all tools
manage-tools uninstall all

# search for a tool
manage-tools search preload
```

Where possible, the tools keep the installs very self-contained (i.e., in to tool/ directory), and most uninstalls are just calls to `git clean` (**NOTE**, this is **NOT** careful; everything under the tool directory, including whatever you were working on, is blown away during an uninstall).

Python and Ruby tools are installed in a tool-specific virtual environment.
If you want to add other packages to this environment, look under the `ctf-tools/TOOL/pipx` or `ctf-tools/TOOL/gems` directories.

## Help!

Something not working?
I didn't write (almost) any of these tools, but hit up [the discord](https://discord.gg/KRcjyn4pBH) if you're desperate.
Maybe some kind soul will help!

## Dockerized Tools

### Prebuilt Tool Containers

You can get most of these tools in prebuilt containers from [https://hub.docker.com/r/ctftools](dockerhub).
For example:

```console
$ echo hi | docker run -i ctftools/taintgrind taintgrind --taint-stdin=yes /bin/cat
/home/ctf/tools/taintgrind/valgrind-3.21.0/build/bin/valgrind --tool=taintgrind --taint-stdin=yes /bin/cat
==8== Taintgrind, the taint analysis tool
==8== Copyright (C) 2010-2018, and GNU GPL'd, by Wei Ming Khoo.
==8== Using Valgrind-3.21.0 and LibVEX; rerun with -h for copyright info
==8== Command: /bin/cat
==8==
0xFFFFFFFF: _syscall_read | Read:3 | 0x0 | 4a5a000_unknownobj
hi
==8== 
```

### Building Your Own

You can build a docker image with:

```bash
git clone https://github.com/zardus/ctf-tools
cd ctf-tools
docker build -t ctf-tools --build-arg PREINSTALLED=some-tool .
```

And run it with:

```bash
docker run -it ctf-tools
```

The built image will have ctf-tools cloned and ready to go and your tool installed.

## Kali Linux

Kali Linux (Sana and Rolling), due to manually setting certain libraries to not use the latest version available (sometimes being out of date by years) causes some tools to not install at all, or fail in strange ways.
Overriding these libraries breaks other tools included in Kali so your only solution is to either live with some of Kali's tools being broken, use docker, or running another distribution separately such as Ubuntu.

## Adding Tools

To add a tool (say, named *toolname*), do the following:

1. Create a `toolname` directory.
2. Create an `install` script.
3. Add it to the readme.
4. (optional) if special uninstall steps are required, create an `uninstall` script.

### Install Scripts

The install script will be run with `$PWD` being `toolname`. It should install the tool into this directory, in as contained a manner as possible.
Ideally, full uninstallation should be possible with a `git clean`.

The install script should create a `bin` directory and put its executables there.
These executables will be automatically linked into the main `bin` directory for the repo.
They could be launched from any directory, so don't make assumptions about the location of `$0`!

## License

The individual tools are all licensed under their own licenses.
As for ctf-tools itself, it is licensed under BSD 2-Clause License.
If you find it useful, star it on github (https://github.com/zardus/ctf-tools).

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
