{ lib, buildGoModule, fetchFromGitHub, makeWrapper }:

buildGoModule rec {
  pname = "khinsider";
  version = "2.0.2";

  nativeBuildInputs = [ makeWrapper ];

  src = fetchFromGitHub {
    owner = "marcus-crane";
    repo = "khinsider";
    rev = "v${version}";
    sha256 = "0r58rk03mdnl0mlckd3xxkvfi68v9dl8snc7xqqgaxqv2y1g88z6";
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
