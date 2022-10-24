{ lib, buildFirefoxXpiAddon }:

buildFirefoxXpiAddon {
  pname = "fx_cast";
  version = "0.3.1";
  addonId = "fx_cast@matt.tf";
  url =
    "https://github.com/hensm/fx_cast/releases/download/v0.3.1/fx_cast-0.3.1.xpi";
  sha256 = "sha256-zaYnUJpJkRAPSCpM3S20PjMS4aeBtQGhXB2wgdlFkSQ=";
  meta = with lib; {
    homepage = "https://hensm.github.io/fx_cast/";
    description =
      "A browser extension that enables Chromecast support for casting web apps";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
