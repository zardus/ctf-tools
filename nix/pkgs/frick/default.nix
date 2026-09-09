{ lib
, stdenvNoCC
, fetchFromGitHub
, python3
, makeWrapper
}:

let
  python = python3.withPackages (ps: with ps; [
    capstone
    frida-python
    six
    unicorn
  ]);
in
stdenvNoCC.mkDerivation {
  pname = "frick";
  version = "unstable-2018-08-14";

  src = fetchFromGitHub {
    owner = "iGio90";
    repo = "frick";
    rev = "5a60bc8fe8ddcac146853ad22b64e3bac7930269";
    hash = "sha256-cOzkK/SvDYzuw2vrsVcwAqxLLOw75EWxENbSTQ38caM=";
  };

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    # Python 3.12 removed imp; translate frick's one dynamic-module load to the
    # supported importlib API so the tool can use nixpkgs' default Python.
    substituteInPlace main.py \
      --replace-fail 'import imp' 'import importlib.util' \
      --replace-fail "self.uc_impl = imp.load_source('uc_hooks', self.uc_impl)" \
                     "spec = importlib.util.spec_from_file_location('uc_hooks', self.uc_impl); self.uc_impl = importlib.util.module_from_spec(spec); spec.loader.exec_module(self.uc_impl)"

    # These JavaScript payloads are package data, not session files. Locate
    # them beside the Python sources while leaving user-created state in $PWD.
    sed -i '1i import os' script.py
    substituteInPlace main.py \
      --replace-fail "open('base.js', 'r')" \
                     "open(os.path.join(os.path.dirname(__file__), 'base.js'), 'r')"
    substituteInPlace script.py \
      --replace-fail "open('script.js', 'r')" \
                     "open(os.path.join(os.path.dirname(__file__), 'script.js'), 'r')" \
      --replace-fail "open('base.js', 'r')" \
                     "open(os.path.join(os.path.dirname(__file__), 'base.js'), 'r')" \
      --replace-fail "open('post.js', 'r')" \
                     "open(os.path.join(os.path.dirname(__file__), 'post.js'), 'r')"

    # Repair literal identity tests that newer Python versions diagnose and
    # that could misbehave when the values aren't interned.
    sed -i \
      -e 's/ is not \x27\x27/ != \x27\x27/g' \
      -e 's/ is not 0/ != 0/g' \
      -e 's/ is 0/ == 0/g' \
      main.py
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/frick $out/bin
    cp -r . $out/libexec/frick/
    makeWrapper ${python}/bin/python3 $out/bin/frick \
      --add-flags $out/libexec/frick/main.py

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    PYTHONPATH=$out/libexec/frick ${python}/bin/python3 -c 'import main, script'
  '';

  meta = {
    description = "Interactive debugger built on Frida";
    homepage = "https://github.com/iGio90/frick";
    license = lib.licenses.mit;
    mainProgram = "frick";
    platforms = lib.platforms.linux;
  };
}
