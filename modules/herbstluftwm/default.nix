{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.herbstluftwm;
  fn = rec {
    flattenAttrs = let
      recurse = path: value:
        if lib.isAttrs value && !lib.isDerivation value then
          lib.mapAttrsToList (name: value: recurse ([ name ] ++ path) value)
          value
        else if lib.length path > 1 then {
          ${lib.concatStringsSep "." (lib.reverseList path)} = value;
        } else {
          ${lib.head path} = value;
        };
    in attrs:
    lib.foldl lib.recursiveUpdate { } (lib.flatten (recurse [ ] attrs));
  };
in {
  options.programs.herbstluftwm = {
    enable = lib.mkEnableOption "herbstluftwm window manager";

    defaultTag = mkOption {
      type = types.nullOr types.str;
      description = ''
        Renames the default tag.
      '';
      default = null;
      example = "1";
    };

    tags = mkOption {
      type = with types; listOf str;
      description = ''
        Herbstluftwm tags to create.
      '';
      default = [ ];
      example = [ "1" "2" "3" ];
    };

    keybindings = mkOption {
      type = with types; attrsOf str;
      description = ''
        Keybindings to setup.
      '';
      default = { };
      example = {
        "Mod4-Mod1-q" = "quit";
        "Mod4-Mod1-r" = "reload";
      };
    };

    mousebindings = mkOption {
      type = with types; attrsOf str;
      description = ''
        Mousebindings to setup.
      '';
      default = { };
      example = {
        "Mod4-Button1" = "move";
        "Mod4-Button2" = "zoom";
        "Mod4-Button3" = "resize";
      };
    };

    settings = mkOption {
      type = with types; attrsOf (oneOf [ bool int str ]);
      description = ''
        Herbstluftwm settings.
      '';
      default = { };
      example = { window_gap = 5; };
    };

    attributes = mkOption {
      type = with types; attrsOf anything;
      description = ''
        Herbstluftwm attributes.
      '';
      default = { };
      example = {
        "theme.tiling" = 1;
        "theme.floating.reset" = 1;
      };
    };

    rules = mkOption {
      type = with types; listOf str;
      description = ''
        Herbstluftwm rules.
      '';
      default = [ ];
      example = [
        "focus=on"
        "windowtype~'_NET_WM_WINDOW_TYPE_(DIALOG|UTILITY|SPLASH)' floating=on"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."herbstluftwm/autostart" = {
      executable = true;
      text = let hc = "${pkgs.herbstluftwm}/bin/herbstclient";
      in ''
        #!${pkgs.runtimeShell}

        ${hc} emit_hook reload

        ${hc} keyunbind --all
        ${concatStringsSep "\n"
        (mapAttrsToList (k: v: "${hc} keybind ${k} ${v}") cfg.keybindings)}

        ${hc} mouseunbind --all
        ${concatStringsSep "\n"
        (mapAttrsToList (k: v: "${hc} mousebind ${k} ${v}") cfg.mousebindings)}

        ${lib.optionalString (cfg.defaultTag != null)
        "${hc} rename default ${cfg.defaultTag} || true"}
        ${concatStringsSep "\n" (map (tag: "${hc} add ${tag}") cfg.tags)}

        ${concatStringsSep "\n" (mapAttrsToList (k: v:
          "${hc} set ${k} ${
            if builtins.isBool v then
              (if v then "on" else "off")
            else
              toString v
          }") cfg.settings)}

        ${hc} attr tiling.reset 1
        ${hc} attr floating.reset 1
        ${concatStringsSep "\n"
        (mapAttrsToList (k: v: "${hc} attr ${k} ${toString v}")
          (fn.flattenAttrs cfg.attributes))}

        ${hc} unrule -F
        ${concatStringsSep "\n" (map (rule: "${hc} rule ${rule}") cfg.rules)}

        ${hc} unlock
      '';
      onChange = ''
        ${pkgs.herbstluftwm}/bin/herbstclient reload
      '';
    };
  };
}
