{ config, lib, pkgs, ... }:

let
  wallpapers = pkgs.callPackage ../wallpapers.nix { };
  unstable = import <nixpkgs-unstable> { config = config.nixpkgs.config; };
in {
  imports = [ ../types/work.nix ];

  home.packages = with pkgs; [
    pavucontrol

    pamixer
    herbstluftwm

    minikube

    zoom-us
    signal-desktop
    xsane
  ];

  services.dunst = {
    enable = true;
    settings = {
      global = {
        follow = "mouse";
        geometry = "350x5-20+45";
        indicate_hidden = "yes";
        transparency = 0;
        notification_height = 75;
        frame_color = "#4C566A";
        frame_width = 2;
        separator_color = "frame";
        separator_height = 5;
        padding = 10;
        horizontal_padding = 10;
        sort = "yes";
        font = "Arimo 10";
        markup = "full";
        format = "<b>%s</b>\\n%b";
        word_wrap = "yes";
        stack_duplicates = true;
        show_indicators = "yes";
        icon_position = "left";
        max_icon_size = 64;
        dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p dunst";
        browser = "${config.programs.firefox.package}/bin/firefox";
      };
      shortcuts = {
        close = "ctrl+space";
        close_all = "ctrl+shift+space";
        history = "ctrl+grave";
        context = "ctrl+shift+period";
      };
      urgency_low = {
        background = "#3b4252";
        foreground = "#eceff4";
        frame_color = "#4c566a";
        timeout = 10;
      };
      urgency_normal = {
        background = "#3b4252";
        foreground = "#eceff4";
        timeout = 10;
      };
      urgency_critical = {
        background = "#3b4252";
        foreground = "#eceff4";
        frame_color = "#bf616a";
        timeout = 0;
      };
    };
  };

  services.xsecurelock.enable = true;

  services.picom = {
    enable = true;
    vSync = true;
  };

  programs.rofi = {
    enable = true;
    theme = "Arc-Dark";
    extraConfig = {
      drun-show-actions = true;
      show-icons = true;
      modi = "drun,run";
    };
  };

  programs.ssh = {
    matchBlocks = {
      "srvpi" = {
        hostname = "192.168.2.10";
        extraOptions = {
          IdentityAgent = "/run/user/1000/yubikey-agent/yubikey-agent.sock";
        };
      };
      "github.com" = {
        extraOptions = {
          IdentityAgent = "/run/user/1000/yubikey-agent/yubikey-agent.sock";
        };
      };
      "100.75.69.73" = {
        extraOptions = {
          IdentityAgent = "/run/user/1000/yubikey-agent/yubikey-agent.sock";
        };
      };
    };
  };

  services.keynav.enable = true;

  services.redshift = {
    enable = true;
    provider = "geoclue2";
  };

  services.syncthing = {
    enable = true;
    tray.enable = true;
  };

  services.grobi = {
    enable = true;
    executeAfter =
      [ "${pkgs.systemd}/bin/systemctl --user restart polybar.service" ];
    rules = [
      {
        name = "Desk TB4";
        outputs_connected = [ "DP-3" ];
        outputs_present = [ "eDP-1" ];
        configure_single = "DP-3";
        primary = "DP-3";
        atomic = true;
        execute_after = [
          "${pkgs.herbstluftwm}/bin/herbstclient set_monitors 3840x2160+0+0"
          "${pkgs.feh}/bin/feh --bg-fill --no-fehbg ${wallpapers.ryuji-real}"
        ];
      }
      {
        name = "Fallback";
        configure_single = "eDP-1";
        primary = "eDP-1";
        atomic = true;
        execute_after = [
          "${pkgs.herbstluftwm}/bin/herbstclient set_monitors 3840x2400+0+0"
          "${pkgs.feh}/bin/feh --bg-fill --no-fehbg ${wallpapers.ryuji-real}"
        ];
      }
    ];
  };

  services.easyeffects.enable = true;
  services.blueman-applet.enable = true;

  services.polybar = {
    enable = true;
    config = {
      "bar/base" = {
        width = "100%";
        height = "22";

        line-size = 1;
        padding = 0;
        module-margin = 1;

        font-0 = "Berkeley Mono Variable:size=8;3";
        font-1 = "Sarasa Mono CL:size=8;3";
        font-2 = "Noto Emoji:scale=13";
        font-3 = "Material Icons Round:size=10;3";
        background = "#2E3440";
        foreground = "#D8DEE9";

        enable-ipc = true;
      };
      "bar/top" = {
        "inherit" = "bar/base";

        modules-left = "xworkspaces";
        modules-center = "xwindow";
        modules-right = "pulseaudio battery wireless-network date";

        tray-position = "right";
      };
      "bar/bottom" = {
        "inherit" = "bar/base";
        bottom = true;

        modules-right = "info-techinc info-unread";
      };
      "module/wireless-network" = {
        type = "internal/network";
        interface-type = "wireless";
        format-connected = "<ramp-signal> <label-connected>";
        label-connected = "%essid%";

        format-connected-underline = "#88C0D0";
        format-connected-margin = 1;
        format-connected-padding = 2;

        ramp-signal-0 = "%{T4}%{T-}";
        ramp-signal-1 = "%{T4}%{T-}";
        ramp-signal-2 = "%{T4}%{T-}";
        ramp-signal-3 = "%{T4}%{T-}";
        ramp-signal-4 = "%{T4}%{T-}";
      };
      "module/info-unread" = {
        type = "custom/script";
        exec = "${
            pkgs.writeOilApplication {
              name = "info-maildir-unread";
              runtimeInputs = with pkgs; [ mblaze coreutils ];
              text = ''
                var count = $(mdirs -a ~/Maildir | mlist -s | wc -l)
                if (count !== "0") {
                  printf '%%{T4}%s%%{T-} %d\n' $'\uf18a' $count
                } else {
                  echo ""
                }
              '';
            }
          }/bin/info-maildir-unread";
        label-foreground = "#BF616A";
        label-underline = "#BF616A";
        label-margin = 1;
        label-padding = 2;
      };
      "module/info-techinc" = {
        type = "custom/script";
        exec = "${
            pkgs.writeBabashkaApplication {
              name = "info-techinc";
              runtimeInputs = [ pkgs.curl ];
              text = ''
                (require '[babashka.curl :as curl])

                (defn format-color [color]
                  (str "%{F" color "}"))
                (defn format-underline [color]
                  (str "%{u" color "}"))
                (defn icon [code-point]
                  (str "%{T4}" code-point "%{T-}"))

                (let [state (:body (curl/get "https://techinc.nl/space/spacestate" {:headers ["User-Agent" "member/terinjokes"]}))]
                  (cond (= state "closed") (println (format-color "#BF616A") (format-underline "#BF616A") "%{+u}" (icon "\ue335") "Closed" "%{-u}")
                        (= state "open") (println (format-color "#A3BE8C") (format-underline "#A3Be8C") "%{+u}" (icon "\ue335") "Open" "%{-u}")))
              '';
            }
          }/bin/info-techinc";
        interval = 300;
        label-margin = 1;
        label-padding = 2;
      };
      "module/battery" = {
        type = "internal/battery";
        battery = "BAT0";
        adapter = "AC";
        format-charging-underline = "#D8DEE9";
        format-discharging-underline = "#EBCB8B";
        format-discharging-foreground = "#EBCB8B";
        label-full-foreground = "#A3BE8C";
        label-full-underline = "#A3BE8C";
        label-charging-margin = 1;
        label-discharging-margin = 1;
        label-full-margin = 1;
        label-charging-padding = 1;
        label-discharging-padding = 1;
        label-full-padding = 1;
      };
      "module/date" = {
        type = "internal/date";
        internal = 5;
        date = "%Y-%m-%d";
        time = "%H:%M";
        label = "%time% %date%";
        label-margin = 1;
        label-underline = "#88C0D0";
        label-padding = 2;
      };
      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        use-ui-max = false;
        format-volume-underline = "#B48EAD";
        label-muted-padding = 1;
        label-muted-foreground = "#BF616A";
        label-muted-underline = "#BF616A";
        label-volume-padding = 1;
      };
      "module/xworkspaces" = {
        type = "internal/xworkspaces";
        format = "<label-state>";

        label-active-underline = "#8FBCBB";
        label-active-foreground = "#8FBCBB";
        label-active-padding = 2;

        label-occupied-underline = "#81A1C1";
        label-occupied-foreground = "#81A1C1";
        label-occupied-padding = 2;

        label-urgent-foreground = "#BF616A";
        label-urgent-background = "#D8DEE9";
        label-urgent-padding = 2;

        label-empty-foreground = "#4c566a";
        label-empty-padding = 2;
      };
      "module/xwindow" = {
        type = "internal/xwindow";
        format-foreground = "#8FBCBB";
        format-underline = "#8FBCBB";
        format-padding = 1;
        label = "%title%";
        label-empty = "-- none --";
      };
    };
    script = ''
      polybar top &
      polybar bottom &
    '';
  };

  systemd.user.services.yubikey-agent = {
    Unit = {
      Description = "Seamless ssh-agent for YubiKeys";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };

    Service = {
      Environment = "PATH=${
          (lib.makeBinPath
            (with pkgs; [ pinentry-qt libsForQt5.qtstyleplugin-kvantum ]))
        }";
      ExecStart =
        "${pkgs.yubikey-agent}/bin/yubikey-agent -l %t/yubikey-agent/yubikey-agent.sock";
      ExecReload = "${pkgs.utillinux}/bin/kill -HUP $MAINPID";
      UMask = 177;
      RuntimeDirectory = "yubikey-agent";
    };
  };

  xsession = {
    enable = true;
    scriptPath = ".hm-xsession";
    importedVariables = [ "PATH" "QT_STYLE_OVERRIDE" ];
    windowManager.command = "${pkgs.herbstluftwm}/bin/herbstluftwm";

    numlock.enable = true;
  };

  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.gnome3.adwaita-icon-theme;
    size = 16;
    x11.enable = true;
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
    "x-scheme-handler/about" = [ "firefox.desktop" ];
    "x-scheme-handler/unknown" = [ "firefox.desktop" ];
  };
}
