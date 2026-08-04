{ lib
, stdenv
, fetchFromGitHub
, bundlerEnv
, ruby
, makeWrapper
, sqlite
, espeak
}:

# BeEF (Browser Exploitation Framework) is a Ruby application driven by
# bundler. Upstream's ctf-tools installer clones the repo, strips the
# :test gem group from the Gemfile (heavy dev-only deps: selenium,
# geckodriver-helper, curb, capybara, ...), runs `bundle install`, and
# drops a bin/beef wrapper that sets GEM_HOME/GEM_PATH and execs ./beef.
#
# We reproduce that here: the checked-in Gemfile/Gemfile.lock have the
# :test group already removed (the lock was regenerated with bundler),
# and gemset.nix was produced from that lock with bundix. bundlerEnv
# builds the exact gem closure; a makeWrapper launcher runs the repo's
# ./beef under the wrapped ruby (which sets BUNDLE_GEMFILE etc.), from
# the app directory as the interpreter requires.

let
  rev = "7f4d40432f84b82098433008d5dc6d9be64053df";

  gems = bundlerEnv {
    name = "beef-gems";
    inherit ruby;
    gemdir = ./.;
  };
in
stdenv.mkDerivation {
  pname = "beef";
  version = "0.6.0.0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "beefproject";
    repo = "beef";
    inherit rev;
    hash = "sha256-wneR0h9VyYgvmCP0oENs5ZKrSJfVPPM4Om8bWMZB1CE=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/beef
    cp -a . $out/share/beef/

    # Use the Gemfile/Gemfile.lock that match the pinned gemset (test
    # group removed), so bundler/setup inside beef is satisfied.
    cp ${./Gemfile} $out/share/beef/Gemfile
    cp ${./Gemfile.lock} $out/share/beef/Gemfile.lock

    mkdir -p $out/bin
    makeWrapper ${gems.wrappedRuby}/bin/ruby $out/bin/beef \
      --add-flags "$out/share/beef/beef" \
      --chdir "$out/share/beef" \
      --set BUNDLE_GEMFILE "${gems.confFiles}/Gemfile" \
      --prefix PATH : "${lib.makeBinPath [ espeak ]}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "BeEF - The Browser Exploitation Framework";
    homepage = "https://github.com/beefproject/beef";
    license = licenses.free;
    mainProgram = "beef";
    platforms = platforms.linux;
  };
}
