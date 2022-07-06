{ lib, fetchurl, linkFarm }:

let
  version = "2022-06-27";
  rev = "8825e59fa98ec04a3bd6c7cf0ef7b7abf07c3cec";
in linkFarm "material-icons-${version}" [
  {
    name = "share/fonts/truetype/MaterialIcons-Regular.ttf";
    path = (fetchurl {
      name = "material-icons-${version}-regular.ttf";
      url =
        "https://github.com/google/material-design-icons/raw/${rev}/font/MaterialIcons-Regular.ttf";
      sha256 = "sha256-o+96+LeeMqSs34vNXH2CJ73VV3UPdqI8zxHKAqtcq+M=";
    });
  }
  {
    name = "share/fonts/opentype/MaterialIconsOutlined-Regular.otf";
    path = (fetchurl {
      name = "material-icons-outline-${version}-regular.otf";
      url =
        "https://github.com/google/material-design-icons/raw/${rev}/font/MaterialIconsOutlined-Regular.otf";
      sha256 = "sha256-OtOeToZHU/eMvK6UJX6nSWsauwtdzjwoFoA9VWZpgP8=";
    });
  }
  {
    name = "share/fonts/opentype/MaterialIconsRound-Regular.otf";
    path = (fetchurl {
      name = "material-icons-round-${version}-regular.otf";
      url =
        "https://github.com/google/material-design-icons/raw/${rev}/font/MaterialIconsRound-Regular.otf";
      sha256 = "sha256-4WiuaO//pOJLga8eD0wgfnsjXWYeRvaBcPrgrZhbKtY=";
    });
  }
  {
    name = "share/fonts/opentype/MaterialIconsSharp-Regular.otf";
    path = (fetchurl {
      name = "material-icons-sharp-${version}-regular.otf";
      url =
        "https://github.com/google/material-design-icons/raw/${rev}/font/MaterialIconsSharp-Regular.otf";
      sha256 = "sha256-U/0ZixTdMX1PQMMrHohPBUpK8/w1r2pG6HBiRGTLchw=";
    });
  }
  {
    name = "share/fonts/opentype/MaterialIconsTwoTone-Regular.otf";
    path = (fetchurl {
      name = "material-icons-twotone-${version}-regular.otf";
      url =
        "https://github.com/google/material-design-icons/raw/${rev}/font/MaterialIconsTwoTone-Regular.otf";
      sha256 = "sha256-VtdO/2y+BpoarUORXhqGc6hADQRrG701HUuUiPXWThc=";
    });
  }
]
