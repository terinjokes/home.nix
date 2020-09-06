{ config, lib, pkgs, ... }:
with lib;

{
  imports = [ ./modules/programs/openrct2.nix ];

  nixpkgs.config.allowUnfree = true;

  manual.manpages.enable = true;

  home.packages = with pkgs; [
    nixfmt
    nixpkgs-fmt
    xclip

    noto-fonts
    jetbrains-mono

    kubectl
    kubectx

    cloudflared

    jq
    google-cloud-sdk
    ghq
    ripgrep
    skopeo

    git
    vcsh
    gitAndTools.stgit

    fd
    emacs-all-the-icons-fonts
    pandoc
    shellcheck

    # all the Go things
    go
    gopls
    golangci-lint
    gomodifytags
    gocode-gomod
    gotests
    gore

    krita
    sxiv
    okular
    multimc
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.alacritty = {
    enable = true;
    settings = {
      font.normal.family = "JetBrains Mono";
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

  programs.openrct2 = {
    enable = true;
    config = {
      general = {
        fullscreen_mode = 0;
        use_vsync = true;
        multi_threading = true;
        game_path = "/home/terin/Downloads/rct2/app";

        window_scale = 2;
        scale_quality = "SMOOTH_NEAREST_NEIGHBOUR";
        landscape_smoothing = true;
        drawing_engine = "OPENGL";

        measurement_format = "METRIC";
        temperature_format = "CELSIUS";
        date_format = "YY/MM/DD";

        render_weather_effects = true;
        render_weather_gloom = true;
        enable_light_fx = true;
        enable_light_fx_for_vehicles = true;
        disable_lightning_effect = true;

        auto_open_shops = true;
        default_inspection_interval = 0; # 10 minutes
      };
    };
    plugins = [
      (
        pkgs.fetchurl {
          url =
            "https://github.com/tubbo/openrct2-benchwarmer/releases/download/v0.1.1/benchwarmer-v0.1.1.js";
          sha256 = "0aljssczc087iisbdlbag66xj4fp5cwi0qv5hrq2yz67k57wic5k";
        }
      )
    ];
    scenarios = [
      (
        pkgs.fetchurl {
          url =
            "https://downloads.rctgo.com/scenarios/2020-05/20042/The%20Starry%20Night.sc6";
          name = "20042-the-starry-night.sc6";
          sha256 = "1z2qna03068w7hsg842wn7fiq1j9wfma82zfchdd53xf2r1rs02n";
        }
      )
    ];
    tracks = [
      (
        pkgs.fetchurl {
          url = "https://downloads.rctgo.com/tracks/2017-12/17697/Gladiator.td6";
          sha256 = "1awh224ixf4zjrh4j42la9nvm1jx8qa1wfz6l7vq03rncas0wrar";
        }
      )
    ];
  };

  programs.bat = {
    enable = true;
    config = { theme = "Nord"; };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableNixDirenvIntegration = true;
  };

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [ epkgs.emacs-libvterm ];
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
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
  };

  programs.zsh = {
    enable = true;
    initExtraBeforeCompInit = ''
      export ZSH=$HOME/.config/zsh

      # source every .zsh file in the $ZSH directory
      for config_file ($ZSH/*.zsh) source $config_file
    '';

  };

  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = [ "okularApplication_pdf.desktop" ];
      };
    };
  };

  services.emacs = { enable = true; };

  fonts.fontconfig.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.03";
}
