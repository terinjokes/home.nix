{ config, lib, pkgs, ... }:

let wallpapers = pkgs.callPackage ../wallpapers.nix { };
in {
  nixpkgs.overlays = [
    (self: super: {
      khinsider = super.callPackage ../packages/khinsider {
        buildGoModule = pkgs.buildGo117Module;
      };
    })
  ];

  home.packages = with pkgs; [
    google-chrome
    herbstluftwm

    pavucontrol
    pamixer

    _1password
    _1password-gui

    khinsider
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
        browser = "${pkgs.google-chrome}/bin/google-chrome-stable";
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
      show-icons = true;
      modi = "drun,run";
    };
  };

  programs.firefox.enable = true;

  programs.ssh = {
    matchBlocks = {
      "github.com" = {
        extraOptions = {
          IdentityAgent = "/run/user/1000/yubikey-agent/yubikey-agent.sock";
        };
      };
      "138.68.58.96" = {
        extraOptions = {
          IdentityAgent = "/run/user/1000/yubikey-agent/yubikey-agent.sock";
        };
      };
      "srvpi" = {
        hostname = "100.83.216.39";
        extraOptions = {
          IdentityAgent = "/run/user/1000/yubikey-agent/yubikey-agent.sock";
        };
      };
      "mullvad" = {
        hostname = "100.103.120.71";
        extraOptions = {
          IdentityAgent = "/run/user/1000/yubikey-agent/yubikey-agent.sock";
        };
      };
      "mullvad-boot" = {
        hostname = "192.168.1.3";
        port = 2222;
        proxyJump = "srvpi";
        user = "root";
        extraOptions = {
          IdentityAgent = "/run/user/1000/yubikey-agent/yubikey-agent.sock";
        };
      };
    };
  };

  services.keynav.enable = true;

  services.gammastep = {
    enable = true;
    provider = "geoclue2";
    tray = true;
  };

  services.grobi = {
    enable = true;
    executeAfter =
      [ "${pkgs.systemd}/bin/systemctl --user restart polybar.service" ];
    rules = [
      {
        name = "Desk";
        outputs_connected = [ "DP-1-1" ];
        outputs_present = [ "eDP-1" ];
        configure_single = "DP-1-1";
        primary = "DP-1-1";
        atomic = true;
        execute_after = [
          "${pkgs.herbstluftwm}/bin/herbstclient set_monitors 3840x2160+0+0"
          "${pkgs.feh}/bin/feh --bg-fill --no-fehbg ${wallpapers.luca}"
        ];
      }
      {
        name = "Fallback";
        configure_single = "eDP-1";
        primary = "eDP-1";
        atomic = true;
        execute_after = [
          "${pkgs.herbstluftwm}/bin/herbstclient set_monitors 2256x1504+0+0"
          "${pkgs.feh}/bin/feh --bg-fill --no-fehbg ${wallpapers.luca}"
        ];
      }
    ];
  };

  services.polybar = {
    enable = true;
    config = {
      "bar/base" = {
        width = "100%";
        height = "22";

        line-size = 1;
        padding = 0;
        module-margin = 1;

        font-0 = "Iosevka Aile:size=8;3";
        font-1 = "Sarasa Mono CL:size=8;3";
        font-2 = "NotoEmoji:scale=13";
        background = "#2E3440";
        foreground = "#D8DEE9";

        enable-ipc = true;
      };
      "bar/eDP-1" = {
        "inherit" = "bar/base";
        monitor = "eDP-1";

        modules-left = "xworkspaces";
        modules-center = "xwindow";
        modules-right = "pulseaudio battery-BAT1 date";

        tray-position = "right";
      };
      "bar/DP-1-1" = {
        "inherit" = "bar/base";
        monitor = "DP-1-1";

        modules-left = "xworkspaces";
        modules-center = "xwindow";
        modules-right = "pulseaudio battery-BAT1 date";

        tray-position = "right";
      };
      "module/battery-BAT1" = {
        type = "internal/battery";
        battery = "BAT1";
        adapter = "ACAD";
        full-at = 80;
        format-charging-underline = "#D8DEE9";
        format-discharging-underline = "#EBCB8B";
        format-discharging-foreground = "#EBCB8B";
        label-full = "%percentage_raw%%";
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
        click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
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
    script = "polybar eDP-1 & polybar DP-1-1 &";
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

    pointerCursor = {
      name = "Adwaita";
      package = pkgs.gnome3.adwaita-icon-theme;
      size = 16;
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "google-chrome.desktop" ];
    "x-scheme-handler/http" = [ "google-chrome.desktop" ];
    "x-scheme-handler/https" = [ "google-chrome.desktop" ];
    "x-scheme-handler/about" = [ "google-chrome.desktop" ];
    "x-scheme-handler/unknown" = [ "google-chrome.desktop" ];
  };
}
