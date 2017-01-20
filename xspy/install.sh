#!/bin/bash -e

[ -e xspy ] || git clone git://git.kali.org/packages/xspy.git
mkdir -p bin
gcc -o bin/xspy xspy/Xspy.c -lX11
