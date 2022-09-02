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
    herbstluftwm

    pavucontrol
    pamixer

    khinsider
  ];

  programs.firefox = {
    profiles = {
      private = {
        id = 1;
        settings = {
          "app.shield.optoutstudies.enabled" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.shell.checkDefaultBrowser" = false;
          "browser.toolbars.bookmarks.visibility" = "never";
          "browser.urlbar.suggest.quicksuggest.sponsored" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "dom.security.https_only_mode" = true;
          "dom.security.https_only_mode_ever_enabled" = true;
          "extensions.formautofill.addresses.enabled" = false;
          "extensions.formautofill.creditCards.enabled" = false;
          "extensions.pocket.enabled" = false;
          "media.ffmpeg.vaapi.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "privacy.webrtc.legacyGlobalIndicator" = false;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "widget.use-xdg-desktop-portal.file-picker" = 1;
          "widget.use-xdg-desktop-portal.mime-handler" = 1;
        };
        userChrome = ''
          #sidebar-header {
            visibility: collapse !important;
          }
          #TabsToolbar {
            display: none;
          }
        '';
      };
    };
  };
  xdg.desktopEntries.firefox = {
    actions = {
      secondary-profile = {
        exec = "${config.programs.firefox.package}/bin/firefox -P private";
        icon = "firefox";
        name = "Secondary Profile";
      };
    };
  };

  accounts.email.accounts.terinjokes = {
    address = "terinjokes@gmail.com";
    flavor = "gmail.com";
    primary = true;
    passwordCommand = "${pkgs.oauth2token}/bin/oauth2get gmail terinjokes";
    mbsync = {
      enable = true;
      create = "maildir";
      extraConfig.account = { AuthMechs = "XOAUTH2"; };
      groups = {
        gmail = {
          channels = {
            default = {
              farPattern = "INBOX";
              nearPattern = "local";
              extraConfig.Create = "Near";
            };
            sent = {
              farPattern = "[Gmail]/Sent Mail";
              nearPattern = "sent";
              extraConfig.Create = "Near";
            };
            trash = {
              farPattern = "[Gmail]/Trash";
              nearPattern = "trash";
              extraConfig.Create = "Near";
            };
          };
        };
      };
    };
  };
  programs.mbsync = {
    enable = true;
    package = (pkgs.runCommand "isync-wrapper" {
      buildInputs = [ pkgs.makeWrapper ];
    } ''
      makeWrapper ${pkgs.isync}/bin/mbsync $out/bin/mbsync \
        --prefix SASL_PATH : "${pkgs.cyrus_sasl.out}/lib/sasl2:${pkgs.cyrus-sasl-xoauth2}/lib/sasl2"
    '');
  };

  xdg.configFile = {
    "oauth2token/gmail/config.json".source =
      (pkgs.formats.json { }).generate "config" {
        web = {
          client_id =
            "406964657835-aq8lmia8j95dhl1a2bvharmfk3t1hgqj.apps.googleusercontent.com";
          client_secret = "kSmqreRr0qwBWJgbf5Y-PjSU";
          auth_uri = "https://accounts.google.com/o/oauth2/auth";
          token_uri = "https://www.googleapis.com/oauth2/v3/token";
        };
      };
    "oauth2token/gmail/scopes.json".source =
      (pkgs.formats.json { }).generate "scopes" [ "https://mail.google.com/" ];
  };

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
      "100.75.69.73" = {
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
      "multivac" = {
        hostname = "100.103.120.71";
        extraOptions = {
          IdentityAgent = "/run/user/1000/yubikey-agent/yubikey-agent.sock";
        };
      };
      "multivac-boot" = {
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

  services.syncthing = {
    enable = true;
    tray = {
      enable = true;
      command = "syncthingtray --wait";
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
        outputs_connected = [ "DP-1" ];
        outputs_present = [ "eDP-1" ];
        configure_single = "DP-1";
        primary = "DP-1";
        atomic = true;
        execute_after = [
          "${pkgs.herbstluftwm}/bin/herbstclient set_monitors 3840x2160+0+0"
          "${pkgs.feh}/bin/feh --bg-fill --no-fehbg ${wallpapers.framework-martiandeath-4k}"
        ];
      }
      {
        name = "Fallback";
        configure_single = "eDP-1";
        primary = "eDP-1";
        atomic = true;
        execute_after = [
          "${pkgs.herbstluftwm}/bin/herbstclient set_monitors 2256x1504+0+0"
          "${pkgs.feh}/bin/feh --bg-fill --no-fehbg ${wallpapers.framework-martiandeath}"
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
        modules-right =
          "pulseaudio info-kdeconnect-battery battery-BAT1 wireless-network date";

        tray-position = "right";
      };
      "bar/bottom" = {
        "inherit" = "bar/base";
        bottom = true;

        modules-right = "baywheels";
      };
      "module/baywheels" = {
        type = "custom/script";
        exec = "${
            pkgs.writeOilApplication {
              name = "info-baywheels";
              runtimeInputs = with pkgs; [ curl jq ];
              text = ''
                fopen 2> /dev/null {
                  try {
                    ... curl -Ss --fail https://gbfs.baywheels.com/gbfs/en/station_status.json -H"User-Agent: https://terinstock.com"
                      | jq -r '.data.stations | map(select(.station_id=="930fe54f-5572-4900-8910-6041386560bf"))[0]'
                      | json read :station
                      ;
                  }
                }

                if (_status !== 0) {
                   echo ""
                   exit 0
                }

                ... write --sep ' ' "%{T4}%{T-} $[station->num_bikes_available - station->num_ebikes_available]"
                    "%{T4}%{T-} $[station->num_ebikes_available]"
                  ;
              '';
            }
          }/bin/info-baywheels";
        interval = 60;
        label-overline = "#88C0D0";
        label-margin = 1;
        label-padding = 2;
      };
      "module/info-kdeconnect-battery" = {
        type = "custom/script";
        exec = "${
            pkgs.writeOilApplication {
              name = "info-kdeconnect-battery";
              runtimeInputs = with pkgs; [ systemd ];
              text = ''
                var device_id = "ab6a66e7ec2c7c18"
                fopen 2> /dev/null {
                  try {
                    ... busctl --user --json=short get-property org.kde.kdeconnect /modules/kdeconnect/devices/$device_id org.kde.kdeconnect.device isReachable
                      | json read :info
                      ;
                  }
                }

                if (_status !== 0) {
                  echo ""
                  exit 0
                } elif (not info->data) {
                  echo ""
                  exit 0
                }

                fopen 2> /dev/null {
                  try {
                    ... busctl --user --json=short get-property org.kde.kdeconnect /modules/kdeconnect/devices/$device_id/battery org.kde.kdeconnect.device.battery charge
                      | json read :info
                      ;
                  }
                }

                if (_status !== 0) {
                  echo ""
                  exit 0
                }

                write --sep "" "%{T4}%{T-}" $[info->data] "%"
              '';
            }
          }/bin/info-kdeconnect-battery";
        interval = 60;
        label-margin = 1;
        label-padding = 2;
        label-underline = "#88C0D0";
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
    script = ''
      polybar top &
      polybar bottom &
    '';
  };

  services.kdeconnect = {
    enable = true;
    indicator = true;
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
