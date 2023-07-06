{ lib, buildFirefoxXpiAddon }:

buildFirefoxXpiAddon {
  pname = "tst-colored-tabs";
  version = "0.7.1";
  addonId = "tst-colored-tabs@murz";
  url =
    "https://addons.mozilla.org/firefox/downloads/file/3807216/tst_colored_tabs-0.7.1.xpi";
  sha256 = "78b11c71e3f0a04a1202be0cb2ad4bf4450df212d39ec1880bda42974596c4c9";
  meta = with lib; {
    homepage = "https://github.com/MurzNN/TST-Colored-tabs";
    description =
      "TST Colored Tabs addon adds colourized background to each tab based on current tab domain, so all opened tabs with same domain have same colour background in list for easier tab navigation.";
    license = licenses.gpl3Only;
    platforms = platforms.all;
  };
}
