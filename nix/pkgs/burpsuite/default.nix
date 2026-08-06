{ lib
, symlinkJoin
, writeShellScriptBin
, runCommandLocal
, makeDesktopItem
, unzip
, burpsuite  # nixpkgs' burpsuite; callPackage resolves this from pkgs, not from
             # this directory, so there is no self-reference here
}:

# nixpkgs wraps Burp in buildFHSEnv (bubblewrap). Burp is a plain JVM app --
# upstream's whole runScript is `java -jar burp.jar` -- so the FHS tree buys
# nothing, and the bubblewrap launcher *breaks* the tool on any host that
# restricts unprivileged user namespaces: the nix-store bwrap is not setuid and
# is not covered by the distro AppArmor profile, so it dies with
#   bwrap: setting up uid map: Permission denied
# That is the default on Ubuntu 24.04+ (kernel.apparmor_restrict_unprivileged_userns=1).
# Pre-nix ctf-tools just ran the jar under the JVM, so this derivation restores
# that: same jar, same JDK, no sandbox.

let
  # buildFHSEnvBubblewrap re-exports the arguments it was called with as
  # passthru.args (nixpkgs' own comment points at `args` as the supported way
  # to reach them). Reusing upstream's runScript means we share nixpkgs'
  # hash-pinned jar fetch instead of re-downloading and re-pinning a ~1GB
  # unfree binary that PortSwigger reissues every few weeks.
  runScript = burpsuite.args.runScript or (throw ''
    pkgs.burpsuite no longer exposes passthru.args.runScript (it is probably no
    longer a buildFHSEnv derivation). Update nix/pkgs/burpsuite/default.nix.
  '');

  # `<jdk>/bin/java -jar <burp.jar>` -> `<burp.jar>`, used only to pull the
  # app icon out of the jar the way nixpkgs' extraInstallCommands does.
  jarMatch = builtins.match ".* -jar ([^ ]+)" runScript;
  jar = if jarMatch == null then null else builtins.head jarMatch;

  # Not a wrapProgram of some upstream binary: there is no binary to wrap, the
  # program *is* a jar, so bin/burpsuite is the launcher itself.
  launcher = writeShellScriptBin "burpsuite" ''
    exec ${runScript} "$@"
  '';

  desktopItem = makeDesktopItem {
    name = "burpsuite";
    exec = "burpsuite";
    icon = "burpsuite";
    desktopName = "Burp Suite Desktop";
    comment = "Integrated platform for performing security testing of web applications";
    categories = [ "Development" "Security" "System" ];
  };

  icon = runCommandLocal "burpsuite-icon" { nativeBuildInputs = [ unzip ]; } ''
    mkdir -p $out
    # Tolerated failure: a renamed resource inside the jar must not take the
    # whole tool down over a menu icon.
    if unzip -p ${jar} resources/Media/icon64community.png > icon.png && [ -s icon.png ]; then
      install -Dm644 icon.png $out/share/icons/hicolor/64x64/apps/burpsuite.png
    fi
  '';
in
symlinkJoin {
  name = "burpsuite-${burpsuite.version}";

  paths = [ launcher desktopItem ] ++ lib.optional (jar != null) icon;

  # symlinkJoin has no `version` of its own; carry nixpkgs' through so
  # `nix eval .#burpsuite.version` keeps working.
  passthru = { inherit (burpsuite) version; };

  meta = burpsuite.meta // {
    description = "Integrated platform for performing security testing of web applications (launched directly under the JVM, without the nixpkgs bubblewrap sandbox)";
    mainProgram = "burpsuite";
  };
}
