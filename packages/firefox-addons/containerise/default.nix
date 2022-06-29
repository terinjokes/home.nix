{ lib, buildFirefoxXpiAddon }:

buildFirefoxXpiAddon {
  pname = "containerise";
  version = "3.9.0";
  addonId = "containerise@kinte.sh";
  url =
    "https://addons.mozilla.org/firefox/downloads/file/3724805/containerise-3.9.0.xpi";
  sha256 = "bf511aa160512c5ece421d472977973d92e1609a248020e708561382aa10d1e5";
  meta = with lib; {
    homepage = "https://github.com/kintesh/containerise";
    description =
      "Automatically open websites in a dedicated container. Simply add rules to map domain or subdomain to your container.";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
