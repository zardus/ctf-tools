# ctf-tools
[![Build Status](https://travis-ci.org/zardus/ctf-tools.svg?branch=master)](https://travis-ci.org/zardus/ctf-tools)
[![IRC](https://img.shields.io/badge/freenode-%23ctf--tools-green.svg)](http://webchat.freenode.net/?channels=#ctf-tools)

This is a collection of setup scripts to create an install of various security research tools.
Of course, this isn't a hard problem, but it's really nice to have them in one place that's easily deployable to new machines and so forth.

Installers for the following tools are included:

| Category | Tool | Description |
|----------|------|-------------|
| binary | [afl](http://lcamtuf.coredump.cx/afl/) | State-of-the-art fuzzer. | <!--tool--> <!--test-->
| binary | [angr](http://angr.io) | Next-generation binary analysis engine from Shellphish. | <!--tool--> <!--no-test-->
| binary | [barf](https://github.com/programa-stic/barf-project) | Binary Analysis and Reverse-engineering Framework. | <!--tool--><!--times-out-->
| binary | [bindead](https://bitbucket.org/mihaila/bindead/wiki/Home) | A static analysis tool for binaries. | <!--tool--><!--failing-->
| binary | [checksec](https://github.com/slimm609/checksec.sh) | Check binary hardening settings. | <!--tool--><!--test-->
| binary | [codereason](https://github.com/trailofbits/codereason) | Semantic Binary Code Analysis Framework. | <!--tool--><!--failing-->
| binary | [crosstool-ng](http://crosstool-ng.org/) | Cross-compilers and cross-architecture tools. | <!--tool--><!--no-test-->
| binary | [cross2](http://kozos.jp/books/asm/asm.html) | A set of cross-compilation tools from a Japanese book on C. | <!--tool--><!--no-test-->
| binary | [elfkickers](http://www.muppetlabs.com/~breadbox/software/elfkickers.html) | A set of utilities for working with ELF files. | <!--tool--><!--test-->
| binary | [elfparser](http://www.elfparser.com/) | Quickly determine the capabilities of an ELF binary through static analysis. | <!--tool--><!--test-->
| binary | [evilize](http://www.mathstat.dal.ca/~selinger/md5collision/) | Tool to create MD5 colliding binaries | <!--tool--><!--test-->
| binary | [gdb](http://www.gnu.org/software/gdb/) | Up-to-date gdb with python2 bindings. | <!--tool--><!--failing-->
| binary | [panda](https://github.com/moyix/panda) | Platform for Architecture-Neutral Dynamic Analysis. | <!--tool--><!--no-test-->
| binary | [pathgrind](https://github.com/codelion/pathgrind) | Path-based, symbolically-assisted fuzzer. | <!--tool--><!--test-->
| binary | [peda](https://github.com/longld/peda) | Enhanced environment for gdb. | <!--tool--><!--test-->
| binary | [preeny](https://github.com/zardus/preeny) | A collection of helpful preloads (compiled for many architectures!). | <!--tool--><!--no-test-->
| binary | [pwntools](https://github.com/Gallopsled/pwntools) | Useful CTF utilities. | <!--tool--><!--no-test-->
| binary | [python-pin](https://github.com/blankwall/Python_Pin) | Python bindings for pin. | <!--tool--><!--test-->
| binary | [qemu](http://qemu.org) | Latest version of qemu! | <!--tool--><!--times-out-->
| binary | [qira](http://qira.me) | Parallel, timeless debugger. | <!--tool--><!--test-->
| binary | [radare2](http://www.radare.org/) | Some crazy thing crowell likes. | <!--tool--><!--test-->
| binary | [rp++](https://github.com/0vercl0k/rp) | Another gadget finder. | <!--tool--><!--test-->
| binary | [shellnoob](https://github.com/reyammer/shellnoob) | Shellcode writing helper. | <!--tool--><!--test-->
| binary | [shellsploit](https://github.com/b3mb4m/shellsploit-framework) | Shellcode development kit. | <!--tool--><!--test-->
| binary | [snowman](https://github.com/yegord/snowman) | Cross-architecture decompiler. | <!--tool--><!--test-->
| binary | [taintgrind](https://github.com/wmkhoo/taintgrind) | A valgrind taint analysis tool. | <!--tool--><!--test-->
| binary | [villoc](https://github.com/wapiflapi/villoc) | Visualization of heap operations. | <!--tool--><!--test-->
| binary | [virtualsocket](https://github.com/antoniobianchi333/virtualsocket) | A nice library to interact with binaries. | <!--tool--><!--test-->
| binary | [xrop](https://github.com/acama/xrop) | Gadget finder. | <!--tool--><!--failing-->
| forensics | [binwalk](https://github.com/devttys0/binwalk.git) | Firmware (and arbitrary file) analysis tool. | <!--tool--><!--test-->
| forensics | [dislocker](http://www.hsc.fr/ressources/outils/dislocker/) | Tool for reading Bitlocker encrypted partitions. | <!--tool--><!--test-->
| forensics | [exetractor](https://github.com/kholia/exetractor-clone) | Unpacker for packed Python executables. Supports PyInstaller and py2exe. | <!--tool--><!--test-->
| forensics | [firmware-mod-kit](https://code.google.com/p/firmware-mod-kit/) | Tools for firmware packing/unpacking. | <!--tool--><!--test-->
| forensics | [pdf-parser](http://blog.didierstevens.com/programs/pdf-tools/) | Tool for digging in PDF files | <!--tool--><!--test-->
| forensics | [scrdec](https://gist.github.com/bcse/1834878) | A decoder for encoded Windows Scripts. | <!--tool--><!--test-->
| forensics | [testdisk](http://www.cgsecurity.org/wiki/TestDisk) | Testdisk and photorec for file recovery. | <!--tool--><!--test-->
| crypto | [cribdrag](https://github.com/SpiderLabs/cribdrag) | Interactive crib dragging tool (for crypto). | <!--tool--><!--test-->
| crypto | [foresight](https://github.com/ALSchwalm/foresight) | A tool for predicting the output of random number generators. To run, launch "foresee". | <!--tool--><!--test-->
| crypto | [hashpump](https://github.com/bwall/HashPump) | A tool for performing hash length extension attaacks. | <!--tool--><!--test-->
| crypto | [hashpump-partialhash](https://github.com/mheistermann/HashPump-partialhash) | Hashpump, supporting partially-unknown hashes. | <!--tool--><!--test-->
| crypto | [hash-identifier](https://code.google.com/p/hash-identifier/source/checkout) | Simple hash algorithm identifier. | <!--tool--><!--test-->
| crypto | [littleblackbox](https://github.com/devttys0/littleblackbox) | Database of private SSL/SSH keys for embedded devices. | <!--tool--><!--test-->
| crypto | [msieve](http://sourceforge.net/projects/msieve/) | Msieve is a C library implementing a suite of algorithms to factor large integers. | <!--tool--><!--test-->
| crypto | [pemcrack](https://github.com/robertdavidgraham/pemcrack) | SSL PEM file cracker. | <!--tool--><!--test-->
| crypto | [pkcrack](https://www.unix-ag.uni-kl.de/~conrad/krypto/pkcrack.html) | PkZip encryption cracker. | <!--tool--><!--test-->
| crypto | [python-paddingoracle](https://github.com/mwielgoszewski/python-paddingoracle) | Padding oracle attack automation. | <!--tool--><!--test-->
| crypto | [reveng](http://reveng.sourceforge.net/) | CRC finder. | <!--tool--><!--test-->
| crypto | [ssh_decoder](https://github.com/jjyg/ssh_decoder) | A tool for decoding ssh traffic. You will need `ruby1.8` from `https://launchpad.net/~brightbox/+archive/ubuntu/ruby-ng` to run this. Run with `ssh_decoder --help` for help, as running it with no arguments causes it to crash. | <!--tool--><!--test-->
| crypto | [sslsplit](https://github.com/droe/sslsplit) | SSL/TLS MITM. | <!--tool--><!--test-->
| crypto | [xortool](https://github.com/hellman/xortool) | XOR analysis tool. | <!--tool--><!--test-->
| crypto | [yafu](http://sourceforge.net/projects/yafu/) | Automated integer factorization. | <!--tool--><!--test-->
| web | [burpsuite](http://portswigger.net/burp) | Web proxy to do naughty web stuff. | <!--tool--><!--failing-->
| web | [commix](https://github.com/stasinopoulos/commix) | Command injection and exploitation tool. | <!--tool--><!--test-->
| web | [dirs3arch](https://github.com/maurosoria/dirs3arch) | Web path scanner. | <!--tool--><!--test-->
| web | [sqlmap](http://sqlmap.org/) | SQL injection automation engine. | <!--tool--><!--test-->
| web | [subbrute](https://github.com/TheRook/subbrute) | A DNS meta-query spider that enumerates DNS records, and subdomains. | <!--tool--><!--test-->
| stego | [sound-visualizer](http://www.sonicvisualiser.org/) | Audio file visualization. | <!--tool--><!--failing-->
| stego | [steganabara](http://www.caesum.com/handbook/stego.htm) | Another image steganography solver. | <!--tool--><!--test-->
| stego | [stegdetect](http://www.outguess.org/) | Steganography detection/breaking tool. | <!--tool--><!--test-->
| stego | [stegsolve](http://www.caesum.com/handbook/stego.htm) | Image steganography solver. | <!--tool--><!--test-->
| android | [apktool](https://ibotpeaches.github.io/Apktool/) | Dissect, dis-assemble, and re-pack Android APKs | <!--tool--><!--test-->

There are also some installers for non-CTF stuff to break the monotony!

| Category | Tool | Description |
|----------|------|-------------|
| game | [Dwarf Fortress](http://www.bay12games.com/dwarves/) | Something to help you relax after a CTF! | <!--tool-->

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

# uninstall gdb
manage-tools uninstall gdb

# uninstall all tools
manage-tools uninstall all

# search for a tool
manage-tools search preload
```

Where possible, the tools keep the installs very self-contained (i.e., in to tool/ directory), and most uninstalls are just calls to `git clean` (**NOTE**, this is **NOT** careful; everything under the tool directory, including whatever you were working on, is blown away during an uninstall).
To support python dependencies, however, make sure to create a virtualenv before installing and using tools (i.e., `mkvirtualenv --system-site-packages ctf`. The `--system-site-packages` is there for easier reuse of apt-gotten python packages where necessary).

## Help!

Something not working?
I didn't write (almost) any of these tools, but hit up [#ctf-tools on freenode](http://webchat.freenode.net/?channels=#ctf-tools) if you're desperate.
Maybe some kind soul will help!

## Docker

By popular demand, a Dockerfile has been included.
You can build a docker image with:

```bash
git clone https://github.com/zardus/ctf-tools
docker build -t ctf-tools .
```

And run it with:

```bash
docker run -it ctf-tools
```

The built image will have ctf-tools cloned and ready to go, but you will still need to install the tools themselves (see above).

## Vagrant

You can build a Vagrant VM with:

```bash
wget https://raw.githubusercontent.com/zardus/ctf-tools/master/Vagrantfile
vagrant up
```

And connect to it via:

```bash
vagrant ssh
```

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
As for ctf-tools itself, it is "starware".
If you find it useful, star it on github (https://github.com/zardus/ctf-tools).

Good luck!

# See Also

There's a curated list of CTF tools, but without installers, here: https://github.com/apsdehal/awesome-ctf.

There's a Vagrant config with a lot of the bigger frameworks here: https://github.com/thebarbershopper/epictreasure.

## Tools in the official Debian/Ubuntu repos

These tools are present in the Debian or Ubuntu repos (in an adequately new version).
They're not included in ctf-tools, but are included here as notes for the author.

| Category | Package | Description | Package |
|----------|---------|-------------|---------|
| forensics | [foremost](http://foremost.sourceforge.net/) | File carver. | `foremost` | <!--deb-tool-->
| dsniff | [dsniff](http://www.monkey.org/~dugsong/dsniff/) | Grabs passwords and other data from pcaps/network streams. | dsniff | <!--deb-tool-->

## Tools with unofficial Debian/Ubuntu repos or debs

| Category | Package | Description | Repo/deb |
|----------|---------|-------------|----------|
| stego | [sound-visualizer](http://www.sonicvisualiser.org/) | Audio file visualization. | [deb](http://www.sonicvisualiser.org/download.html) | <!--deb-tool-->
