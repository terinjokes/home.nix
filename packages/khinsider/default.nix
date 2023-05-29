{ lib, buildGoModule, fetchFromGitHub, makeWrapper }:

buildGoModule rec {
  pname = "khinsider";
  version = "2.0.7";

  nativeBuildInputs = [ makeWrapper ];

  src = fetchFromGitHub {
    owner = "marcus-crane";
    repo = "khinsider";
    rev = "v${version}";
    sha256 = "sha256-sJacVi85flrkiQeTP7uO3ltA/H4ha4h3Gd3R9jUMWPE=";
  };

  ldflags = [
    "-X main.version=v${version}"
    "-X main.commit=${src.rev}"
    "-X main.date=1980-01-01T00:00:00Z"
    "-X main.builtBy=nixpkgs"
  ];

  subPackages = [ "." ];

  vendorSha256 = "sha256-Lstqz/O934mC9aHXyOIBIIMdO5g+VlgOnNGXGJVpumQ=";

  postInstall = ''
    wrapProgram "$out/bin/khinsider" --set KHINSIDER_NO_UPDATE true
  '';

  meta = with lib; {
    description = "A khinsider downloader written in Go.";
    license = licenses.mit;
    homepage = "https://github.com/marcus-crane/khinsider";
    maintainers = with maintainers; [ terin ];
  };
}
