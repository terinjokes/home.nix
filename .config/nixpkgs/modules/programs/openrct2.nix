{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.openrct2;

  eitherStrBoolIntList = with types;
    either str (either bool (either int (either float (listOf str))));

  configFile = pkgs.writeText "config.ini"
    ((generators.toINI { } cfg.config) + "\n" + cfg.extraConfig);

  foldPackageListToAttr = (path: list:
    (builtins.listToAttrs (map (p: {
      "name" = "OpenRCT2/" + path + "/" + p.name;
      "value" = {
        source = p.outPath;
        recursive = true;
      };
    }) list)));

in {
  meta.maintainers = [ "terinjokes@gmail.com" ];

  options.programs.openrct2 = {
    enable = mkEnableOption
      "OpenRCT2, an open-source re-implementation of RollerCoaster Tycoon 2";

    config = mkOption {
      type = (types.attrsOf (types.attrsOf eitherStrBoolIntList));
      description = ''
        OpenRCT2 configuration. Can be either a path to a file, or set of
        attributes that will be used to create the final configuration.
      '';
      default = { };
      example = literalExample ''
        {
          general = {
            show_fps = true;
            uncap_fps = true;
          };
        }
      '';
    };

    extraConfig = mkOption {
      type = types.lines;
      description = "Additional configuration to add.";
      default = "";
      example = ''
        [twitch]
        follow_peep_names = true
      '';
    };

    plugins = mkOption {
      type = types.listOf types.package;
      description = "Additional plugins to add.";
      default = [ ];
      example = ''
        (pkgs.fetchurl {
          url =
            "https://github.com/tubbo/openrct2-benchwarmer/releases/download/v0.1.1/benchwarmer-v0.1.1.js";
          sha256 = "0aljssczc087iisbdlbag66xj4fp5cwi0qv5hrq2yz67k57wic5k";
        })
      '';
    };

    scenarios = mkOption {
      type = types.listOf types.package;
      description = "Additional scenarios to add.";
      default = [ ];
      example = ''
        (pkgs.fetchurl {
          url =
            "https://downloads.rctgo.com/scenarios/2020-05/20042/The%20Starry%20Night.sc6";
          name = "20042-the-starry-night.sc6";
          sha256 = "1z2qna03068w7hsg842wn7fiq1j9wfma82zfchdd53xf2r1rs02n";
        })
      '';
    };

    tracks = mkOption {
      type = types.listOf types.package;
      description = "Additional tracks to add.";
      default = [ ];
      example = ''
        (pkgs.fetchurl {
          url = "https://downloads.rctgo.com/tracks/2017-12/17697/Gladiator.td6";
          sha256 = "1awh224ixf4zjrh4j42la9nvm1jx8qa1wfz6l7vq03rncas0wrar";
        })
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.openrct2 ];
    xdg.configFile = (foldPackageListToAttr "plugin" cfg.plugins)
      // (foldPackageListToAttr "track" cfg.tracks)
      // (foldPackageListToAttr "scenario" cfg.scenarios) // {
        "OpenRCT2/config.ini".source = configFile;
      };
  };
}
