{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "khinsider";
  version = "1.11.1";

  src = fetchFromGitHub {
    owner = "marcus-crane";
    repo = "khinsider";
    rev = "v${version}";
    sha256 = "18ifz9k4dysykpgr2l0cmxjg2w0a5rqgjns3c7vjbl8gs5vc557p";
  };

  vendorSha256 = "0mcp4vcg5jxsdb7s29nhblhp5kg3j3vfz6bmwl9gwcsd7qgqhld2";

  meta = with lib; {
    description = "A khinsider downloader written in Go.";
    license = licenses.mit;
    homepage = "https://github.com/marcus-crane/khinsider";
    maintainers = with maintainers; [ terin ];
  };
}
