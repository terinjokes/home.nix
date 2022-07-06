{ lib, stdenv, fetchFromGitHub, autoconf, automake, libtool, cyrus_sasl }:

stdenv.mkDerivation rec {
  pname = "cyrus-sasl-xoauth2";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "moriyoshi";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-lI8uKtVxrziQ8q/Ss+QTgg1xTObZUTAzjL3MYmtwyd8=";
  };

  nativeBuildInputs = [ autoconf automake ];
  buildInputs = [ libtool cyrus_sasl ];

  preConfigure = ''
    ./autogen.sh
  '';

  configureFlags = [ "--with-cyrus-sasl=/" ];
  installFlags = [ "DESTDIR=$(out)" ];
}
