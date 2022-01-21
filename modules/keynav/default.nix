{ config, lib, pkgs, ... }:

let cfg = config.services.keynav;
in {
  config = lib.mkIf cfg.enable {
    systemd.user.services.keynav.Unit.X-Restart-Triggers =
      [ "${config.xdg.configFile."keynav/keynavrc".source}" ];
    xdg.configFile."keynav/keynavrc" = {
      text = ''
        clear
        Super_L+semicolon start
        Escape end
        ctrl+g end
        a history-back
        h cut-left
        j cut-down
        k cut-up
        l cut-right
        shift+h move-left
        shift+j move-down
        shift+k move-up
        shift+l move-right
        space warp,click 1,end
        1 click 1
        2 click 2
        3 click 3
        i click 4
        m click 5
        z windowzoom
        c cursorzoom 300 300
        w warp
        semicolon warp,end
      '';
    };
  };
}
