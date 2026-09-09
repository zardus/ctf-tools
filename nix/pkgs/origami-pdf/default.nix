{ lib
, ruby
, buildRubyGem
}:

let
  # Origami's only runtime dependency is not exposed in nixpkgs' generated
  # rubyPackages set, so build the small pure-Ruby gem alongside it.
  colorize = buildRubyGem rec {
    inherit ruby;
    name = "ruby${ruby.version}-${gemName}-${version}";
    gemName = "colorize";
    version = "0.8.1";
    source.sha256 = "sha256-C6DCpYIy+bcG3DBiHqaqZGju6hIOtvHMxAAQW5DEeYw=";
  };
in
buildRubyGem rec {
  inherit ruby;

  name = "${gemName}-${version}";
  gemName = "origami";
  version = "2.1.0";
  source.sha256 = "sha256-O/gq8FHPydrr2Lj/EAFvHlNr9X4oTPOhSjq7LDxHNX0=";

  # Ruby 3.4 treats this unbraced hash as keyword arguments to Hash.new.
  postInstall = ''
    substituteInPlace \
      "$GEM_HOME/gems/${gemName}-${version}/lib/origami/graphics/instruction.rb" \
      --replace-fail 'Hash.new(operands: [], render: lambda{})' \
                     'Hash.new({operands: [], render: lambda{}})'
  '';

  propagatedBuildInputs = [ colorize ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/pdfmetadata" --help >/dev/null
    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "Ruby framework and command-line tools for manipulating PDF files";
    homepage = "https://github.com/gdelugre/origami";
    license = licenses.lgpl3Plus;
    mainProgram = "pdfsh";
    platforms = platforms.unix;
  };
}
