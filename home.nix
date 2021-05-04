{ config, pkgs, lib, ... }:

{
  imports = [ ./modules/xsecurelock ./modules/zsh ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (self: super: {
      polybar = super.polybar.override {
        alsaSupport = false;
        mpdSupport = true;
        pulseSupport = true;
      };
      google-chrome = super.google-chrome.override {
        commandLineArgs = "--enable-features=WebUIDarkMode --force-dark-mode";
      };
      kubectx = super.callPackage ./packages/kubectx { };
      aaru =
        super.callPackage ./packages/aaru { dotnetSDK = super.dotnet-sdk_5; };
    })
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "terin";
  home.homeDirectory = "/home/terin";

  home.packages = with pkgs; [
    nixfmt
    google-chrome

    noto-fonts
    iosevka
    (iosevka.override { set = "aile"; })
    sarasa-gothic
    emacs-all-the-icons-fonts

    ripgrep
    fd
    jq

    gitAndTools.delta
    gitAndTools.ghq
    gitAndTools.stgit

    pavucontrol
    herbstluftwm
    xclip

    pinentry_qt5
    openconnect_openssl

    p7zip
    ark

    libsForQt5.qtstyleplugin-kvantum
    (pkgs.runCommand "qt512-kvantum" { } ''
      mkdir $out
      ln -s ${pkgs.libsForQt512.qtstyleplugin-kvantum}/* $out
      rm $out/bin
    '')
    (pkgs.runCommand "qt514-kvantum" { } ''
      mkdir $out
      ln -s ${pkgs.libsForQt514.qtstyleplugin-kvantum}/* $out
      rm $out/bin
    '')

    kubectl
    kubectx

    virt-manager

    zoom-us

    (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
    hunspell
    hunspellDicts.en-us-large

    aaru
  ];

  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "alacritty-direct";
      font.normal.family = "Iosevka";
      font.size = 10;
      colors = {
        primary = {
          background = "0x2E3440";
          foreground = "0xD8DEE9";
        };
        cursor = {
          text = "0x2E3440";
          cursor = "0xD8DEE9";
        };
        normal = {
          black = "0x3B4252";
          red = "0xBF616A";
          green = "0xA3BE8C";
          yellow = "0xEBCB8B";
          blue = "0x81A1C1";
          magenta = "0xB48EAD";
          cyan = "0x88C0D0";
          white = "0xE5E9F0";
        };
        bright = {
          black = "0x4C566A";
          red = "0xBF616A";
          green = "0xA3BE8C";
          yellow = "0xEBCB8B";
          blue = "0x81A1C1";
          magenta = "0xB48EAD";
          cyan = "0x8FBCBB";
          white = "0xECEFF4";
        };
      };
    };
  };

  programs.bat = {
    enable = true;
    config = { theme = "Nord"; };
  };

  programs.rofi = {
    enable = true;
    theme = "Arc-Dark";
    extraConfig = ''
      rofi.show-icons: true
      rofi.modi: drun,run
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
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
        text = "Iosevka Aile 10";
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
      };
      "bar/eDP1" = {
        "inherit" = "bar/base";
        monitor = "eDP1";

        modules-left = "xworkspaces";
        modules-center = "xwindow";
        modules-right =
          "tpacpi-kbd_backlight pulseaudio-MGXU pulseaudio-HDAudio battery-BAT0 battery-BAT1 date";

        tray-position = "right";
      };
      "bar/DP1" = {
        "inherit" = "bar/base";
        monitor = "DP1";

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
        sink = "alsa_output.pci-0000_00_1f.3.analog-stereo";
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
      "module/tpacpi-kbd_backlight" = {
        type = "custom/script";
        tail = true;
        exec = (pkgs.writeScript "tpacpi-kbd_backlight" ''
          #!${pkgs.stdenv.shell}
          path="/sys/devices/platform/thinkpad_acpi/leds/tpacpi::kbd_backlight/brightness"

          status() {
            case $(<$path) in
             "0")
               echo "%{F#4C566A}%{u#4C566A}%{+u}☼%{u-}%{F-}"
               ;;
             "1")
               echo "%{F#5E81AC}%{u#5E81AC}%{+u}☀%{u-}%{F-}"
               ;;
             "2")
               echo "%{F#8FBCBB}%{u#8FBCBB}%{+u}☀%{u-}%{F-}"
               ;;
            esac
          }

          next() {
            case $(<$path) in
             "0")
               echo "1" > $path
               ;;
             "1")
               echo "2" > $path
               ;;
             "2")
               echo "0" > $path
               ;;
            esac
            status
          }

          trap "status" USR1
          trap "next" USR2

          while true; do
            status
            ${pkgs.coreutils}/bin/sleep 10 &
            wait $!
          done
        '').outPath;
        click-left = "${pkgs.utillinux}/bin/kill -USR2 %pid%";
      };
    };
    script = "polybar eDP1 & polybar DP1 &";
  };

  services.picom = {
    enable = true;
    vSync = true;
  };

  services.redshift = {
    enable = true;
    provider = "geoclue2";
  };

  services.xsecurelock.enable = true;

  services.grobi = {
    enable = true;
    executeAfter =
      [ "${pkgs.systemd}/bin/systemctl --user restart polybar.service" ];
    rules = [
      {
        name = "Desk";
        outputs_connected = [ "DP1" ];
        outputs_present = [ "eDP1" ];
        configure_single = "DP1";
        primary = "DP1";
        atomic = true;
        execute_after = [
          "${pkgs.herbstluftwm}/bin/herbstclient set_monitors 3840x2160+0+0"
        ];
      }
      {
        name = "Fallback";
        configure_single = "eDP1";
        primary = "eDP1";
        atomic = true;
        execute_after = [
          "${pkgs.herbstluftwm}/bin/herbstclient set_monitors 2560x1440+0+0"
        ];
      }
    ];
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableNixDirenvIntegration = true;
  };

  programs.ssh = {
    enable = true;
    controlMaster = "auto";
    controlPersist = "10m";
    extraConfig = ''
      VisualHostKey yes
    '';
    serverAliveInterval = 60;
    matchBlocks = {
      "git-bypass-cfaccess.cfdata.org" = {
        port = 7999;
        extraOptions = {
          IdentityAgent = "/run/user/1000/yubikey-agent/yubikey-agent.sock";
        };
      };
      "??m* ?m* ??www* ?www* ??db* ???m* ??com* ???com* ??ndb* ??s* ???s* ??ssds* ??netops* !??dm* !???dm* !?dm* !jump" =
        {
          proxyJump = "$(echo %h|grep -o -E '[0-9]+'|head -1).primary.cfops.it";
          identitiesOnly = true;
          identityFile = "~/.ssh/id_ed25519";
          extraOptions = { StrictHostKeyChecking = "accept-new"; };
        };
    };
  };

  programs.git = {
    enable = true;
    userName = "Terin Stock";
    userEmail = "terinjokes@gmail.com";
    delta = {
      enable = true;
      options = { syntax-theme = "Nord"; };
    };
    includes = [
      {
        path = pkgs.writeText "bitbucket.inc" ''
          [url "ssh://git@git-bypass-cfaccess.cfdata.org:7999"]
            insteadOf = ssh://git@stash.cfops.it:7999
            insteadOf = https://bitbucket.cfdata.org/scm
            insteadOf = https://bitbucket.cfdata.org
        '';
      }
      {
        condition = "gitdir:~/cf-repos/";
        contents = { user.email = "terin@cloudflare.com"; };
      }
    ];
    extraConfig = {
      color = {
        diff = "auto";
        status = "auto";
        branch = "auto";
        ui = "auto";
      };
      diff.algorithm = "histogram";
      ghq.root = "/home/terin/Development";
      "ghq \"https://bitbucket.cfdata.org/\"" = {
        vcs = "git";
        root = "/home/terin/cf-repos";
      };
    };
  };

  xresources.properties = {
    "*.foreground" = "#D8DEE9";
    "*.background" = "#2E3440";
    "*.cursorColor" = "#D8DEE9";
    "*fading" = 35;
    "*fadeColor" = "#4C566A";
    "*.color0" = "#3B4252";
    "*.color1" = "#BF616A";
    "*.color2" = "#A3BE8C";
    "*.color3" = "#EBCB8B";
    "*.color4" = "#81A1C1";
    "*.color5" = "#B48EAD";
    "*.color6" = "#88C0D0";
    "*.color7" = "#E5E9F0";
    "*.color8" = "#4C566A";
    "*.color9" = "#BF616A";
    "*.color10" = "#A3BE8C";
    "*.color11" = "#EBCB8B";
    "*.color12" = "#81A1C1";
    "*.color13" = "#B48EAD";
    "*.color14" = "#8FBCBB";
    "*.color15" = "#ECEFF4";
    "Xft.dpi" = 96;
    "xterm*faceName" = "Iosevka";
    "xterm*faceSize" = 8;
    "xterm*renderFont" = true;
  };

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [ epkgs.vterm ];
  };

  services.emacs = {
    enable = true;
    client.enable = true;
    socketActivation.enable = true;
  };

  systemd.user.services.yubikey-agent = {
    Unit = {
      Description = "Seamless ssh-agent for YubiKeys";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };

    Service = {
      ExecStart =
        "${pkgs.yubikey-agent}/bin/yubikey-agent -l %t/yubikey-agent/yubikey-agent.sock";
      ExecReload = "${pkgs.utillinux}/bin/kill -HUP $MAINPID";
      ProtectSystem = "strict";
      ProtectKernelLogs = "yes";
      ProtectKernelModules = "yes";
      ProtectKernelTunables = "yes";
      ProtectControlGroups = "yes";
      ProtectClock = "yes";
      ProtectHostname = "yes";
      PrivateTmp = "yes";
      PrivateDevices = "yes";
      PrivateUsers = "yes";
      IPAddressDeny = "any";
      RestrictAddressFamilies = "AF_UNIX";
      RestrictNamespaces = "yes";
      RestrictRealtime = "yes";
      RestrictSUIDSGID = "yes";
      LockPersonality = "yes";
      CapabilityBoundingSet = "";
      SystemCallFilter = [ "@system-service" "~@privileged @resources" ];
      SystemCallErrorNumber = "EPERM";
      SystemCallArchitectures = "native";
      NoNewPrivileges = "yes";
      KeyringMode = "private";
      UMask = 177;
      RuntimeDirectory = "yubikey-agent";
    };
  };

  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = [ "google-chrome.desktop" ];
        "x-scheme-handler/http" = [ "google-chrome.desktop" ];
        "x-scheme-handler/https" = [ "google-chrome.desktop" ];
        "x-scheme-handler/about" = [ "google-chrome.desktop" ];
        "x-scheme-handler/unknown" = [ "google-chrome.desktop" ];
      };
    };
    configFile."Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=KvArcDark
    '';
    configFile."fontconfig/conf.d/99-local.conf".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>

        <!-- Prefer fonts for generics -->
        <alias binding="strong">
          <family>serif</family>
          <prefer><family>Tinos</family></prefer>
        </alias>
        <alias binding="strong">
          <family>sans-serif</family>
          <prefer><family>Arimo</family></prefer>
        </alias>
        <alias binding="strong">
          <family>sans</family>
          <prefer><family>Arimo</family></prefer>
        </alias>
        <alias binding="strong">
          <family>monospace</family>
          <prefer><family>Cousine</family></prefer>
        </alias>

        <!-- Map specific families to CrOS ones -->
        <match>
          <test name="family"><string>Arial</string></test>
          <edit name="family" mode="assign" binding="strong">
            <string>Arimo</string>
          </edit>
        </match>
        <match>
          <test name="family"><string>Helvetica</string></test>
          <edit name="family" mode="assign" binding="strong">
            <string>Arimo</string>
          </edit>
        </match>
        <match> <!-- NOT metric-compatible! -->
          <test name="family"><string>Verdana</string></test>
          <edit name="family" mode="assign" binding="strong">
            <string>Arimo</string>
          </edit>
        </match>
        <match> <!-- NOT metric-compatible! -->
          <test name="family"><string>Tahoma</string></test>
          <edit name="family" mode="assign" binding="strong">
            <string>Arimo</string>
          </edit>
        </match>
        <match>
          <test name="family"><string>Times</string></test>
          <edit name="family" mode="assign" binding="strong">
            <string>Tinos</string>
          </edit>
        </match>
        <match>
          <test name="family"><string>Times New Roman</string></test>
          <edit name="family" mode="assign" binding="strong">
            <string>Tinos</string>
          </edit>
        </match>
        <match> <!-- NOT metric-compatible! -->
          <test name="family"><string>Consolas</string></test>
          <edit name="family" mode="assign" binding="strong">
            <string>Cousine</string>
          </edit>
        </match>
        <match>
          <test name="family"><string>Courier</string></test>
          <edit name="family" mode="assign" binding="strong">
            <string>Cousine</string>
          </edit>
        </match>
        <match>
          <test name="family"><string>Courier New</string></test>
          <edit name="family" mode="assign" binding="strong">
            <string>Cousine</string>
          </edit>
        </match>
        <match>
          <test name="family"><string>Calibri</string></test>
          <edit name="family" mode="assign" binding="strong">
            <string>Carlito</string>
          </edit>
        </match>
        <match>
          <test name="family"><string>Cambria</string></test>
          <edit name="family" mode="assign" binding="strong">
            <string>Caladea</string>
          </edit>
        </match>
      </fontconfig>
    '';
  };

  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.arc-icon-theme;
      name = "Arc";
    };
    theme = {
      package = pkgs.arc-theme;
      name = "Arc-Dark";
    };
  };

  home.sessionVariables = {
    QT_STYLE_OVERRIDE = "kvantum-dark";
    EDITOR = "emacsclient -t";
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";
}
