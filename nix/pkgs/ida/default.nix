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
#   ida-native  plain exec, no namespaces, with our libraries behind the host's
#               on LD_LIBRARY_PATH. This is the default, and it is what the
#               pre-nix ida/install effectively did. On an ordinary FHS distro
#               the vendor binary just runs, and it sees the host's fonts, icon
#               themes and GPU drivers rather than the sandbox's necessarily
#               partial copies of them.
#   ida-fhs     runs IDA inside an FHS sandbox (buildFHSEnv/bubblewrap) that
#               supplies the shared libraries it links against. This is for
#               hosts where the binary cannot exec at all: NixOS has no
#               /lib64/ld-linux-*.so.*, the ELF interpreter every Hex-Rays
#               build hardcodes. Needs unprivileged user namespaces, which
#               Ubuntu 24.04+ denies to the store's bwrap
#               (kernel.apparmor_restrict_unprivileged_userns=1) -- another
#               reason not to route FHS distros through it.
# `ida` is a dispatcher: it uses ida-native wherever the host provides that ELF
# interpreter, and the sandbox only where it does not. Force either with
# CTF_TOOLS_IDA_MODE=fhs|native.

let
  idaProMcp = callPackage ../ida-pro-mcp { };

  # Libraries IDA (Qt6-based GUI + idalib) needs at runtime. Mirrors
  # install-root-debian (libpython, libopengl0) plus the full Qt6/xcb stack.
  targetLibs = p: with p; [
    # OpenGL / EGL / GLX (libOpenGL.so.0, libEGL.so.1, libGL.so.1)
    libglvnd
    libGL
    mesa
    # Qt xcb platform plugin dependencies. Top-level names, not the `xorg.*`
    # set: nixpkgs deprecated that set and warns once per attribute, which
    # buried every `nix build .#ida` under 21 lines of rename notices.
    libx11
    libxext
    libxrender
    libxi
    libxfixes
    libxrandr
    libxcursor
    libxcomposite
    libxdamage
    libxtst
    libxcb
    libxcb-util
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-wm
    libxcb-cursor
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
    # IDA's IDAPython bindings (_ida_idaapi.so) link libcrypt.so.1, the
    # pre-4.4 libxcrypt soname that most distros no longer ship by default.
    # Without it `import idaapi` dies and takes the idalib worker with it.
    libxcrypt-legacy
  ];

  # Fonts, for the FHS sandbox only. buildFHSEnv bind-mounts the host's
  # /etc/fonts, so fontconfig's *configuration* comes from the host -- but that
  # config points at /usr/share/fonts, and inside the sandbox /usr is the FHS
  # tree, not the host's. With no font package in targetPkgs there is nothing
  # for fontconfig to find, and IDA draws every glyph as an empty box.
  # ida-native runs against the host's real /usr and needs none of this.
  fontPkgs = p: with p; [ dejavu_fonts liberation_ttf ];

  libPath = lib.makeLibraryPath (targetLibs pkgs);

  # Base interpreters for the idalib venv: a python with ida-pro-mcp importable,
  # which is what `uv run --project ida-pro-mcp` used to provide — one
  # environment that can both drive IDA headlessly (idapro, added by the
  # activation) and serve MCP.
  #
  # There is more than one because IDA's idalib binding is built for particular
  # CPython versions and nixpkgs' default runs ahead of them: on 9.3 the wheel
  # installs cleanly into a 3.14 venv and then `import idapro` fails. The
  # activation tries these in order and keeps the first that can import it.
  # Newest first, so a future IDA that does support 3.14 needs no change here.
  # Each entry pairs the interpreter with its own ida-pro-mcp build, because the
  # console scripts the activation copies resolve store site-packages for
  # exactly one Python version.
  idalibCandidates = map
    (py:
      let mcp = callPackage ../ida-pro-mcp { python3Packages = py.pkgs; };
      in {
        env = py.withPackages (_: [ (py.pkgs.toPythonModule mcp) ]);
        inherit mcp;
      })
    [ python3 pkgs.python313 pkgs.python312 ];

  # '"<env>|<mcp>" "<env>|<mcp>" ...' — one *quoted* shell word per candidate.
  # The quotes are load-bearing: unquoted, the shell reads the `|` joining the
  # two store paths as a pipe and the script dies at parse time.
  candidateList = lib.concatMapStringsSep " " (c: ''"${c.env}|${c.mcp}"'') idalibCandidates;
  # Stamp content: interpreters only, no separators to worry about.
  candidateStamp = lib.concatMapStringsSep " " (c: "${c.env}") idalibCandidates;
  candidatePythons = lib.concatMapStringsSep ", " (c: c.env.python.version) idalibCandidates;

  launcher = writeShellScript "ida-launch" ''
    set -u

    unpack_path="${lib.makeBinPath [ gnutar gzip xz ]}"
    cache="''${XDG_CACHE_HOME:-$HOME/.cache}/ctf-tools/ida"
    state="''${XDG_DATA_HOME:-$HOME/.local/share}/ctf-tools/ida"

    # Look for the vendor binary in a directory. Two things this has to get
    # right, both learned the hard way:
    #   - `test -x` is true for directories, and IDA 9.x's tarball has a
    #     *directory* named `ida` at its root. Probing with -x alone picks that
    #     up and the launcher execs it ("ida: Is a directory"). Every probe here
    #     insists on a regular file.
    #   - the binary may be one level down, inside that `ida` directory.
    # Names: 9.x ships `ida` (GUI) and `idat` (text mode); older releases split
    # them into 32/64-bit pairs. GUI first, since that is what `ida` implies.
    ida_bin_in() {
      local d=$1 n
      for n in ida ida64 idat idat64; do
        [ -f "$d/$n" ] && [ -x "$d/$n" ] && { echo "$d/$n"; return 0; }
      done
      return 1
    }

    # Tarballs from Hex-Rays unpack to a single directory holding libida.so
    # (this is how the pre-nix ida/install located the payload, too).
    find_unpacked() {
      local d
      for d in "$cache"/*/; do
        [ -d "$d" ] || continue
        ida_bin_in "''${d%/}" && return 0
        ida_bin_in "''${d%/}/ida" && return 0
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
      # Unpacked, yet find_unpacked came up empty: the tree is laid out in some
      # way this script does not know about. Say where it is, so the user can
      # point IDA_HOME at it instead of being told nothing was found at all.
      unpacked_but_unusable() {
        echo "ida: $tarball is unpacked in $dest," >&2
        echo "     but no ida/idat binary turned up there. Set IDA_HOME to the" >&2
        echo "     directory holding it (or to the binary itself)." >&2
        return 1
      }
      [ -d "$dest" ] && { unpacked_but_unusable; return 1; }
      echo "ida: unpacking $tarball (first run; this takes a while)..." >&2
      rm -rf "$dest.tmp"
      mkdir -p "$dest.tmp" || return 1
      PATH="$unpack_path" tar xf "$tarball" -C "$dest.tmp" || { rm -rf "$dest.tmp"; return 1; }
      mv "$dest.tmp" "$dest" || return 1
      local bin
      bin=$(find_unpacked) || { unpacked_but_unusable; return 1; }

      # Pre-nix, ida/install activated idalib immediately after unpacking, so
      # `idalib-mcp` worked without a second command. Same here, once, on the
      # unpack path only. Best effort: IDA Free ships no idalib and pip may be
      # offline, and neither is a reason to stop IDA from starting. stdout is
      # routed to stderr because this whole path runs inside $(find_ida), whose
      # stdout is the binary path.
      if ! activate_idalib "$bin" >&2; then
        echo "ida: idalib was not activated -- 'idalib-mcp' will not be able to load a" >&2
        echo "     binary until you run 'ida --activate-idalib'. Starting IDA anyway." >&2
      fi
      echo "$bin"
    }

    find_ida() {
      # 1. explicit IDA_HOME — the install directory, or the binary itself
      if [ -n "''${IDA_HOME:-}" ]; then
        ida_bin_in "$IDA_HOME" && return 0
        ida_bin_in "$IDA_HOME/ida" && return 0
        if [ -f "$IDA_HOME" ] && [ -x "$IDA_HOME" ]; then echo "$IDA_HOME"; return 0; fi
      fi
      # 2. ~/.idapro
      ida_bin_in "$HOME/.idapro" && return 0
      # 3. newest ~/ida* directory containing an ida binary
      for d in $(ls -dt "$HOME"/ida* 2>/dev/null); do
        ida_bin_in "$d" && return 0
        ida_bin_in "$d/ida" && return 0
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
          [ -f "$dir/$name" ] && [ -x "$dir/$name" ] || continue
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
    # activate_idalib [--force] [ida-binary]   (binary defaults to $IDA_BIN,
    # which is not set yet when the first-run unpack path calls this)
    activate_idalib() {
      local force="" bin ida_dir script venv stamp want w n wheel cand pyenv mcp pyver last_err port wlog wpid tries
      [ "''${1:-}" = "--force" ] && { force=1; shift; }
      bin="''${1:-$IDA_BIN}"
      ida_dir=$(dirname "$bin")
      script="$ida_dir/idalib/python/py-activate-idalib.py"
      if [ ! -f "$script" ]; then
        echo "ida: $script not found." >&2
        echo "     idalib ships with IDA Pro 9.x; IDA Free does not have it." >&2
        return 1
      fi
      venv="$state/idalib-venv"
      stamp="$venv/.ctf-tools-activated"
      want="$ida_dir ${candidateStamp}"
      if [ -z "$force" ] && [ -x "$venv/bin/python" ] \
         && [ "$(cat "$stamp" 2>/dev/null)" = "$want" ]; then
        echo "ida: idalib already activated for $ida_dir" >&2
        echo "     ($venv, re-run with --force to redo)" >&2
        return 0
      fi
      mkdir -p "$state" || return 1
      wheel=$(ls -t "$ida_dir"/idalib/python/idapro-*.whl 2>/dev/null | head -n1)

      # `import idapro` dlopens $ida_dir/libidalib.so, which links libstdc++
      # and IDA's own sibling libraries. Nothing puts those on the loader path
      # for the *python* doing the import -- the launcher's LD_LIBRARY_PATH is
      # applied to the IDA binary on its way out, which this never reaches --
      # so the import fails with "libstdc++.so.6: cannot open shared object
      # file" no matter which interpreter or wheel is used. $ida_dir first so
      # IDA's libraries win, then ours for libstdc++ and friends.
      idalib_ld="$ida_dir:${libPath}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      # Every python invocation below goes through this; workers spawned by the
      # MCP server inherit it from the wrapper, which sets the same thing.
      pyrun() { LD_LIBRARY_PATH="$idalib_ld" "$@"; }

      # IDA's idalib binding is built against particular CPython versions, and
      # nixpkgs' default python3 runs ahead of what IDA supports (3.14 vs 9.3's
      # 3.13 ceiling) -- the wheel installs happily and then `import idapro`
      # fails. So try each interpreter we can offer and keep the first that can
      # actually import it. Each candidate carries its own ida-pro-mcp build,
      # because the console scripts copied in below resolve the store's
      # site-packages for exactly one Python version.
      for cand in ${candidateList}; do
        pyenv=''${cand%%|*}
        mcp=''${cand##*|}
        rm -rf "$venv"
        "$pyenv/bin/python" -m venv --system-site-packages "$venv" || continue
        pyrun "$venv/bin/python" "$script" >&2 || true

        # py-activate-idalib.py used to pip-install the binding; as of IDA 9.3
        # it only writes ~/.idapro/ida-config.json, so install the wheel IDA
        # ships next to it. Conditioned on the import, not the IDA version, so
        # both behaviours work.
        if ! pyrun "$venv/bin/python" -c 'import idapro' >/dev/null 2>&1 \
           && [ -n "''${wheel:-}" ]; then
          # --no-index first: the wheel is self-contained, so this has to work
          # offline; fall back to a normal install if it has dependencies.
          pyrun "$venv/bin/python" -m pip install -q --disable-pip-version-check \
            --no-index "$wheel" >/dev/null 2>&1 \
            || pyrun "$venv/bin/python" -m pip install -q --disable-pip-version-check \
                 "$wheel" >/dev/null 2>&1 || true
        fi

        if pyrun "$venv/bin/python" -c 'import idapro' >/dev/null 2>&1; then
          pyver=$("$venv/bin/python" -c 'import sys; print("%d.%d" % sys.version_info[:2])')
          echo "ida: idalib binding imports under python $pyver" >&2
          break
        fi
        # Keep the real reason from the last attempt; without this the failure
        # below can only say "it did not work", which is what made this bug
        # take three rounds to pin down.
        last_err=$(pyrun "$venv/bin/python" -c 'import idapro' 2>&1 | tail -3)
        mcp=""
      done

      # Gate the stamp on the binding actually importing. Stamping first is how
      # this shipped broken: activation "succeeded", every later run reported
      # "already activated", and idalib-mcp failed anyway with nothing to
      # suggest re-running it. Leaving it unstamped means the next launch
      # retries.
      if [ -z "''${mcp:-}" ] || ! pyrun "$venv/bin/python" -c 'import idapro' >/dev/null 2>&1; then
        echo "ida: activation incomplete -- no available python could import idapro." >&2
        echo "     Wheel: ''${wheel:-<none found>}" >&2
        echo "     Tried: ${candidatePythons}" >&2
        echo "     Last error:" >&2
        echo "''${last_err:-       (no import error captured)}" | sed 's/^/       /' >&2
        return 1
      fi

      # ida-pro-mcp's console scripts in the store are pinned to the store
      # python, which cannot see the `idapro` bindings that were just installed
      # into the venv. Copy them onto the venv interpreter instead; the
      # site.addsitedir preamble nixpkgs generates still pulls ida_pro_mcp and
      # its dependencies out of the store, so only `idapro` comes from the venv.
      for w in "$mcp"/bin/.*-wrapped; do
        [ -f "$w" ] || continue
        n=$(basename "$w"); n=''${n#.}; n=''${n%-wrapped}
        { echo "#!$venv/bin/python"; tail -n +2 "$w"; } > "$venv/bin/$n"
        chmod +x "$venv/bin/$n"
      done
      # ida-pro-mcp spawns its worker with stderr=DEVNULL, so a worker that dies
      # takes the reason with it and every client sees the same content-free
      # "idalib worker exited early with code 1". Run that exact command once,
      # here, where its output can be shown. A healthy worker stays up and
      # serves, so "still running" is the pass condition.
      port=$(pyrun "$venv/bin/python" -c \
        'import socket;s=socket.socket();s.bind(("127.0.0.1",0));p=s.getsockname()[1];s.close();print(p)' \
        2>/dev/null) || port=""
      if [ -n "$port" ]; then
        wlog="$state/idalib-worker-preflight.log"
        pyrun "$venv/bin/python" -m ida_pro_mcp.idalib_server \
          --host 127.0.0.1 --port "$port" >"$wlog" 2>&1 &
        wpid=$!
        tries=0
        while [ "$tries" -lt 60 ]; do
          kill -0 "$wpid" 2>/dev/null || break
          pyrun "$venv/bin/python" -c \
            "import socket,sys;s=socket.socket();s.settimeout(0.3);sys.exit(0 if s.connect_ex(('127.0.0.1',$port))==0 else 1)" \
            2>/dev/null && break
          tries=$((tries + 1))
          sleep 0.5
        done
        if kill -0 "$wpid" 2>/dev/null; then
          kill "$wpid" 2>/dev/null
          wait "$wpid" 2>/dev/null || true
        else
          wait "$wpid" 2>/dev/null || true
          echo "ida: idalib imports, but its MCP worker exits immediately." >&2
          echo "     ida-pro-mcp discards the worker's output, so this is what it said:" >&2
          sed 's/^/       /' "$wlog" >&2
          echo "     Reproduce it directly with:" >&2
          echo "       LD_LIBRARY_PATH=\"\$(cat $venv/.ctf-tools-ld-path)\" \\" >&2
          echo "         $venv/bin/python -m ida_pro_mcp.idalib_server --host 127.0.0.1 --port 8745" >&2
          return 1
        fi
      fi

      # The wrapper needs the same loader path when it execs the venv's
      # idalib-mcp (and the workers that server spawns), so record where IDA is.
      echo "$ida_dir" > "$venv/.ctf-tools-ida-dir"
      echo "$want" > "$stamp"
      echo "ida: idalib activated for $ida_dir" >&2
      echo "     headless MCP server: idalib-mcp /path/to/binary (uses $venv)" >&2
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
    targetPkgs = p: targetLibs p ++ fontPkgs p;
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

    # Does the host provide the ELF interpreter the vendor binary asks for? On
    # any ordinary distro it does, and then plain exec is the better path: it
    # inherits the host's fonts, icon themes and GPU drivers, none of which the
    # sandbox can reproduce completely. The sandbox is for hosts (NixOS) where
    # this file does not exist and the binary therefore cannot start at all.
    for ldso in /lib64/ld-linux-x86-64.so.2 /lib/ld-linux-aarch64.so.1; do
      [ -e "$ldso" ] && exec ${native}/bin/ida-native "$@"
    done

    # No host loader. The FHS sandbox is the only thing that can run IDA here,
    # so probe with the same bwrap buildFHSEnv uses -- if that is blocked too,
    # say so plainly instead of failing inside bwrap with a bare uid-map error.
    if ${bubblewrap}/bin/bwrap --unshare-user --ro-bind / / ${coreutils}/bin/true >/dev/null 2>&1; then
      exec ${fhs}/bin/ida-fhs "$@"
    fi

    echo "ida: this host has no /lib64/ld-linux-x86-64.so.2, so IDA's own binary cannot exec," >&2
    echo "     and bubblewrap cannot create a user namespace, so the FHS sandbox that would" >&2
    echo "     supply one is unavailable too. Allow unprivileged user namespaces (on Ubuntu" >&2
    echo "     24.04+: sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0), or run" >&2
    echo "     IDA through your own FHS environment. Trying the plain path anyway:" >&2
    exec ${native}/bin/ida-native "$@"
  '';
  # Upstream's `idalib-mcp` runs against the store python, which has no
  # `idapro` binding: that lives only in the venv the activation builds, since
  # it is pip-installed from a wheel inside the user's IDA and the store is
  # read-only. So run the activation ourselves if the venv is not there yet,
  # rather than exiting and asking for a command to be run -- an MCP client
  # launching this sees only "Transport closed" and never shows the advice.
  #
  # Test the venv by importing the binding, not by looking for files. Builds
  # before f871e8a stamped activation as successful without installing idapro,
  # so a venv can hold a full set of console scripts and still be unable to
  # open a database -- and the stamp then makes a plain --activate-idalib a
  # no-op. Hence --force below: the only way past a venv that lies about
  # itself is to rebuild it.
  idalibMcp = writeShellScript "idalib-mcp" ''
    venv="''${XDG_DATA_HOME:-$HOME/.local/share}/ctf-tools/ida/idalib-venv"
    venv_works() {
      local d
      d=$(cat "$venv/.ctf-tools-ida-dir" 2>/dev/null || true)
      [ -x "$venv/bin/python" ] && [ -x "$venv/bin/idalib-mcp" ] \
        && LD_LIBRARY_PATH="''${d:+$d:}${libPath}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
           "$venv/bin/python" -c 'import idapro' >/dev/null 2>&1
    }
    if ! venv_works; then
      echo "idalib-mcp: idalib is not usable yet; setting it up now (one time, ~a minute)." >&2
      # ida-native rather than the dispatcher: activation only runs a store
      # python against IDA's script and wheel, so it needs no FHS sandbox, and
      # referring to the dispatcher from here would be a cycle in the join.
      ${native}/bin/ida-native --activate-idalib --force >&2 || true
    fi
    if venv_works; then
      # libidalib.so links libstdc++ and IDA's sibling libraries, and nothing
      # else puts them on the loader path for this python. Same list the
      # activation used; workers the server spawns inherit it.
      ida_dir=$(cat "$venv/.ctf-tools-ida-dir" 2>/dev/null || true)
      export LD_LIBRARY_PATH="''${ida_dir:+$ida_dir:}${libPath}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      exec "$venv/bin/idalib-mcp" "$@"
    fi
    echo "idalib-mcp: activation did not complete, so this server can start but cannot load" >&2
    echo "            a binary. Run 'ida --activate-idalib' to see why." >&2
    exec ${idaProMcp}/bin/idalib-mcp "$@"
  '';
in
symlinkJoin {
  name = "ida";
  # idaProMcp rides along because the pre-nix ida/install checked out
  # ida-pro-mcp as part of installing IDA -- `idalib-mcp` and friends were
  # simply there afterwards. It stays a separate flake output too, for anyone
  # who wants the MCP servers without this launcher; installing both into one
  # profile collides on those four names, which is the expected outcome of
  # asking for the same programs twice.
  paths = [ dispatcher fhs native idaProMcp ];

  # ... with the venv-aware idalib-mcp in front of the store one.
  postBuild = ''
    ln -sf ${idalibMcp} $out/bin/idalib-mcp
  '';

  meta = with lib; {
    description =
      "Launcher for IDA Pro (proprietary; set IDA_HOME to your unpacked install)";
    longDescription = ''
      IDA Pro is nonfree, user-supplied software that cannot be bundled in Nix.
      This package provides an `ida` command that runs your existing IDA
      install: normally by plain exec with the libraries it needs on
      LD_LIBRARY_PATH (`ida-native`), and on hosts with no
      /lib64/ld-linux-*.so.* -- NixOS -- inside an FHS sandbox that supplies
      that interpreter (`ida-fhs`). `ida` picks between them automatically;
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
