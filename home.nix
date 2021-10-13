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
  imports = [ ./modules/xsecurelock ./modules/zsh ./hosts ];

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

    # don't override openssh, as that will cause a rebuild
    # of several other packages.
    (pkgs.callPackage ./packages/openssh-term { })

    xclip

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
    configFile."herbstluftwm/autostart".source = ./autostart;
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
