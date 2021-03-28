{ lib, stdenv, fetchurl, fetchFromGitHub, icu, openssl, fontconfig, lttngUst
, curl, krb5, dotnetSDK, dotnetPackages, makeWrapper, autoPatchelfHook
, linkFarmFromDrvs }:

let
  deps = import ./deps.nix {
    fetchNuGet = { name, version, sha256 }:
      fetchurl {
        name = "nuget-${name}-${version}.nupkg";
        url = "https://www.nuget.org/api/v2/package/${name}/${version}";
        inherit sha256;
      };
  };
  version = "2020-03-27";
  runtimeDeps = [ icu openssl ];

in stdenv.mkDerivation {
  pname = "aaru";
  inherit version;

  src = fetchFromGitHub {
    owner = "aaru-dps";
    repo = "Aaru";
    rev = "8a0064e870dcebf24073e69b46f1a706094d49f8";
    fetchSubmodules = true;
    sha256 = "15s0rwbln6ljysrb2544z2mcv3zlkpy7k2jj54wzdimwl5si6kv5";
  };

  buildInputs = [ stdenv.cc.cc.lib fontconfig.lib lttngUst curl krb5 ];

  nativeBuildInputs =
    [ dotnetSDK dotnetPackages.Nuget makeWrapper autoPatchelfHook ];

  buildPhase = ''
    # workaround zip "DateTimeOffset" bug
    find . -exec touch -m -d '1/1/1980' {} +

    export HOME=$TMP/home
    export DOTNET_CLI_TELEMETRY_OPTOUT=1
    export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

    nuget sources Disable -Name "nuget.org"
    nuget sources Add -Name tmpsrc -Source $TMP/nuget
    nuget init ${linkFarmFromDrvs "deps" deps} $TMP/nuget

    dotnet restore --source $TMP/nuget -r linux-x64 Aaru/Aaru.csproj
    dotnet publish --no-restore --output $out/lib/$pname -c Release -r linux-x64 Aaru/Aaru.csproj
  '';

  installPhase = ''
    makeWrapper $out/lib/$pname/aaru $out/bin/$pname \
      --set DOTNET_ROOT "${dotnetSDK}" \
      --suffix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeDeps}"
  '';

  dontStrip = true;

  meta = with lib; {
    description = "Aaru Data Preservation Suite";
    homepage = "https://www.aaru.app/";
    license = with licenses; [ gpl3 mit lgpl21 ];
    maintainers = with maintainers; [ terin ];
    platforms = [ "x86_64-linux" ];
  };
}
