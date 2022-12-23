{ lib, buildFirefoxXpiAddon }:

buildFirefoxXpiAddon {
  pname = "simple-translate";
  version = "2.8.0";
  addonId = "simple-translate@sienori";
  url =
    "https://addons.mozilla.org/firefox/downloads/file/3996565/simple_translate-2.8.0.xpi";
  sha256 = "fcee11b477465c87d5b1f3c922e40edbcbf2c99a95022f57265a8fab22047ca8";
  meta = with lib; {
    homepage = "https://simple-translate.sienori.com/";
    description =
      "Quickly translate selected or typed text on web pages. Supports Google Translate and DeepL API.";
    license = licenses.mpl20;
    platforms = platforms.all;
  };
}
