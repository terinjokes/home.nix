{ lib, buildGoModule, fetchFromGitHub, makeWrapper }:

buildGoModule rec {
  pname = "khinsider";
  version = "2.0.1";

  nativeBuildInputs = [ makeWrapper ];

  src = fetchFromGitHub {
    owner = "marcus-crane";
    repo = "khinsider";
    rev = "v${version}";
    sha256 = "0bc3i70a9d7dkfky2y40ykhkvprck6qca449w4gychn9yl1154rx";
  };

  ldflags = [
    "-X main.version=v${version}"
    "-X main.commit=${src.rev}"
    "-X main.date=1980-01-01T00:00:00Z"
    "-X main.builtBy=nixpkgs"
  ];

  subPackages = [ "." ];

  vendorSha256 = "1an6b3f9s26127dp51vlsvhfvd6vrwncdv41vpyd59wr3751gwvf";

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
