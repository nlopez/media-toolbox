{ python3Packages, fetchPypi, yt-dlp }:

python3Packages.buildPythonApplication rec {
  pname = "tubeup";
  version = "2026.5.8";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-THVCOkKUk73a947eADGUeTiz6zVDWEfuZZe0mkvnatc=";
  };

  build-system = [ python3Packages.setuptools ];

  dependencies = [
    python3Packages.internetarchive
    python3Packages.docopt
    yt-dlp
  ];

  # tubeup pins docopt==0.6.2 exactly; nixpkgs' version may differ slightly.
  pythonRelaxDeps = [ "docopt" ];

  doCheck = false;
  pythonImportsCheck = [ "tubeup" ];

  meta.mainProgram = "tubeup";
}
