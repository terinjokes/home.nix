{ lib, stdenv, fetchFromGitHub, makeWrapper, kubectl, ... }:

stdenv.mkDerivation rec {
  pname = "kubectx";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "ahmetb";
    repo = pname;
    rev = "v${version}";
    sha256 = "1c7y5hj4w72bm6y3riw0acayn4w9x7bbf1vykqcprbyw3a3dvcsw";
  };

  buildInputs = [ makeWrapper ];

  dontBuild = true;
  doCheck = false;

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/zsh/site-functions
    mkdir -p $out/share/bash-completion/completions
    mkdir -p $out/share/fish/vendor_completions.d
    cp kubectx $out/bin
    cp kubens $out/bin
    # Provide ZSH completions
    cp completion/kubectx.zsh $out/share/zsh/site-functions/_kubectx
    cp completion/kubens.zsh $out/share/zsh/site-functions/_kubens
    # Provide BASH completions
    cp completion/kubectx.bash $out/share/bash-completion/completions/kubectx
    cp completion/kubens.bash $out/share/bash-completion/completions/kubens
    # Provide FISH completions
    cp completion/*.fish $out/share/fish/vendor_completions.d/
    for f in $out/bin/*; do
      wrapProgram $f --prefix PATH : ${lib.makeBinPath [ kubectl ]}
    done
  '';
}
