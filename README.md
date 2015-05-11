# ctf-tools

This is a collection of setup scripts to create an install of various security research tools.
Of course, this isn't a hard problem, but it's really nice to have them in one place that's easily deployable to new machines and so forth.
To use, do:

```bash
# set up the path
/path/to/ctf-tools/manage-tools setup
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
```

Where possible, the tools keep the installs very self-contained (i.e., in to tool/ directory), and most uninstalls are just calls to `git clean` (**NOTE**, this is **NOT** careful; everything under the tool directory, including whatever you were working on, is blown away during an uninstall).
To support python dependencies, however, make sure to create a virtualenv before installing and using tools (i.e., `mkvirtualenv ctf`).
Installers for the following tools are included:

| Category | Tool | Description |
|----------|------|-------------|
| binary | [afl](http://lcamtuf.coredump.cx/afl/) | State-of-the-art fuzzer. |
| binary | [checksec](https://github.com/slimm609/checksec.sh) | Check binary hardening settings. |
| binary | [crosstool-ng](http://crosstool-ng.org/) | Cross-compilers and cross-architecture tools. |
| binary | [gdb](http://www.gnu.org/software/gdb/) | Up-to-date gdb with python2 bindings. |
| binary | [peda](https://github.com/longld/peda) | Enhanced environment for gdb. |
| binary | [preeny](https://github.com/zardus/preeny) | A collection of helpful preloads (compiled for many architectures!). |
| binary | [villoc](https://github.com/wapiflapi/villoc) | Visualization of heap operations. |
| binary | [qemu](http://qemu.org) | Latest version of qemu! |
| binary | [pwntools](https://github.com/Gallopsled/pwntools) | Useful CTF utilities. |
| binary | [python-pin](https://github.com/blankwall/Python_Pin) | Python bindings for pin. |
| binary | [radare2](http://www.radare.org/) | Some crazy thing crowell likes. |
| binary | [shellnoob](https://github.com/reyammer/shellnoob) | Shellcode writing helper. |
| binary | [taintgrind](https://github.com/wmkhoo/taintgrind) | A valgrind taint analysis tool. |
| binary | [qira](http://qira.me) | Parallel, timeless debugger. |
| binary | [xrop](https://github.com/acama/xrop) | Gadget finder. |
| forensics | [binwalk](https://github.com/devttys0/binwalk.git) | Firmware (and arbitrary file) analysis tool. |
| forensics | [dislocker](http://www.hsc.fr/ressources/outils/dislocker/) | Tool for reading Bitlocker encrypted partitions. |
| forensics | [firmware-mod-kit](https://code.google.com/p/firmware-mod-kit/) | Tools for firmware packing/unpacking. |
| forensics | [testdisk](http://www.cgsecurity.org/wiki/TestDisk) | Testdisk and photorec for file recovery. |
| forensics | [pdf-parser](http://blog.didierstevens.com/programs/pdf-tools/) | Tool for digging in PDF files |
| crypto | [cribdrag](https://github.com/SpiderLabs/cribdrag) | Interactive crib dragging tool (for crypto). |
| crypto | [hashpump](https://github.com/bwall/HashPump) | A tool for performing hash length extension attaacks. |
| crypto | [hashpump-partialhash](https://github.com/mheistermann/HashPump-partialhash) | Hashpump, supporting partially-unknown hashes. |
| crypto | [hash-identifier](https://code.google.com/p/hash-identifier/source/checkout) | Simple hash algorithm identifier. |
| crypto | [littleblackbox](https://github.com/devttys0/littleblackbox) | Database of private SSL/SSH keys for embedded devices. |
| crypto | [pemcrack](https://github.com/robertdavidgraham/pemcrack) | SSL PEM file cracker. |
| crypto | [reveng](http://reveng.sourceforge.net/) | CRC finder. |
| crypto | [sslsplit](https://github.com/droe/sslsplit) | SSL/TLS MITM. |
| crypto | [python-paddingoracle](https://github.com/mwielgoszewski/python-paddingoracle) | Padding oracle attack automation. |
| crypto | [xortool](https://github.com/hellman/xortool) | XOR analysis tool. |
| web | [dirs3arch](https://github.com/maurosoria/dirs3arch) | Web path scanner. |
| web | [sqlmap](http://sqlmap.org/) | SQL injection automation engine. |
| stego | [sound-visualizer](http://www.sonicvisualiser.org/) | Audio file visualization. |
| stego | [steganabara](http://www.caesum.com/handbook/stego.htm) | Antoher image steganography solver. |
| stego | [stegsolve](http://www.caesum.com/handbook/stego.htm) | Image steganography solver. |
| android | [APKTool](https://ibotpeaches.github.io/Apktool/) | Dissect, dis-assemble, and re-pack Android APKs |
## Adding Tools

To add a tool (say, named *toolname*), do the following:

1. Create a `toolname` directory.
2. Create an `install` script.
3. (optional) if special uninstall steps are reuired, create an `uninstall` script.

### Install Scripts

The install script will be run with `$PWD` being `toolname`. It should install the tool into this directory, in as contained a manner as possible.
Ideally, full uninstallation should be possible with a `git clean`.

The install script should create a `bin` directory and put its executables there.
These executables will be automatically linked into the main `bin` directory for the repo.
They could be launched from any directory, so don't make assumptions about the location of `$0`!
