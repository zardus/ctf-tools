# The full cross2 target set (build/binutils/targets.sh). Shared by default.nix
# (to build each) and flake.nix (to surface each as a cross2-<target> output in
# the toolchains CI matrix).
[
  # major architectures
  "arm-elf" "h8300-elf" "i386-elf" "mips-elf" "powerpc-elf" "sh-elf"
  # other architectures
  "arc-elf" "avr-elf" "cris-elf" "fr30-elf" "frv-elf" "hppa-linux"
  "m32r-elf" "m6811-elf" "m68k-elf" "mcore-elf" "mips64-elf" "mmix-elf"
  "mn10300-elf" "pdp11-aout" "powerpc64-linux" "s390-linux" "sh64-elf"
  "sparc-elf" "strongarm-elf" "v850-elf" "x86_64-linux" "xscale-elf"
  "xstormy16-elf" "xtensa-elf"
  # need patches to build cross binutils/gcc
  "alpha-elf" "ia64-elf" "vax-netbsdelf"
  # need obsolete option to build cross gcc
  "i960-elf"
]
