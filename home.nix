{ config, pkgs, lib, ... }:

let
  unstable = import <nixpkgs-unstable> { config = config.nixpkgs.config; };
  dircolorForExtensions = color: extensions:
    builtins.listToAttrs (builtins.map (name: {
      name = name;
      value = color;
    }) extensions);
  splitExtensions = extensions:
    lib.strings.splitString " " (lib.concatStringsSep " " extensions);

in {
  imports =
    [ ./modules/xsecurelock ./modules/zsh ./modules/herbstluftwm ./hosts ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (self: super: {
      polybar = super.polybar.override {
        alsaSupport = false;
        mpdSupport = true;
        pulseSupport = true;
      };
      google-chrome = unstable.google-chrome.override {
        commandLineArgs = "--enable-features=WebUIDarkMode --force-dark-mode";
      };
      kubectx = super.callPackage ./packages/kubectx { };
      _1password-gui = unstable._1password-gui;
    })
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "terin";
  home.homeDirectory = "/home/terin";

  home.packages = with pkgs; [
    dconf

    moreutils
    nixfmt

    noto-fonts
    iosevka-bin
    (iosevka-bin.override { variant = "aile"; })
    sarasa-gothic
    emacs-all-the-icons-fonts

    ripgrep
    fd
    jq

    git
    gitAndTools.delta
    gitAndTools.ghq
    gitAndTools.stgit
    gitAndTools.git-revise
    unstable.gitAndTools.git-branchless

    unstable.openssh

    xclip

    file
    atool
    p7zip

    libsForQt5.qtstyleplugin-kvantum

    kubectl
    kubectx

    (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
    hunspell
    hunspellDicts.en-us-large
  ];

  programs.dircolors = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      NORMAL = "00";
      RESET = "0";
      FILE = "00";
      DIR = "01;34";
      LINK = "36";
      MULTIHARDLINK = "04;36";
      FIFO = "04;01;36";
      SOCK = "04;33";
      DOOR = "04;01;36";
      BLK = "01;33";
      CHR = "33";
      ORPHAN = "31";
      MISSING = "01;37;41";
      EXEC = "01;36";
      SETUID = "01;04;37";
      SETGID = "01;04;37";
      CAPABILITY = "01;37";
      STICKY_OTHER_WRITABLE = "01;37;44";
      OTHER_WRITABLE = "01;04;34";
      STICKY = "04;37;44";
    }
    # Archivies
      // dircolorForExtensions "01;32" (splitExtensions [
        ".7z .ace .alz .arc .arj .bz .bz2 .cab .cpio .deb .dz"
        ".ear .gz .jar .lha .lrz .lz .lz4 .lzh .lzma .lzo .rar"
        ".rpm .rz .sar .t7z .tar .taz .tbz .tbz2 .tgz .tlz .txz"
        ".tz .tzo .tzst .war .xz .z .Z .zip .zoo .zst"
      ])
      # Audio
      // dircolorForExtensions "32" (splitExtensions [
        ".aac .au .flac .m4a .mid .midi .mka .mp3 .mpa .mpeg .mpg .ogg .opus .ra .wav"
      ])
      # Documents
      // dircolorForExtensions "32" (splitExtensions [
        ".doc .docx .dot .odg .odp .ods .odt .otg .otp .ots .ott .pdf .ppt .pptx .xls .xlsx"
      ])
      # Encryption
      // dircolorForExtensions "01;35"
      (splitExtensions [ ".3des .aes .age .gpg .pgp" ])
      # Executables
      // dircolorForExtensions "01;36"
      (splitExtensions [ ".app .bat .btm .cmd .com .exe .reg" ])
      # Ignores
      // dircolorForExtensions "02;37" (splitExtensions
        [ "*~ .bak .BAK .log .log .old .OLD .orig .ORIG .swo .swp" ])
      # Images
      // dircolorForExtensions "32" (splitExtensions [
        ".bmp .cgm .dl .dvi .emf .eps .gif .jpeg .jpg .JPG .mng"
        ".pbm .pcx .pgm .png .PNG .ppm .pps .ppsx .ps .svg .svgz"
        ".tga .tif .tiff .xbm .xcf .xpm .xwd .xwd .yuv"
      ])
      # Video
      // dircolorForExtensions "32" (splitExtensions [
        ".anx .asf .avi .axv .flc .fli .flv .gl .m2v .m4v .mkv"
        ".mov .MOV .mp4 .mpeg .mpg .nuv .ogm .ogv .ogx .qt .rm"
        ".rmvb .swf .vob .webm .wmv"
      ]);
  };

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

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.ssh = {
    enable = true;
    controlMaster = "auto";
    controlPersist = "10m";
    hashKnownHosts = true;
    extraOptionOverrides = { IgnoreUnknown = "OverrideTerm"; };
    extraConfig = ''
      VisualHostKey yes
    '';
    serverAliveInterval = 60;
  };

  programs.git = {
    enable = true;
    userName = "Terin Stock";
    userEmail = "terinjokes@gmail.com";
    delta = {
      enable = true;
      options = { syntax-theme = "Nord"; };
    };
    extraConfig = {
      color = {
        diff = "auto";
        status = "auto";
        branch = "auto";
        ui = "auto";
      };
      diff.algorithm = "histogram";
      ghq.root = "/home/terin/Development";
    };
  };

  programs.gpg = { enable = true; };
  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "qt";
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

  programs.herbstluftwm = {
    enable = true;
    keybindings = {
      "Mod4-Mod1-q" = "quit";
      "Mod4-Mod1-r" = "reload";
      "Mod4-w" = "close";
      "Mod4-space" = "spawn ${pkgs.rofi}/bin/rofi -show drun";
      "Mod4-Return" = "spawn ${pkgs.alacritty}/bin/alacritty";

      # brightness controls
      "XF86MonBrightnessUp" = "spawn ${pkgs.brillo}/bin/brillo -A 5";
      "XF86MonBrightnessDown" = "spawn ${pkgs.brillo}/bin/brillo -U 5";
      "Shift-XF86MonBrightnessUp" =
        "spawn ${pkgs.brillo}/bin/brillo -S 100 -u 1000000";
      "Shift-XF86MonBrightnessDown" =
        "spawn ${pkgs.brillo}/bin/brillo -S 0 -u 1000000";

      # audio mixer controls
      "XF86AudioMute" = "spawn ${pkgs.pamixer}/bin/pamixer -t";
      "XF86AudioRaiseVolume" = "spawn ${pkgs.pamixer}/bin/pamixer -i 5";
      "XF86AudioLowerVolume" = "spawn ${pkgs.pamixer}/bin/pamixer -d 5";

      # focusing clients
      "Mod4-Left" = "focus left";
      "Mod4-Down" = "focus down";
      "Mod4-Up" = "focus up";
      "Mod4-Right" = "focus right";
      "Mod4-h" = "focus left";
      "Mod4-j" = "focus down";
      "Mod4-k" = "focus up";
      "Mod4-l" = "focus right";

      # moving clients in tiling and floating mode
      "Mod4-Shift-Left" = "shift left";
      "Mod4-Shift-Down" = "shift down";
      "Mod4-Shift-Up" = "shift up";
      "Mod4-Shift-Right" = "shift right";
      "Mod4-Shift-h" = "shift left";
      "Mod4-Shift-j" = "shift down";
      "Mod4-Shift-k" = "shift up";
      "Mod4-Shift-l" = "shift right";

      # splitting frames
      "Mod4-u" = "split bottom 0.5";
      "Mod4-o" = "split right 0.5";
      "Mod4-Control-space" = "split explode";

      # resizing frames
      "Mod4-Control-h" = "resize left +0.02";
      "Mod4-Control-j" = "resize down +0.02";
      "Mod4-Control-k" = "resize up +0.02";
      "Mod4-Control-l" = "resize right +0.02";
      "Mod4-Control-Left" = "resize left +0.02";
      "Mod4-Control-Down" = "resize down +0.02";
      "Mod4-Control-Up" = "resize up +0.02";
      "Mod4-Control-Right" = "resize right +0.02";

      # tag cycling
      "Mod4-period" = "use_index +1 --skip-visible";
      "Mod4-comma" = "use_index -1 --skip-visible";

      # layouting
      "Mod4-r" = "remove";
      "Mod4-s" = "floating toggle";
      "Mod4-f" = "fullscreen toggle";
      "Mod4-Shift-f" = "set_attr clients.focus.floating toggle";
      "Mod4-p" = "pseudotile toggle";
      "Mod4-Shift-space" = ''
        or , and . compare tags.focus.curframe_wcount = 2 \
                 . cycle_layout +1 vertical horizontal max vertical grid \
           , cycle_layout +1
      '';

      # focus
      "Mod4-BackSpace" = "cycle_monitor";
      "Mod4-Tab" = "cycle_all +1";
      "Mod4-Shift-Tab" = "cycle_all -1";
      "Mod4-c" = "cycle";
      "Mod4-i" = "jumpto urgent";
    } // (builtins.listToAttrs (lib.flatten (map (tag: [
      {
        name = "Mod4-${toString (tag + 1)}";
        value = "use_index ${toString tag}";
      }
      {
        name = "Mod4-Shift-${toString (tag + 1)}";
        value = "move_index ${toString tag}";
      }
    ]) (lib.lists.range 0 8))));
    mousebindings = {
      "Mod4-Button1" = "move";
      "Mod4-Button2" = "zoom";
      "Mod4-Button3" = "resize";
    };
    settings = {
      default_frame_layout = "horizontal";
      frame_bg_normal_color = "'#565656'";
      frame_bg_active_color = "'#345F0C'";
      frame_bg_transparent = true;
      frame_transparent_width = 5;
      frame_border_width = 1;
      frame_gap = 10;
      always_show_frame = true;
      window_gap = 5;
      frame_padding = 0;
      smart_window_surroundings = true;
      smart_frame_surroundings = true;
      mouse_recenter_gap = 0;
      focus_follows_mouse = true;
      tree_style = "'╾│ ├└╼─┐'";
    };
    attributes = {
      theme = {
        normal.color = "'#454545'";
        urgent.color = "orange";
        background_color = "'#141414'";
        active = {
          color = "'#9fBC00'";
          inner_color = "'#3E4A00'";
          outer_color = "'#3E4A00'";
        };

        inner_color = "black";
        inner_width = 1;
        border_width = 3;

        floating = {
          border_width = 4;
          outer_width = 1;
          outer_color = "black";
        };
      };
    };
    rules = [
      "focus=on"
      "windowtype~'_NET_WM_WINDOW_TYPE_(DIALOG|UTILITY|SPLASH)' floating=on"
      "windowtype='_NET_WM_WINDOW_TYPE_DIALOG' focus=on"
      "windowtype~'_NET_WM_WINDOW_TYPE_(NOTIFICATION|DOCK|DESKTOP)' manage=off"
    ];
    defaultTag = "1";
    tags = map (tag: toString tag) (lib.lists.range 1 9);
  };

  services.emacs = {
    enable = true;
    client.enable = true;
    socketActivation.enable = true;
  };

  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps.enable = true;
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
