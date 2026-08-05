# pkgsPy2 is injected by the flake for all tools; IDA needs no Python-2
# component, so it is accepted and ignored here.
{ lib, buildFHSEnv, writeShellScript, pkgsPy2 ? null }:

# IDA Pro is proprietary, nonfree software. It cannot be bundled or fetched:
# the user must download and unpack the vendor tarball themselves (Hex-Rays).
# The original ctf-tools installer (ida/install) unpacks ida*.tar.?z from
# ~/Downloads and wires up a launcher. We cannot reproduce that, but we CAN
# make the user's own IDA actually run on Nix/NixOS by exec'ing it inside an
# FHS sandbox (buildFHSEnv) that provides the shared libraries IDA links
# against (libOpenGL/libEGL/libGL, xcb/xkb/X libs, glib, freetype, fontconfig,
# zlib, nss, libsecret, dbus, wayland, ...). On a stock NixOS host IDA fails
# with "libOpenGL.so.0: cannot open shared object file"; run inside this FHS it
# finds everything it needs.
#
# IDA install location is resolved at runtime, in order:
#   1. $IDA_HOME                 (explicit, recommended)
#   2. ~/.idapro/ida, ~/.idapro
#   3. ~/ida*/ (newest match)
#   4. an `ida`/`ida64` already on $PATH (outside this wrapper)
# Set IDA_HOME to the directory that contains the `ida` binary, e.g.
#   export IDA_HOME=$HOME/ida-pro-9.3

let
  launcher = writeShellScript "ida-launch" ''
    set -u

    find_ida() {
      # 1. explicit IDA_HOME
      if [ -n "''${IDA_HOME:-}" ]; then
        if [ -x "$IDA_HOME/ida" ]; then echo "$IDA_HOME/ida"; return 0; fi
        if [ -x "$IDA_HOME/ida64" ]; then echo "$IDA_HOME/ida64"; return 0; fi
        if [ -x "$IDA_HOME" ]; then echo "$IDA_HOME"; return 0; fi
      fi
      # 2. ~/.idapro
      for c in "$HOME/.idapro/ida" "$HOME/.idapro/ida64"; do
        [ -x "$c" ] && { echo "$c"; return 0; }
      done
      # 3. newest ~/ida* directory containing an ida binary
      for d in $(ls -dt "$HOME"/ida* 2>/dev/null); do
        for b in "$d/ida" "$d/ida64"; do
          [ -x "$b" ] && { echo "$b"; return 0; }
        done
      done
      # 4. ida/ida64 already on PATH (but not this very wrapper)
      for name in ida64 ida; do
        p=$(command -v "$name" 2>/dev/null || true)
        if [ -n "$p" ] && [ "$(readlink -f "$p")" != "$(readlink -f "$0")" ]; then
          echo "$p"; return 0
        fi
      done
      return 1
    }

    IDA_BIN=$(find_ida) || {
      echo "ida: could not locate an IDA Pro installation." >&2
      echo "     IDA is proprietary and user-supplied. Download it from Hex-Rays," >&2
      echo "     unpack it, then set IDA_HOME to the directory containing the 'ida'" >&2
      echo "     binary, e.g.  export IDA_HOME=\$HOME/ida-pro-9.3" >&2
      exit 1
    }

    exec "$IDA_BIN" "$@"
  '';
in
buildFHSEnv {
  name = "ida";

  # Libraries IDA (Qt6-based GUI + idalib) needs at runtime. Mirrors
  # install-root-debian (libpython, libopengl0) plus the full Qt6/xcb stack.
  targetPkgs = pkgs: with pkgs; [
    # OpenGL / EGL / GLX (libOpenGL.so.0, libEGL.so.1, libGL.so.1)
    libglvnd
    libGL
    mesa
    # Qt xcb platform plugin dependencies
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXi
    xorg.libXfixes
    xorg.libXrandr
    xorg.libXcursor
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXtst
    xorg.libxcb
    xorg.xcbutil
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    xorg.xcbutilcursor
    libxkbcommon
    xkeyboardconfig
    # core graphics/text stack
    glib
    freetype
    fontconfig
    zlib
    dbus
    # wayland client libs (IDA ships libQt6WaylandClient)
    wayland
    # secret storage / crypto
    libsecret
    nss
    nspr
    # misc
    expat
    e2fsprogs # libcom_err
    krb5
    openssl
    stdenv.cc.cc.lib # libstdc++/libgcc_s
    # a Python for idalib/idapyswitch (IDA 9.x links libpython3.x)
    python3
    python3.pkgs.pip
  ];

  runScript = launcher;

  meta = with lib; {
    description =
      "FHS launcher for IDA Pro (proprietary; set IDA_HOME to your unpacked install)";
    longDescription = ''
      IDA Pro is nonfree, user-supplied software that cannot be bundled in Nix.
      This package provides an `ida` command that runs your existing IDA install
      inside an FHS sandbox containing the shared libraries it needs.

      Point it at your install with the IDA_HOME environment variable, e.g.
        export IDA_HOME=$HOME/ida-pro-9.3
      Otherwise it searches ~/.idapro and ~/ida*.
    '';
    mainProgram = "ida";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
