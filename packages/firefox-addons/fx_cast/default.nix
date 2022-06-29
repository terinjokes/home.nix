{ lib, buildFirefoxXpiAddon }:

buildFirefoxXpiAddon {
  pname = "fx_cast";
  version = "0.2.0";
  addonId = "fx_cast@matt.tf";
  url =
    "https://github.com/hensm/fx_cast/releases/download/v0.2.0/fx_cast-0.2.0-fx.xpi";
  sha256 = "a8344e30a7111b772f9d0ba43bd2368e8a67575c0646b98cd8d3c4bc782beae3";
  meta = with lib; {
    homepage = "https://hensm.github.io/fx_cast/";
    description =
      "A browser extension that enables Chromecast support for casting web apps";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
