{ config, lib, pkgs, ... }:

let
  wallpapers = pkgs.callPackage ../wallpapers.nix { };
  unstable = import <nixpkgs-unstable> { config = config.nixpkgs.config; };
  nur = import <NUR> { inherit pkgs; };
  ff-containerise = nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon {
    pname = "containerise";
    version = "3.9.0";
    addonId = "containerise@kinte.sh";
    url =
      "https://addons.mozilla.org/firefox/downloads/file/3724805/containerise-3.9.0.xpi";
    sha256 = "bf511aa160512c5ece421d472977973d92e1609a248020e708561382aa10d1e5";
    meta = with lib; {
      homepage = "https://github.com/kintesh/containerise";
      description =
        "Automatically open websites in a dedicated container. Simply add rules to map domain or subdomain to your container.";
      license = licenses.mit;
      platforms = platforms.all;
    };
  };
  ff-fx_cast = nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon {
    pname = "fx_cast";
    version = "0.2.0";
    addonId = "fx_cast@matt.tf";
    url =
      "https://github.com/hensm/fx_cast/releases/download/v0.2.0/fx_cast-0.2.0-fx.xpi";
    sha256 = "a8344e30a7111b772f9d0ba43bd2368e8a67575c0646b98cd8d3c4bc782beae3";
    meta = with lib; {
      homepage = "https://hensm.github.io/fx_cast/";
      description =
        "A browser extension that enables Chromecast support for casting web apps";
      license = licenses.mit;
      platforms = platforms.all;
    };
  };
in {
  imports = [ ../types/work.nix ];

  home.packages = with pkgs; [
    google-chrome
    pavucontrol

    pamixer
    herbstluftwm

    _1password
    unstable._1password-gui

    minikube

    zoom-us
    signal-desktop
    xsane

    ghostscript
    libsForQt5.breeze-icons
    libsForQt5.kdegraphics-thumbnailers
    libsForQt5.kio-extras
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

  programs.ssh = {
    matchBlocks = {
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

  programs.firefox = {
    enable = true;
    package = unstable.firefox.override {
      cfg = {
        smartcardSupport = true;
        enableFXCastBridge = true;
      };
    };
    extensions = with nur.repos.rycee.firefox-addons; [
      ff-containerise
      ff-fx_cast
      multi-account-containers
      onepassword-password-manager
      temporary-containers
      tree-style-tab
      ublock-origin
      violentmonkey
    ];
    profiles = {
      terin = {
        id = 0;
        isDefault = true;
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

  services.keynav.enable = true;

  services.redshift = {
    enable = true;
    provider = "geoclue2";
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

        font-0 = "Iosevka Aile:size=8;3";
        font-1 = "Sarasa Mono CL:size=8;3";
        background = "#2E3440";
        foreground = "#D8DEE9";

        enable-ipc = true;
      };
      "bar/top" = {
        "inherit" = "bar/base";

        modules-left = "xworkspaces";
        modules-center = "xwindow";
        modules-right =
          "pulseaudio-MGXU pulseaudio-HDAudio battery-BAT0 battery-BAT1 date";

        tray-position = "right";
      };
      "module/battery-BAT0" = {
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
      "module/battery-BAT1" = {
        type = "internal/battery";
        battery = "BAT1";
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
      "module/pulseaudio-MGXU" = {
        type = "internal/pulseaudio";
        sink = "alsa_output.usb-Yamaha_Corporation_MG-XU-00.iec958-stereo";
        use-ui-max = false;
        format-volume-underline = "#B48EAD";
        label-muted-padding = 1;
        label-muted-foreground = "#BF616A";
        label-muted-underline = "#BF616A";
        label-volume-padding = 1;
      };
      "module/pulseaudio-HDAudio" = {
        type = "internal/pulseaudio";
        sink =
          "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink";
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
    script = "polybar top &";
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
    "text/html" = [ "google-chrome.desktop" ];
    "x-scheme-handler/http" = [ "google-chrome.desktop" ];
    "x-scheme-handler/https" = [ "google-chrome.desktop" ];
    "x-scheme-handler/about" = [ "google-chrome.desktop" ];
    "x-scheme-handler/unknown" = [ "google-chrome.desktop" ];
  };
}
