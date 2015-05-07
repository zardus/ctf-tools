# ctf-tools

This is a collection of setup scripts to create an install of various security research tools.
Of course, this isn't a hard problem, but it's really nice to have them in one place that's easily deployable to new machines and so forth.
To use, do:

```bash
# list the available tools
manage-tools list

# install gdb
manage-tools install gdb

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
| binary | afl | State-of-the-art fuzzer. |
| binary | checksec | Check binary hardening settings. |
| binary | crosstool | Cross-compilers and cross-architecture tools. |
| binary | gdb | Up-to-date gdb with python2 bindings. |
| binary | peda | Enhanced environment for gdb. |
| binary | preeny | A collection of helpful preloads (compiled for many architectures!). |
| binary | qemu | Latest version of qemu! |
| binary | shellnoob | Shellcode writing helper. |
| binary | xrop | Gadget finder. |
| forensics | firmware-mod-kit | Tools for firmware packing/unpacking. |
| forensics | testdisk | Testdisk and photorec for file recovery. |
| crypto | cribdrag | Interactive crib dragging tool (for crypto). |
| crypto | hashpump | A tool for performing hash length extension attaacks. |
| crypto | [hash-identifier](https://code.google.com/p/hash-identifier/source/checkout) | Simple hash algorithm identifier. |
| crypto | xortool | XOR analysis tool. |
| web | dirs3arch | Web path scanner. |
| web | sqlmap | SQL injection automation engine. |
