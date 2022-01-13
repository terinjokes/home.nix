{ fetchurl }:

{
  luca = fetchurl {
    url =
      "https://archive.fo/170Hd/d44e3a670bd1b8e60a01caf159e145f706aff0f9.jpg";
    sha1 = "d44e3a670bd1b8e60a01caf159e145f706aff0f9";
  };
  ryuji = fetchurl {
    url =
      "https://archive.fo/yHNt4/ee3da86805a82e0a8581c8bc61a8eee1f112baef.jpg";
    sha1 = "ee3da86805a82e0a8581c8bc61a8eee1f112baef";
  };
}
