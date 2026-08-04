{ lib
, python3Packages
, fetchFromGitHub
, makeWrapper
, binutils      # provides `strings`
, gnugrep       # provides `grep`
, imagemagick   # image manipulation
, exiftool      # image EXIF metadata
, steghide      # steganography
, tesseract     # OCR
}:

python3Packages.buildPythonApplication rec {
  pname = "webgrep-tool";
  version = "1.19-unstable-2024";

  src = fetchFromGitHub {
    owner = "dhondta";
    repo = "webgrep";
    rev = "d8b642d8f254b3571c55645712d972186612129b";
    hash = "sha256-lHACbfiU85YhWdXnF+aFcsvc9p+nVCVgtP25F++z1Ik=";
  };

  # setup.py is a plain setuptools script installing the `webgrep` script.
  format = "setuptools";

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = with python3Packages; [
    beautifulsoup4
    coloredlogs
    jsbeautifier
    requests
  ];

  # No test suite upstream.
  doCheck = false;

  # webgrep shells out to these external CLI tools at runtime; make them
  # available on PATH via a wrapper.
  postFixup = ''
    wrapProgram $out/bin/webgrep \
      --prefix PATH : ${lib.makeBinPath [
        binutils
        gnugrep
        imagemagick
        exiftool
        steghide
        tesseract
      ]}
  '';

  meta = {
    description = "Grep for a Web page with extra features like JS deobfuscation and OCR";
    homepage = "https://github.com/dhondta/webgrep";
    license = lib.licenses.gpl3Plus;
    mainProgram = "webgrep";
  };
}
