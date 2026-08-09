{ lib
, rustPlatform
, fetchFromGitHub
, makeWrapper
}:

# kuna (https://github.com/Noelo-Lab/kuna) is an agent-first decompiler: a Rust
# port of Ghidra's C++ decompiler that has since diverged, shipped as a single
# CLI (`kuna decompile ./a.out main`).
#
# Two things about the upstream build are worth knowing before touching this
# file, both of which come straight from its top-level Makefile:
#
#  1. `make binaries` builds four binaries out of the cargo workspace under
#     decompiler/ -- the engine console (`decomp_dbg`), the datatest harness
#     (`decomp_test_dbg`), the SLEIGH compiler (`slacomp`) and the user-facing
#     `kuna` CLI. They are not independent: `kuna` is a driver that shells out
#     to the other three, which it finds as *siblings of its own argv[0]*
#     (kuna-cli/src/paths.rs). Installing all four into $out/bin is therefore
#     what makes the CLI work at all, not a convenience.
#
#  2. `make specs` is a real build step, not a docs target. The decoder cannot
#     disassemble anything without compiled SLEIGH specs, and the repo ships
#     only the .slaspec *sources* (the .sla outputs are gitignored). So the
#     build runs the just-built `slacomp` over the vendored spec tree exactly
#     as the Makefile does, and installs the result.
#
# The compiled spec tree is found at runtime through `KUNA_SPECS`. Without it,
# kuna derives the spec directory from its own path by walking three levels up
# (it expects to live at <repo>/decompiler/target/release/kuna), which lands on
# the store root here and finds nothing -- hence the wrappers below.

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kuna";
  # Upstream's version is `VERSION` + the commit count (scripts/version.sh), so
  # tags are v1.<n>; this is the latest release tag.
  version = "1.119";

  src = fetchFromGitHub {
    owner = "Noelo-Lab";
    repo = "kuna";
    tag = "v${finalAttrs.version}";
    hash = "sha256-A1kkGhsWmqum3XknBjE7J0eOpcKavRG86ezP2VUJQVA=";
  };

  # The cargo workspace is decompiler/, not the repo root (which is a plain
  # Makefile tree holding the specs, tests and docs alongside it).
  cargoRoot = "decompiler";
  buildAndTestSubdir = "decompiler";
  cargoHash = "sha256-kanKRqb40Ps2D2aoWwdeaPn/sosRHD860XVqCyJpIWM=";

  nativeBuildInputs = [ makeWrapper ];

  # Same four packages `make binaries` builds. Deliberately not `--workspace`:
  # that would also build kuna-wasm (a wasm-bindgen crate meant for a
  # wasm32-unknown-unknown target) and kuna-ghidra (the JNI-side Ghidra
  # extension), neither of which is a host binary anyone installs.
  cargoBuildFlags = [ "-p" "kuna-console" "-p" "kuna-harness" "-p" "kuna-slacomp" "-p" "kuna-cli" ];

  # The workspace suite is upstream's `make rust-test` gate. It needs the
  # compiled specs and the XML regression corpus, and takes far longer than the
  # build itself; the cheap end-to-end check (decompile a real binary with the
  # specs this build produced) is in installCheckPhase instead.
  doCheck = false;

  # `make specs`: compile every vendored .slaspec -> .sla with the slacomp we
  # just built. slacomp writes each .sla next to its source, so this mutates the
  # unpacked spec tree in place, which is what postInstall then copies out.
  postBuild = ''
    # buildAndTestSubdir moves cargo's output to $CARGO_TARGET_DIR (top-level
    # target/), under a per-target-triple subdirectory.
    slacomp=$(find "''${CARGO_TARGET_DIR:-target}" -type f -executable -name slacomp | head -n1)
    [ -n "$slacomp" ] || { echo "slacomp was not built"; exit 1; }
    echo "compiling SLEIGH specs with $slacomp"
    "$slacomp" -a specs
  '';

  postInstall = ''
    mkdir -p $out/share/kuna
    cp -r specs $out/share/kuna/specs

    # docs/options.md is the toggle catalog upstream's README points agents at,
    # and docs/phases.md the stage model; they are the tool's real manual.
    mkdir -p $out/share/doc/kuna
    cp -r docs/. $out/share/doc/kuna/
    cp README.md $out/share/doc/kuna/

    # `kuna` finds the spec tree relative to its own location, which only works
    # inside a source checkout -- point it at the installed one. --set-default
    # so a user pointing KUNA_SPECS at their own rebuilt specs still wins.
    wrapProgram $out/bin/kuna \
      --set-default KUNA_SPECS $out/share/kuna/specs

    # The engine console takes the same tree via SLEIGHHOME (kuna passes it
    # explicitly, so this is only for running decomp_dbg by hand).
    for engine in decomp_dbg decomp_test_dbg; do
      wrapProgram $out/bin/$engine \
        --set-default SLEIGHHOME $out/share/kuna/specs
    done
  '';

  # End-to-end: decompile a real function out of a real ELF with the specs this
  # build compiled. This is the check that catches a spec tree that did not get
  # built or did not get installed -- `kuna --help` would pass either way.
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    cat > hello.c <<'EOF'
    int add(int a, int b) { return a + b; }
    int main(void) { return add(2, 3); }
    EOF
    cc -o hello hello.c
    $out/bin/kuna decompile ./hello add | tee decompiled.c
    grep -q "add" decompiled.c

    runHook postInstallCheck
  '';

  meta = {
    description = "Agent-first decompiler in Rust, ported from Ghidra's decompiler";
    homepage = "https://github.com/Noelo-Lab/kuna";
    license = lib.licenses.asl20;
    mainProgram = "kuna";
    platforms = lib.platforms.linux;
  };
})
