# `pkgs` is here because the FHS library list has to be shared by two consumers
# (the buildFHSEnv rootfs and the non-namespaced LD_LIBRARY_PATH fallback), and
# buildFHSEnv's targetPkgs takes a package set. pkgsPy2 is injected by the flake
# for all tools; IDA needs no Python-2 component, so it is accepted and ignored.
{ lib
, pkgs
, buildFHSEnv
, writeShellScript
, writeShellScriptBin
, symlinkJoin
, callPackage
, bubblewrap
, coreutils
, gnugrep
, gnutar
, gzip
, xz
, python3
, python3Packages
, pkgsPy2 ? null
}:

# IDA Pro is proprietary, nonfree software. It cannot be bundled or fetched:
# the user must download and unpack the vendor tarball themselves (Hex-Rays).
# This package provides the `ida` command that runs *their* install, plus the
# idalib/MCP wiring the pre-nix ida/install used to set up.
#
# IDA install location is resolved at runtime, in order:
#   1. $IDA_HOME                 (explicit, recommended)
#   2. ~/.idapro/ida, ~/.idapro
#   3. ~/ida*/ (newest match)
#   4. an `ida`/`ida64` already on $PATH (outside this wrapper)
#   5. a tarball previously unpacked from ~/Downloads (see below)
#   6. ~/Downloads/{ida,IDA}*.tar.?z, unpacked into the cache on first run
#      (this is the original ctf-tools drop-in contract)
# Set IDA_HOME to the directory that contains the `ida` binary, e.g.
#   export IDA_HOME=$HOME/ida-pro-9.3
#
# There are two ways to actually launch it, because neither works everywhere:
#   ida-fhs     runs IDA inside an FHS sandbox (buildFHSEnv/bubblewrap) that
#               supplies the shared libraries it links against. Required on
#               NixOS, where the vendor binary's ELF interpreter (/lib64/...)
#               does not exist at all. Needs unprivileged user namespaces.
#   ida-native  plain exec, no namespaces, with our libraries behind the host's
#               on LD_LIBRARY_PATH. Works on ordinary FHS distros, which is the
#               class of host where bubblewrap is blocked (Ubuntu 24.04+ sets
#               kernel.apparmor_restrict_unprivileged_userns=1, and the store's
#               bwrap is neither setuid nor covered by the distro AppArmor
#               profile, so it dies with "setting up uid map: Permission
#               denied" before the launcher can print anything of its own).
# `ida` is a dispatcher that probes for a usable user namespace and picks one;
# force either with CTF_TOOLS_IDA_MODE=fhs|native.

