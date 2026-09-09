{ lib
, stdenv
, fetchFromGitHub
, python3
, makeWrapper
, binutils
}:

let
  version = "unstable-2021-08-22";

  hyx4forkever = fetchFromGitHub {
    owner = "haxkor";
    repo = "hyx4forkever";
    rev = "0a6404647b9fd55621a1dbad3e935ab369e4eb5a";
    hash = "sha256-S569fkzMCgTmoWd+vs/hGXuaUBuydfpZQGnguwHc528=";
  };

  python = python3.withPackages (ps: [ ps.pwntools ]);
in
stdenv.mkDerivation {
  pname = "forkever";
  inherit version;

  src = fetchFromGitHub {
    owner = "haxkor";
    repo = "forkever";
    rev = "ddfc10577155c0e1b5e0ce2fd07ad3ebc455fbc4";
    hash = "sha256-3WLl5QEKmi+GBaSdHB/uvaHAjZ/sQR5uo0lBBvS529U=";
  };

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    # These are value comparisons. Python only happened to intern the literal
    # objects on the interpreter versions contemporary with forkever.
    sed -i \
      -e 's/syscall_name is "\*"/syscall_name == "*"/g' \
      -e 's/fmt is not "i"/fmt != "i"/g' \
      ProcessManager.py ProcessWrapper.py
  '';

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    ${stdenv.cc.targetPrefix}cc -g -no-pie \
      -o launcher/launcher launcher/launcher.c

    cp -r ${hyx4forkever} hyx4forkever
    chmod -R u+w hyx4forkever
    ${stdenv.cc.targetPrefix}cc -g -pthread \
      -o hyx4forkever/hyx hyx4forkever/*.c

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    app=$out/libexec/forkever/app
    mkdir -p "$app/launcher" $out/libexec/forkever/hyx4forkever $out/bin
    cp -r ./*.py ptrace utilsFolder FuzzingScripts "$app/"
    rm -rf "$app/FuzzingScripts/fuzzme"
    cp README.md License.txt "$app/"
    install -m0755 launcher/launcher "$app/launcher/launcher"
    install -m0755 hyx4forkever/hyx $out/libexec/forkever/hyx4forkever/hyx

    makeWrapper ${python}/bin/python3 $out/bin/forkever \
      --add-flags "$app/forkever.py" \
      --prefix PATH : ${lib.makeBinPath [ binutils stdenv.cc ]}

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/forkever --help >/dev/null
    $out/libexec/forkever/hyx4forkever/hyx --help >/dev/null 2>&1 || true
  '';

  meta = {
    description = "Debugger with fork-based checkpoints for exploit development";
    homepage = "https://github.com/haxkor/forkever";
    license = lib.licenses.gpl3Only;
    mainProgram = "forkever";
    platforms = [ "x86_64-linux" ];
  };
}
