{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.plasma-polkit-agent;
in {
  options.services.plasma-polkit-agent = {
    enable = mkEnableOption "Plasma PolicyKit Authentication Agent";
  };

  config = mkIf cfg.enable {
    systemd.user.services.plasma-polkit-agent = {
      Unit = {
        Description = "KDE PolicyKit Authentication Agent";
        PartOf = [ "graphical-session.target" ];
      };

      Install.WantedBy = [ "graphical-session.target" ];

      Service = {
        Environment = "PATH=${
            (lib.makeBinPath
              (with pkgs; [ pinentry-qt libsForQt5.qtstyleplugin-kvantum ]))
          }";
        ExecStart =
          "${pkgs.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1";
        Restart = "on-failure";
      };
    };
  };
}