let
  idaProMcp = callPackage ../ida-pro-mcp { };

  # Libraries IDA (Qt6-based GUI + idalib) needs at runtime. Mirrors
  # install-root-debian (libpython, libopengl0) plus the full Qt6/xcb stack.
  targetLibs = p: with p; [
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

  libPath = lib.makeLibraryPath (targetLibs pkgs);

  # Base interpreter for the idalib venv: python3 with ida-pro-mcp importable,
  # so the resulting environment is what `uv run --project ida-pro-mcp` used to
  # provide — one interpreter that can both drive IDA headlessly (idapro, added
  # by the activation) and serve MCP.
  idalibPython = python3.withPackages (_: [ (python3Packages.toPythonModule idaProMcp) ]);

  launcher = writeShellScript "ida-launch" ''
    set -u

    unpack_path="${lib.makeBinPath [ gnutar gzip xz ]}"
    cache="''${XDG_CACHE_HOME:-$HOME/.cache}/ctf-tools/ida"
    state="''${XDG_DATA_HOME:-$HOME/.local/share}/ctf-tools/ida"

    # Tarballs from Hex-Rays unpack to a single directory holding libida.so
    # (this is how the pre-nix ida/install located the payload, too).
    find_unpacked() {
      for b in "$cache"/*/ida "$cache"/*/ida64 "$cache"/*/*/ida "$cache"/*/*/ida64; do
        [ -x "$b" ] && { echo "$b"; return 0; }
      done
      return 1
    }

    # Original ctf-tools contract: drop the vendor tarball in ~/Downloads and
    # the installer unpacks it for you. Unpacking is done once, into the cache.
    unpack_downloads() {
      local tarball dest
      tarball=$(ls -dt "$HOME"/Downloads/ida*.tar.?z "$HOME"/Downloads/IDA*.tar.?z 2>/dev/null | head -n1)
      [ -n "''${tarball:-}" ] && [ -f "$tarball" ] || return 1
      dest="$cache/$(basename "$tarball" | tr -c 'A-Za-z0-9._-' '_')"
      [ -d "$dest" ] && return 1   # already unpacked, and find_unpacked missed it
      echo "ida: unpacking $tarball (first run; this takes a while)..." >&2
      rm -rf "$dest.tmp"
      mkdir -p "$dest.tmp" || return 1
      PATH="$unpack_path" tar xf "$tarball" -C "$dest.tmp" || { rm -rf "$dest.tmp"; return 1; }
      mv "$dest.tmp" "$dest" || return 1
      find_unpacked
    }

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
      # 4. ida/ida64 already on PATH — but never this package's own `ida`, which
      #    is on $PATH whenever ctf-tools is installed and would make us exec
      #    ourselves forever. Its store path cannot be named here (the
      #    dispatcher already refers to this script, so the reference would be
      #    circular), so it is recognized by a marker string instead. $PATH is
      #    walked by hand rather than with `command -v` because our own `ida`
      #    usually comes first and would otherwise hide a real one behind it.
      local path_dirs dir
      IFS=: read -ra path_dirs <<< "$PATH"
      for dir in "''${path_dirs[@]}"; do
        for name in ida64 ida; do
          [ -x "$dir/$name" ] || continue
          p=$(readlink -f "$dir/$name")
          [ "$p" = "$(readlink -f "$0")" ] && continue
          ${gnugrep}/bin/grep -qs ctf-tools-ida-entry-point "$p" && continue
          echo "$p"; return 0
        done
      done
      # 5./6. ~/Downloads tarball, unpacked into the cache
      find_unpacked || unpack_downloads
    }

    # `ida --activate-idalib [--force]`: run IDA's own py-activate-idalib.py,
    # which is what the pre-nix installer did once at install time (it did it
    # inside the ida-pro-mcp uv project). That script pip-installs the `idapro`
    # bindings into whatever environment runs it, so it needs a writable one —
    # a store python never is, hence the venv. Explicit and idempotent (stamped
    # with what it was activated against) rather than implicit on every start.
    activate_idalib() {
      local ida_dir script venv stamp want w n
      ida_dir=$(dirname "$IDA_BIN")
      script="$ida_dir/idalib/python/py-activate-idalib.py"
      if [ ! -f "$script" ]; then
        echo "ida: $script not found." >&2
        echo "     idalib ships with IDA Pro 9.x; IDA Free does not have it." >&2
        return 1
      fi
      venv="$state/idalib-venv"
      stamp="$venv/.ctf-tools-activated"
      want="$ida_dir ${idalibPython} ${idaProMcp}"
      if [ "''${1:-}" != "--force" ] && [ -x "$venv/bin/python" ] \
         && [ "$(cat "$stamp" 2>/dev/null)" = "$want" ]; then
        echo "ida: idalib already activated for $ida_dir" >&2
        echo "     ($venv, re-run with --force to redo)" >&2
        return 0
      fi
      rm -rf "$venv"
      mkdir -p "$state" || return 1
      ${idalibPython}/bin/python -m venv --system-site-packages "$venv" || return 1
      "$venv/bin/python" "$script" || return 1
      # ida-pro-mcp's console scripts in the store are pinned to the store
      # python, which cannot see the `idapro` bindings that were just installed
      # into the venv. Copy them onto the venv interpreter instead; the
      # site.addsitedir preamble nixpkgs generates still pulls ida_pro_mcp and
      # its dependencies out of the store, so only `idapro` comes from the venv.
      for w in ${idaProMcp}/bin/.*-wrapped; do
        [ -f "$w" ] || continue
        n=$(basename "$w"); n=''${n#.}; n=''${n%-wrapped}
        { echo "#!$venv/bin/python"; tail -n +2 "$w"; } > "$venv/bin/$n"
        chmod +x "$venv/bin/$n"
      done
      echo "$want" > "$stamp"
      echo "ida: idalib activated for $ida_dir" >&2
      echo "     headless MCP server: $venv/bin/idalib-mcp /path/to/binary" >&2
      echo "     IDA-plugin MCP server: ${idaProMcp}/bin/ida-pro-mcp --install" >&2
    }

    IDA_BIN=$(find_ida) || {
      echo "ida: could not locate an IDA Pro installation." >&2
      echo "     IDA is proprietary and user-supplied. Download it from Hex-Rays," >&2
      echo "     unpack it, then set IDA_HOME to the directory containing the 'ida'" >&2
      echo "     binary, e.g.  export IDA_HOME=\$HOME/ida-pro-9.3" >&2
      echo "     (A ~/Downloads/ida*.tar.?z tarball is unpacked automatically.)" >&2
      exit 1
    }

    if [ "''${1:-}" = "--activate-idalib" ]; then
      shift
      activate_idalib "$@"
      exit $?
    fi

    # ida-native hands us its library path here instead of exporting it itself:
    # it puts the *host's* lib dirs first, and a store binary run under that
    # (the tar/grep/python above) picks up mismatched host libraries. So it is
    # applied to the vendor binary only, on the way out.
    if [ -n "''${CTF_TOOLS_IDA_LIBS:-}" ]; then
      export LD_LIBRARY_PATH="''${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$CTF_TOOLS_IDA_LIBS"
      unset CTF_TOOLS_IDA_LIBS
    fi

    exec "$IDA_BIN" "$@"
  '';

  fhs = buildFHSEnv {
    name = "ida-fhs";
    targetPkgs = targetLibs;
    runScript = launcher;
  };

  native = writeShellScriptBin "ida-native" ''
    # This path exists for ordinary FHS distros, where the pre-nix ctf-tools
    # just exec'd the vendor binary against apt-installed libraries. Anything on
    # LD_LIBRARY_PATH outranks ld.so.cache, so the host's own lib dirs are
    # listed first and ours only fill gaps: a store libstdc++ shadowing the
    # host one would drag in a newer glibc than the host has and break an IDA
    # that was working fine.
    host_libs=
    for d in /usr/lib/$(uname -m)-linux-gnu /usr/lib64 /usr/lib \
             /lib/$(uname -m)-linux-gnu /lib64 /lib; do
      [ -d "$d" ] && host_libs="''${host_libs:+$host_libs:}$d"
    done
    export CTF_TOOLS_IDA_LIBS="''${host_libs:+$host_libs:}${libPath}"

    # No FHS loader means NixOS (or similar): the vendor binary's PT_INTERP does
    # not exist and only the sandbox can run it, so say that instead of letting
    # exec fail with a bare "No such file or directory". Not fatal — $IDA_HOME
    # could still point at something interpreted.
    if ! ls /lib*/ld-linux*.so* >/dev/null 2>&1; then
      echo "ida-native: no FHS dynamic loader on this host (/lib*/ld-linux*.so*); a vendor IDA" >&2
      echo "            binary can only run inside the FHS sandbox here (CTF_TOOLS_IDA_MODE=fhs)." >&2
    fi

    exec ${launcher} "$@"
  '';

  dispatcher = writeShellScriptBin "ida" ''
    # ctf-tools-ida-entry-point -- marker read by find_ida's $PATH probe; see
    # the launcher above. Do not remove.
    case "''${CTF_TOOLS_IDA_MODE:-auto}" in
      fhs)    exec ${fhs}/bin/ida-fhs "$@" ;;
      native) exec ${native}/bin/ida-native "$@" ;;
    esac

    # Probe with the same bwrap buildFHSEnv uses; on a host that blocks
    # unprivileged user namespaces this fails the same way the FHS env would,
    # except here we get to say why.
    if ${bubblewrap}/bin/bwrap --unshare-user --ro-bind / / ${coreutils}/bin/true >/dev/null 2>&1; then
      exec ${fhs}/bin/ida-fhs "$@"
    fi

    echo "ida: bubblewrap cannot create a user namespace here; running IDA without the FHS sandbox." >&2
    echo "     On Ubuntu 24.04+ this is kernel.apparmor_restrict_unprivileged_userns=1; to get the" >&2
    echo "     sandbox back, 'sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0' or add" >&2
    echo "     an AppArmor profile allowing userns for /nix/store/*/bin/bwrap. Silence this with" >&2
    echo "     CTF_TOOLS_IDA_MODE=native." >&2
    exec ${native}/bin/ida-native "$@"
  '';
in
symlinkJoin {
  name = "ida";
  paths = [ dispatcher fhs native ];

  meta = with lib; {
    description =
      "Launcher for IDA Pro (proprietary; set IDA_HOME to your unpacked install)";
    longDescription = ''
      IDA Pro is nonfree, user-supplied software that cannot be bundled in Nix.
      This package provides an `ida` command that runs your existing IDA
      install, either inside an FHS sandbox containing the shared libraries it
      needs (`ida-fhs`, required on NixOS) or directly with those libraries on
      LD_LIBRARY_PATH (`ida-native`, for hosts where unprivileged user
      namespaces are blocked). `ida` picks between them automatically;
      CTF_TOOLS_IDA_MODE=fhs|native overrides.

      Point it at your install with the IDA_HOME environment variable, e.g.
        export IDA_HOME=$HOME/ida-pro-9.3
      Otherwise it searches ~/.idapro, ~/ida*, and unpacks a
      ~/Downloads/ida*.tar.?z tarball on first run.

      `ida --activate-idalib` runs IDA's py-activate-idalib.py into a venv under
      $XDG_DATA_HOME/ctf-tools/ida that also has the `ida-pro-mcp` output, for
      headless/idalib and MCP-driven use.
    '';
    mainProgram = "ida";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
