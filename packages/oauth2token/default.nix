{ lib, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "oauth2token";
  version = "0.0.3";

  propagatedBuildInputs = with python3Packages; [ google-auth-oauthlib pyxdg ];

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-3wJHPYP74rTdqAfVKZ7LrzwP4tCeV+VRasoqs1uw/vg=";
  };

  meta = with lib; {
    homepage = "https://github.com/VannTen/oauth2token";
    description = "CLI tools to create and use OAuth2 tokens";
    license = licenses.gpl3Only;
    platforms = platforms.all;
  };
}
