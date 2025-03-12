# ctf-tools

This is a collection of setup scripts to create an install of various security research tools.
Of course, this isn't a hard problem, but it's really nice to have them in one place that's easily deployable to new machines and so forth.
The install-scripts for these tools are checked every once in a while, so things should hopefully have a decent chance of working!

Installers for the following tools are included:

| Category | Source | Tool | Description |
|----------|--------|------|-------------|
| binary | Directory | [angr](http://angr.io) | Next-generation binary analysis engine from Shellphish. | <!--tool-->
| binary | Directory | [angr-management](http://angr.io) | A GUI reverse engineering and decompilation tool. | <!--tool-->
| binary | Directory | [crosstool-ng](http://crosstool-ng.org/) | Cross-compilers and cross-architecture tools. | <!--tool--><!--no-test-->
| binary | Directory | [cross2](http://kozos.jp/books/asm/asm.html) | A set of cross-compilation tools from a Japanese book on C. | <!--tool--><!--no-test-->
| binary | Directory | [decomp2dbg](https://github.com/mahaloz/decomp2dbg) |  A plugin to introduce interactive symbols into your debugger from your decompiler. | <!--tool-->
| binary | Directory | [elfkickers](http://www.muppetlabs.com/~breadbox/software/elfkickers.html) | A set of utilities for working with ELF files. | <!--tool-->
| binary | Directory | [elfparser](https://github.com/mentebinaria/elfparser-ng) | Multiplatform CLI and GUI tool to show information about ELF files. | <!--tool-->
| binary | Directory | [evilize](http://www.mathstat.dal.ca/~selinger/md5collision/) | Tool to create MD5 colliding binaries | <!--tool-->
| binary | Directory | [gdb](http://www.gnu.org/software/gdb/) | Up-to-date gdb with python2 bindings. | <!--tool--><!--slow-test-->
| binary | Directory | [gef](https://github.com/hugsy/gef) | Enhanced environment for gdb. | <!--tool-->
| binary | Directory | [honggfuzz](https://github.com/google/honggfuzz) | A general-purpose, easy-to-use fuzzer with interesting analysis options. | <!--tool-->
| binary | Directory | [IDA Free](https://hex-rays.com/ida-free) | Decompilation and reversing tool (requires you to download it to ~/Downloads on your own!). | <!--tool--><!--no-test-->
| binary | Directory | [one_gadget](https://github.com/david942j/one_gadget) | Magic gadget search for libc. | <!--tool--> 
| binary | Directory | [preeny](https://github.com/zardus/preeny) | A collection of helpful preloads (compiled for many architectures!). | <!--tool-->
| binary | Directory | [pwndbg](https://github.com/pwndbg/pwndbg) | Enhanced environment for gdb. Especially for pwning. | <!--tool-->
| binary | Directory | [pwnsh](https://github.com/zardus/pwnsh) | Useful shell scripts for assembly, exploitation, etc. | <!--tool-->
| binary | Directory | [pwntools](https://github.com/Gallopsled/pwntools) | Useful CTF utilities. | <!--tool-->
| binary | Directory | [qemu](http://qemu.org) | Latest version of qemu! | <!--tool--><!--slow-test-->
| binary | Directory | [qira](http://qira.me) | Parallel, timeless debugger. | <!--tool--><!--no-test-->
| binary | Directory | [rappel](https://github.com/yrp604/rappel) | A linux-based assembly REPL. | <!--tool-->
| binary | Directory | [ropper](https://github.com/sashs/Ropper) | Another gadget finder. | <!--tool-->
| binary | Directory | [rp++](https://github.com/0vercl0k/rp) | Another gadget finder. | <!--tool-->
| binary | Directory | [seccomp-tools](https://github.com/david942j/seccomp-tools) | Provides powerful tools for seccomp analysis | <!--tool-->
| binary | Directory | [shellnoob](https://github.com/reyammer/shellnoob) | Shellcode writing helper. | <!--tool-->
| binary | Directory | [taintgrind](https://github.com/wmkhoo/taintgrind) | A valgrind taint analysis tool. | <!--tool--><!--failing-->
| binary | Directory | [valgrind](http://valgrind.org) | A Dynamic Binary Instrumentation framework with some built-in tools. | <!--tool-->
| binary | Directory | [villoc](https://github.com/wapiflapi/villoc) | Visualization of heap operations. | <!--tool-->
| binary | Directory | [xrop](https://github.com/acama/xrop) | Gadget finder. | <!--tool--><!--failing-->
| binary | Directory | [manticore](https://github.com/trailofbits/manticore) | Manticore is a prototyping tool for dynamic binary analysis, with support for symbolic execution, taint analysis, and binary instrumentation. | <!--tool-->
| forensics | Directory | [firmware-mod-kit](https://code.google.com/p/firmware-mod-kit/) | Tools for firmware packing/unpacking. | <!--tool-->
| forensics | Directory | [pdf-parser](http://blog.didierstevens.com/programs/pdf-tools/) | Tool for digging in PDF files | <!--tool-->
| forensics | Directory | [peepdf](https://github.com/cert-ee/peepdf) | Powerful Python tool to analyze PDF documents. | <!--tool-->
| forensics | Directory | [scrdec18](https://gist.github.com/bcse/1834878) | A decoder for encoded Windows Scripts. | <!--tool-->
| crypto | Directory | [codext](https://github.com/dhondta/python-codext) | Python codecs extension featuring CLI tools for encoding/decoding anything including AI-based guessing mode. | <!--tool-->
| crypto | Directory | [cribdrag](https://github.com/SpiderLabs/cribdrag) | Interactive crib dragging tool (for crypto). | <!--tool-->
| crypto | Directory | [fastcoll](https://www.win.tue.nl/hashclash/) | An md5sum collision generator. | <!--tool-->
| crypto | Directory | [foresight](https://github.com/ALSchwalm/foresight) | A tool for predicting the output of random number generators. To run, launch "foresee". | <!--tool-->
| crypto | Directory | [featherduster](https://github.com/nccgroup/featherduster) |  An automated, modular cryptanalysis tool. WARNING: needs python2 (which can be installed with ctf-tools). | <!--tool--><!--no-test-->
| crypto | Directory | [galois](http://web.eecs.utk.edu/~plank/plank/papers/CS-07-593) | A fast galois field arithmetic library/toolkit. | <!--tool-->
| crypto | Directory | [hashpump-partialhash](https://github.com/mheistermann/HashPump-partialhash) | Hashpump, supporting partially-unknown hashes. | <!--tool-->
| crypto | Directory | [hash-identifier](https://code.google.com/p/hash-identifier/source/checkout) | Simple hash algorithm identifier. | <!--tool-->
| crypto | Directory | [libc-database](https://github.com/niklasb/libc-database) | Build a database of libc offsets to simplify exploitation. | <!--tool--><!--slow-test-->
| crypto | Directory | [msieve](http://sourceforge.net/projects/msieve/) | Msieve is a C library implementing a suite of algorithms to factor large integers. | <!--tool-->
| crypto | Directory | [nonce-disrespect](https://github.com/nonce-disrespect/nonce-disrespect) | Nonce-Disrespecting Adversaries: Practical Forgery Attacks on GCM in TLS. | <!--tool-->
| crypto | Directory | [pemcrack](https://github.com/robertdavidgraham/pemcrack) | SSL PEM file cracker. | <!--tool-->
| crypto | Directory | [pkcrack](https://www.unix-ag.uni-kl.de/~conrad/krypto/pkcrack.html) | PkZip encryption cracker. | <!--tool-->
| crypto | Directory | [reveng](http://reveng.sourceforge.net/) | CRC finder. | <!--tool-->
| crypto | Directory | [ssh_decoder](https://github.com/jjyg/ssh_decoder) | A tool for decoding ssh traffic. You will need `ruby1.8` from `https://launchpad.net/~brightbox/+archive/ubuntu/ruby-ng` to run this. Run with `ssh_decoder --help` for help, as running it with no arguments causes it to crash. | <!--tool-->
| crypto | Directory | [sslsplit](https://github.com/droe/sslsplit) | SSL/TLS MITM. | <!--tool-->
| crypto | Directory | [xortool](https://github.com/hellman/xortool) | XOR analysis tool. | <!--tool-->
| crypto | Directory | [yafu](http://sourceforge.net/projects/yafu/) | Automated integer factorization. | <!--tool-->
| web | Directory | [burpsuite](http://portswigger.net/burp) | Web proxy to do naughty web stuff. | <!--tool--><!--failing-->
| web | Directory | [commix](https://github.com/stasinopoulos/commix) | Command injection and exploitation tool. | <!--tool-->
| web | Directory | [mitmproxy](https://mitmproxy.org/) | CLI Web proxy and python library.  | <!--tool-->
| web | Directory | [subbrute](https://github.com/TheRook/subbrute) | A DNS meta-query spider that enumerates DNS records, and subdomains. | <!--tool-->
| web | Directory | [webgrep](https://github.com/dhondta/webgrep) | `grep` for Web pages, with JS deobfuscation, CSS unminifying and OCR on images. | <!--tool-->
| stego | Directory | [steganabara](http://www.caesum.com/handbook/stego.htm) | Another image stenography solver. | <!--tool-->
| stego | Directory | [stegano-tools](https://github.com/dhondta/stegano-tools) | A collection of text and image steganography tools (incl LSB, PVD, PIT). | <!--tool-->
| stego | Directory | [stegdetect](http://www.outguess.org/) | Stenography detection/breaking tool. | <!--tool-->
| stego | Directory | [stegsolve](http://www.caesum.com/handbook/stego.htm) | Image stenography solver. | <!--tool-->
| stego | Directory | [stegosaurus](https://github.com/AngelKitty/stegosaurus) | A steganography tool for embedding arbitrary payloads in Python bytecode (pyc or pyo) files. | <!--tool-->
| stego | Directory | [zsteg](https://github.com/zed-0xff/zsteg) | detect stegano-hidden data in PNG & BMP. | <!--tool-->
| misc | Directory | [xspy](https://gitlab.com/kalilinux/packages/xspy) | Tiny tool to spy on X sessions. | <!--tool-->
| misc | Directory | [jdgui](http://jd.benow.ca/) | Java decompiler. | <!--tool-->
| misc | Directory | [veles](https://codisec.com/veles/) | Binary data analysis and visualization tool. | <!--tool-->
| misc | Directory | [python2](https://www.python.org/downloads/release/python-2718/) | For when you really need it... | <!--tool-->

There are also some installers for non-CTF stuff to break the monotony!

| Category | Tool | Description |
|----------|------|-------------|
| C magic | [C-bind](https://github.com/zwimer/C-bind) | A library used to enable function binding in C! |
| game | [Dwarf Fortress](http://www.bay12games.com/dwarves/) | Something to help you relax after a CTF! |
| library collection | [single\_file\_libs](https://github.com/nothings/single_file_libs) | A large collection of useful single file include libraries written for C/C++ |
| dolphin | [sudolphin](https://sudolph.in/) | If your friend ever leaves their laptop unlocked, `curl -sSL sh.sudolph.in \| sh` then wait and see! |
| tor-browser | [tor-browser](https://www.torproject.org/projects/torbrowser.html.en) | Useful when you need to hit a web challenge from different IPs. |

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
I didn't write (almost) any of these tools, but hit up [#ctf-tools on freenode](http://webchat.freenode.net/?channels=#ctf-tools) if you're desperate.
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

Kali Linux (Sana and Rolling), due to manually setting certain libraries to not use the latest version available (sometimes being out of date by years) causes some tools to not install at all, or fail in strange ways. AFL and Panda comes to mind, in fact any tool that uses QEMU 2.30 will probably fail during compilation under Kali.
Overriding these libraries breaks other tools included in Kali so your only solution is to either live with some of Kali's tools being broken, or running another distribution separately such as Ubuntu.

Most tools aren't affected though.

## Adding Tools

To add a tool (say, named *toolname*), do the following:

1. Create a `toolname` directory.
2. Create an `install` script.
3. (optional) if special uninstall steps are required, create an `uninstall` script.

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
