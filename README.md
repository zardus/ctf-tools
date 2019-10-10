# ctf-tools
[![Build Status](https://travis-ci.org/zardus/ctf-tools.svg?branch=master)](https://travis-ci.org/zardus/ctf-tools)
[![IRC](https://img.shields.io/badge/freenode-%23ctf--tools-green.svg)](http://webchat.freenode.net/?channels=#ctf-tools)

This is a collection of setup scripts to create an install of various security research tools.
Of course, this isn't a hard problem, but it's really nice to have them in one place that's easily deployable to new machines and so forth.
The install-scripts for these tools are checked regularly, the results can be found on [the build status page](_buildstatus/index.md).

Installers for the following tools are included:

| Category | Source | Tool | Description |
|----------|--------|------|-------------|
| binary | Directory | [afl](http://lcamtuf.coredump.cx/afl/) | State-of-the-art fuzzer. | <!--tool--> <!--times-out-->
| binary | Directory | [angr](http://angr.io) | Next-generation binary analysis engine from Shellphish. | <!--tool--> <!--no-test-->
| binary | Directory | [barf](https://github.com/programa-stic/barf-project) | Binary Analysis and Reverse-engineering Framework. | <!--tool--><!--times-out-->
| binary | Directory | [bindead](https://bitbucket.org/mihaila/bindead/wiki/Home) | A static analysis tool for binaries. | <!--tool--><!--failing-->
| binary | Library | [capstone](http://www.capstone-engine.org) | Multi-architecture disassembly framework. | <!--tool--><!--test-->
| binary | Directory | [checksec](https://github.com/slimm609/checksec.sh) | Check binary hardening settings. | <!--tool--><!--test-->
| binary | Directory | [codereason](https://github.com/trailofbits/codereason) | Semantic Binary Code Analysis Framework. | <!--tool--><!--failing-->
| binary | Directory | [crosstool-ng](http://crosstool-ng.org/) | Cross-compilers and cross-architecture tools. | <!--tool--><!--no-test-->
| binary | Directory | [cross2](http://kozos.jp/books/asm/asm.html) | A set of cross-compilation tools from a Japanese book on C. | <!--tool--><!--no-test-->
| binary | Directory | [elfkickers](http://www.muppetlabs.com/~breadbox/software/elfkickers.html) | A set of utilities for working with ELF files. | <!--tool--><!--test-->
| binary | Directory | [elfparser](http://www.elfparser.com/) | Quickly determine the capabilities of an ELF binary through static analysis. | <!--tool--><!--test-->
| binary | Directory | [evilize](http://www.mathstat.dal.ca/~selinger/md5collision/) | Tool to create MD5 colliding binaries | <!--tool--><!--test-->
| binary | Directory | [gdb](http://www.gnu.org/software/gdb/) | Up-to-date gdb with python2 bindings. | <!--tool--><!--failing-->
| binary | Directory | [gdb-heap](https://github.com/rogerhu/gdb-heap) | gdb extension for debugging heap issues. | <!--tool--><!--test-->
| binary | Directory | [gef](https://github.com/hugsy/gef) | Enhanced environment for gdb. | <!--tool--><!--no-test-->
| binary | Directory | [hongfuzz](https://github.com/google/honggfuzz) | A general-purpose, easy-to-use fuzzer with interesting analysis options. | <!--tool--><!--test-->
| binary | Library | [keystone](http://www.keystone-engine.org) | Lightweight multi-architecture assembler framework. | <!--tool--><!--test-->
| binary | Directory | [libheap](https://github.com/cloudburst/libheap) | gdb python library for examining the glibc heap (ptmalloc) | <!--tool--><!--no-test-->
| binary | Library | [lief](https://lief.quarkslab.com/) | Library to Instrument Executable Formats. | <!--tool--><!--test-->
| binary | Directory | [miasm](https://github.com/cea-sec/miasm) | Reverse engineering framework in Python. | <!--tool--> <!--test-->
| binary | Directory | [one_gadget](https://github.com/david942j/one_gadget) | Magic gadget search for libc. | <!--tool--> <!--test-->
| binary | Directory | [panda](https://github.com/moyix/panda) | Platform for Architecture-Neutral Dynamic Analysis. | <!--tool--><!--no-test-->
| binary | Directory | [pathgrind](https://github.com/codelion/pathgrind) | Path-based, symbolically-assisted fuzzer. | <!--tool--><!--failing-->
| binary | Directory | [peda](https://github.com/longld/peda) | Enhanced environment for gdb. | <!--tool--><!--test-->
| binary | Directory | [preeny](https://github.com/zardus/preeny) | A collection of helpful preloads (compiled for many architectures!). | <!--tool--><!--no-test-->
| binary | Directory | [pwndbg](https://github.com/zachriggle/pwndbg) | Enhanced environment for gdb. Especially for pwning. | <!--tool--><!--no-test-->
| binary | Directory | [pwntools](https://github.com/Gallopsled/pwntools) | Useful CTF utilities. | <!--tool--><!--no-test-->
| binary | Directory | [python-pin](https://github.com/blankwall/Python_Pin) | Python bindings for pin. | <!--tool--><!--test-->
| binary | Directory | [qemu](http://qemu.org) | Latest version of qemu! | <!--tool--><!--times-out-->
| binary | Directory | [qira](http://qira.me) | Parallel, timeless debugger. | <!--tool--><!--times-out-->
| binary | Directory | [radare2](http://www.radare.org/) | Some crazy thing crowell likes. | <!--tool--><!--test-->
| binary | Directory | [rappel](https://github.com/yrp604/rappel) | A linux-based assembly REPL. | <!--tool--><!--test-->
| binary | Directory | [ropper](https://github.com/sashs/Ropper) | Another gadget finder. | <!--tool--><!--test-->
| binary | Directory | [rp++](https://github.com/0vercl0k/rp) | Another gadget finder. | <!--tool--><!--test-->
| binary | Directory | [rr](http://rr-project.org) | Record and Replay Debugging Framework | <!--tool--><!--test-->
| binary | Directory | [scratchabit](https://github.com/pfalcon/ScratchABit) | Easily retargetable and hackable interactive disassembler | <!--tool--><!--test-->
| binary | Directory | [scratchablock](https://github.com/pfalcon/ScratchABlock) | Yet another crippled decompiler project | <!--tool--><!--test-->
| binary | Directory | [seccomp-tools](https://github.com/david942j/seccomp-tools) | Provides powerful tools for seccomp analysis | <!--tool--><!--test-->
| binary | Directory | [shellnoob](https://github.com/reyammer/shellnoob) | Shellcode writing helper. | <!--tool--><!--test-->
| binary | Directory | [shellsploit](https://github.com/b3mb4m/shellsploit-framework) | Shellcode development kit. | <!--tool--><!--test-->
| binary | Directory | [snowman](https://github.com/yegord/snowman) | Cross-architecture decompiler. | <!--tool--><!--test-->
| binary | Directory | [taintgrind](https://github.com/wmkhoo/taintgrind) | A valgrind taint analysis tool. | <!--tool--><!--failing-->
| binary | Library | [unicorn](http://www.unicorn-engine.org) | Multi-architecture CPU emulator framework. | <!--tool--><!--test-->
| binary | Directory | [valgrind](http://valgrind.org) | A Dynamic Binary Instrumentation framework with some built-in tools. | <!--tool--><!--test-->
| binary | Directory | [villoc](https://github.com/wapiflapi/villoc) | Visualization of heap operations. | <!--tool--><!--test-->
| binary | Directory | [virtualsocket](https://github.com/antoniobianchi333/virtualsocket) | A nice library to interact with binaries. | <!--tool--><!--test-->
| binary | Directory | [wcc](https://github.com/endrazine/wcc) |  The Witchcraft Compiler Collection is a collection of compilation tools to perform binary black magic on the GNU/Linux and other POSIX platforms. | <!--tool--><!--no-test-->
| binary | Directory | [xrop](https://github.com/acama/xrop) | Gadget finder. | <!--tool--><!--failing-->
| binary | Directory | [manticore](https://github.com/trailofbits/manticore) | Manticore is a prototyping tool for dynamic binary analysis, with support for symbolic execution, taint analysis, and binary instrumentation. | <!--tool--><!--no-test-->
| forensics | Directory | [binwalk](https://github.com/devttys0/binwalk.git) | Firmware (and arbitrary file) analysis tool. | <!--tool--><!--test-->
| forensics | Directory | [dislocker](http://www.hsc.fr/ressources/outils/dislocker/) | Tool for reading Bitlocker encrypted partitions. | <!--tool--><!--test-->
| forensics | Directory | [exetractor](https://github.com/kholia/exetractor-clone) | Unpacker for packed Python executables. Supports PyInstaller and py2exe. | <!--tool--><!--test-->
| forensics | Directory | [firmware-mod-kit](https://code.google.com/p/firmware-mod-kit/) | Tools for firmware packing/unpacking. | <!--tool--><!--test-->
| forensics | apt | [foremost](http://foremost.sourceforge.net/) | File carver. | <!--deb-tool-->
| forensics | Directory | [pdf-parser](http://blog.didierstevens.com/programs/pdf-tools/) | Tool for digging in PDF files | <!--tool--><!--test-->
| forensics | Directory | [peepdf](https://github.com/jesparza/peepdf) | Powerful Python tool to analyze PDF documents. | <!--tool--><!--test-->
| forensics | Directory | [scrdec](https://gist.github.com/bcse/1834878) | A decoder for encoded Windows Scripts. | <!--tool--><!--test-->
| forensics | Directory | [testdisk](http://www.cgsecurity.org/wiki/TestDisk) | Testdisk and photorec for file recovery. | <!--tool--><!--test-->
| crypto | Directory | [cribdrag](https://github.com/SpiderLabs/cribdrag) | Interactive crib dragging tool (for crypto). | <!--tool--><!--test-->
| crypto | Directory | [fastcoll](https://www.win.tue.nl/hashclash/) | An md5sum collision generator. | <!--tool--><!--test-->
| crypto | Directory | [foresight](https://github.com/ALSchwalm/foresight) | A tool for predicting the output of random number generators. To run, launch "foresee". | <!--tool--><!--test-->
| crypto | Directory | [featherduster](https://github.com/nccgroup/featherduster) |  An automated, modular cryptanalysis tool. | <!--tool--><!--no-test-->
| crypto | Directory | [galois](http://web.eecs.utk.edu/~plank/plank/papers/CS-07-593) | A fast galois field arithmetic library/toolkit. | <!--tool--><!--test-->
| crypto | Directory | [hashkill](https://github.com/gat3way/hashkill) | Hash cracker. | <!--tool--><!--test-->
| crypto | Directory | [hashpump](https://github.com/bwall/HashPump) | A tool for performing hash length extension attaacks. | <!--tool--><!--test-->
| crypto | Directory | [hashpump-partialhash](https://github.com/mheistermann/HashPump-partialhash) | Hashpump, supporting partially-unknown hashes. | <!--tool--><!--test-->
| crypto | Directory | [hash-identifier](https://code.google.com/p/hash-identifier/source/checkout) | Simple hash algorithm identifier. | <!--tool--><!--test-->
| crypto | Directory | [libc-database](https://github.com/niklasb/libc-database) | Build a database of libc offsets to simplify exploitation. | <!--tool--><!--test-->
| crypto | Directory | [littleblackbox](https://github.com/devttys0/littleblackbox) | Database of private SSL/SSH keys for embedded devices. | <!--tool--><!--test-->
| crypto | Directory | [msieve](http://sourceforge.net/projects/msieve/) | Msieve is a C library implementing a suite of algorithms to factor large integers. | <!--tool--><!--test-->
| crypto | Directory | [nonce-disrespect](https://github.com/nonce-disrespect/nonce-disrespect) | Nonce-Disrespecting Adversaries: Practical Forgery Attacks on GCM in TLS. | <!--tool--><!--test-->
| crypto | Directory | [pemcrack](https://github.com/robertdavidgraham/pemcrack) | SSL PEM file cracker. | <!--tool--><!--test-->
| crypto | Directory | [pkcrack](https://www.unix-ag.uni-kl.de/~conrad/krypto/pkcrack.html) | PkZip encryption cracker. | <!--tool--><!--test-->
| crypto | Directory | [python-paddingoracle](https://github.com/mwielgoszewski/python-paddingoracle) | Padding oracle attack automation. | <!--tool--><!--test-->
| crypto | Directory | [reveng](http://reveng.sourceforge.net/) | CRC finder. | <!--tool--><!--test-->
| crypto | Directory | [ssh_decoder](https://github.com/jjyg/ssh_decoder) | A tool for decoding ssh traffic. You will need `ruby1.8` from `https://launchpad.net/~brightbox/+archive/ubuntu/ruby-ng` to run this. Run with `ssh_decoder --help` for help, as running it with no arguments causes it to crash. | <!--tool--><!--test-->
| crypto | Directory | [sslsplit](https://github.com/droe/sslsplit) | SSL/TLS MITM. | <!--tool--><!--test-->
| crypto | Directory | [xortool](https://github.com/hellman/xortool) | XOR analysis tool. | <!--tool--><!--test-->
| crypto | Directory | [yafu](http://sourceforge.net/projects/yafu/) | Automated integer factorization. | <!--tool--><!--test-->
| web | Directory | [burpsuite](http://portswigger.net/burp) | Web proxy to do naughty web stuff. | <!--tool--><!--failing-->
| web | Directory | [commix](https://github.com/stasinopoulos/commix) | Command injection and exploitation tool. | <!--tool--><!--test-->
| web | Directory | [dirb](http://dirb.sourceforge.net/) | Web path scanner. | <!--tool--><!--test-->
| web | Directory | [dirsearch](https://github.com/maurosoria/dirsearch) | Web path scanner. | <!--tool--><!--test-->
| web | Directory | [mitmproxy](https://mitmproxy.org/) | CLI Web proxy and python library.  | <!--tool--><!--no-test-->
| web | Directory | [sqlmap](http://sqlmap.org/) | SQL injection automation engine. | <!--tool--><!--test-->
| web | Directory | [subbrute](https://github.com/TheRook/subbrute) | A DNS meta-query spider that enumerates DNS records, and subdomains. | <!--tool--><!--test-->
| stego | apt | [pngtools](https://launchpad.net/ubuntu/+source/pngtools) | PNG's analysis tool. | <!--deb-tool-->
| stego | Directory | [sound-visualizer](http://www.sonicvisualiser.org/) | Audio file visualization. | <!--tool--><!--failing-->
| stego | Directory | [steganabara](http://www.caesum.com/handbook/stego.htm) | Another image stenography solver. | <!--tool--><!--test-->
| stego | Directory | [stegdetect](http://www.outguess.org/) | Stenography detection/breaking tool. | <!--tool--><!--test-->
| stego | Docker | [stego-toolkit](https://github.com/DominicBreuker/stego-toolkit) | A docker image with dozens of steg tools. | <!--tool--><!--no-test-->
| stego | Directory | [stegsolve](http://www.caesum.com/handbook/stego.htm) | Image stenography solver. | <!--tool--><!--test-->
| stego | Directory | [zsteg](https://github.com/zed-0xff/zsteg) | detect stegano-hidden data in PNG & BMP. | <!--tool--><!--no-test-->
| dsniff | apt | [dsniff](http://www.monkey.org/~dugsong/dsniff/) | Grabs passwords and other data from pcaps/network streams. | <!--deb-tool-->
| android | Directory | [apktool](https://ibotpeaches.github.io/Apktool/) | Dissect, dis-assemble, and re-pack Android APKs | <!--tool--><!--test-->
| android | Directory | [android-sdk](http://developer.android.com/sdk) | The android SDK (adb, emulator, etc). | <!--tool--><!--no-test-->
| misc | Directory | [xspy](http://git.kali.org/gitweb/?p=packages/xspy.git;a=summary) | Tiny tool to spy on X sessions. | <!--tool--><!--test-->
| misc | Directory | [z3](https://github.com/Z3Prover/z3) | Theorem prover from Microsoft Research. | <!--tool--><!--times-out-->
| misc | Directory | [jdgui](http://jd.benow.ca/) | Java decompiler. | <!--tool--><!--test-->
| misc | Directory | [veles](https://codisec.com/veles/) | Binary data analysis and visualization tool. | <!--tool--><!--test-->
| misc | Directory | [youtube-dl](https://yt-dl.org/) | Latest version of the popular youtube downloader. | <!--tool--><!--test-->

There are also some installers for non-CTF stuff to break the monotony!

| Category | Tool | Description |
|----------|------|-------------|
| C magic | [C-bind](https://github.com/zwimer/C-bind) | A library used to enable function binding in C! |
| game | [Dwarf Fortress](http://www.bay12games.com/dwarves/) | Something to help you relax after a CTF! | <!--tool-->
| pyvmmonitor | [pyvmmonitor](http://www.pyvmmonitor.com/) | PyVmMonitor is a profiler with a simple goal: being the best way to profile a Python program. | <!--tool--><!--test-->
| library collection | [single\_file\_libs](https://github.com/nothings/single_file_libs) | A large collection of useful single file include libraries written for C/C++ |
| dolphin | [sudolphin](https://sudolph.in/) | If your friend ever leaves their laptop unlocked, `curl -sSL sh.sudolph.in \| sh` then wait and see! |
| tor-browser | [tor-browser](https://www.torproject.org/projects/torbrowser.html.en) | Useful when you need to hit a web challenge from different IPs. | <!--tool--><!--test-->

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
One exception to this are python tools, which are installed using the `pip`
package manager if possible. A `ctftools` virtualenv is created during the
`manage-tools setup` command and can be accessed using the command
`workon ctftools`.

## Help!

Something not working?
I didn't write (almost) any of these tools, but hit up [#ctf-tools on freenode](http://webchat.freenode.net/?channels=#ctf-tools) if you're desperate.
Maybe some kind soul will help!

## Docker (version 1.7+)

By popular demand, a Dockerfile has been included.
You can build a docker image with:

```bash
git clone https://github.com/zardus/ctf-tools
cd ctf-tools
docker build -t ctf-tools .
```

And run it with:

```bash
docker run -it ctf-tools
```

The built image will have ctf-tools cloned and ready to go, but you will still need to install the tools themselves (see above).

Alternatively, you can also pull ctf-tools (with some tools preinstalled) from dockerhub:

```bash
docker run -it zardus/ctf-tools
```

## Vagrant

You can build a Vagrant VM with:

```bash
wget https://raw.githubusercontent.com/zardus/ctf-tools/master/Vagrantfile
vagrant plugin install vagrant-vbguest
vagrant up
```

And connect to it via:

```bash
vagrant ssh
```

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
