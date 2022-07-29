{ lib, stdenv, fetchFromGitHub, makeWrapper, guile }:

stdenv.mkDerivation rec {
  pname = "jaro";
  version = "2021-04-01";

  src = fetchFromGitHub {
    owner = "isamert";
    repo = "jaro";
    rev = "d553a51202d16cca032ca8171e033aded888d789";
    sha256 = "sha256-j8sMqlDyBxw/GGIEXUeLgZDcZI8P5xtr9FM5D0k9rZc=";
  };

  buildInputs = [ makeWrapper ];
  dontBuild = true;
  doCheck = false;

  installPhase = ''
    mkdir -p $out/bin
    cp jaro $out/bin
    wrapProgram $out/bin/jaro --prefix PATH : ${lib.makeBinPath [ guile ]} \
                              --set GUILE_AUTO_COMPILE 0
  '';
}
