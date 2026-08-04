# Fixed-output hashes for the per-sample source-tarball sets fetched by
# crosstool-NG (see ./mk-toolchain.nix). Keys are the *sanitized* sample names
# (commas / non [a-zA-Z0-9_-] replaced with '-'), values are the SRI sha256 of
# the recursive tarball directory.
#
# HOW TO PIN A NEW SAMPLE (trust-on-first-use):
#   1. Add an entry with `lib.fakeHash` (or omit it -- mk-toolchain defaults to
#      fakeHash), or just build `.passthru.toolchains.<name>`.
#   2. Nix reports `got: sha256-...`; paste that value here.
# Samples without an entry here still appear in `passthru.toolchains`, but their
# source download derivation will fail the hash check until pinned. CI tolerates
# per-sample failures, so the full matrix can be filled in incrementally.
{
  # --- Pinned source sets. Toolchain build status noted per entry. ---
  # riscv32-unknown-elf: CT_LIBC_NONE (freestanding) -- toolchain builds; verified
  #   it cross-compiles+links a freestanding RISC-V ELF.
  "riscv32-unknown-elf" = "sha256-Gv40eYP5PoKSS8LWzpWcWkNIQwFJ2A7c2OTDincjgkk=";
  # bpf-unknown-none: CT_LIBC_NONE, no multilib/gdb -- fast; verified it
  #   cross-compiles C to real eBPF machine code. (Same source set as riscv32.)
  "bpf-unknown-none" = "sha256-Gv40eYP5PoKSS8LWzpWcWkNIQwFJ2A7c2OTDincjgkk=";
  # moxie-unknown-elf: newlib -- toolchain builds; verified it cross-compiles a
  #   hosted printf hello-world into a real Moxie ELF (newlib libc linked in).
  "moxie-unknown-elf" = "sha256-G9qHxo+M6DfTYh7YP40jCzTtFr8SWPJzsvtYj/IQJaM=";
  # arm-none-eabi: newlib, multilib -- toolchain builds (heavy multilib build).
  "arm-none-eabi" = "sha256-j+m8RHC8MPGrNE9LDOiMHUH/GOIytL5RgG6Y5jt3ziE=";
  # avr: avr-libc -- source set pins fine, but the toolchain build currently
  #   fails in avr-libc's configure ("Wrong assembler found") with binutils 2.47;
  #   a per-sample upstream incompatibility that CI tolerates. Left pinned so the
  #   source FOD is reproducible and the sample is easy to revisit.
  "avr" = "sha256-sh2pxBjwi7ex+E2/nmr57hrotrFMHLZQiUK47Se5K0A=";

  # --- Additional bare-metal samples (newlib / picolibc / mingw). ---
  # Linux/glibc/uclibc/musl samples are omitted: this ct-ng resolves gettext to
  # 0.26, which is not published on GNU's servers, so their source download
  # fails upstream. Bump ctng or override companion versions to add them.
  "arm-picolibc-eabi"    = "sha256-+IwA8e+Ex/LVGfHM8KqKFS8QN8Xvw0/PnJKdG8vL1b4=";
  "arm-unknown-eabi"     = "sha256-j+m8RHC8MPGrNE9LDOiMHUH/GOIytL5RgG6Y5jt3ziE=";
  "i686-w64-mingw32"     = "sha256-lDPp1o2MOvokOpv3+JRRMPtCt+cQRTvbzG1f/7H2wmI=";
  "riscv32-hifive1-elf"  = "sha256-+IwA8e+Ex/LVGfHM8KqKFS8QN8Xvw0/PnJKdG8vL1b4=";
  "riscv32-picolibc-elf" = "sha256-+IwA8e+Ex/LVGfHM8KqKFS8QN8Xvw0/PnJKdG8vL1b4=";
  "riscv64-multilib-elf" = "sha256-+IwA8e+Ex/LVGfHM8KqKFS8QN8Xvw0/PnJKdG8vL1b4=";
  "sh-unknown-elf"       = "sha256-+IwA8e+Ex/LVGfHM8KqKFS8QN8Xvw0/PnJKdG8vL1b4=";
}
