{ config, lib, pkgs, ... }:
let
  unstable = import <unstable> { config = { allowUnfree = true; }; };
in
{
  nixpkgs.overlays = [
    (
      self: super: {
        spotifyd = unstable.spotifyd.override {
          withALSA = false;
          withMpris = true;
          withKeyring = true;
        };
        polybar = super.polybar.override {
          alsaSupport = false;
          mpdSupport = true;
          pulseSupport = true;
        };
        bat = unstable.bat;
        google-chrome-beta = super.google-chrome-beta.override {
          commandLineArgs = "--use-gl=desktop";
        };
        openrct2 = unstable.openrct2.overrideAttrs (
          old: {
            src = pkgs.fetchFromGitHub {
              owner = "OpenRCT2";
              repo = "OpenRCT2";
              rev = "66fb9f556e1ff6b7e52776083303d17b98721ebf";
              sha256 = "0qrqf5hxr29x71hzmgwz0sp13jc22zzb7s4cynfzdy078k4hgxap";
            };
          }
        );
        ghq = unstable.ghq;
        cloudflared = unstable.cloudflared;
        gopls = unstable.gopls;
        gomodifytags = unstable.gomodifytags;
        gore = unstable.gore;
      }
    )
  ];

  home.packages = with pkgs; [
    xsecurelock
    sxhkd

    slack
    discord
    pavucontrol

    zoom-us
    unstable.obs-studio

    virt-manager

    pinentry_gtk2
    yubikey-agent
  ];

  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        userChrome = ''
          @-moz-document url("chrome://browser/content/browser.xul") {
            #TabsToolbar {
              visibility: collapse !important;
              margin-bottom: 21px !important;
            }

            #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
              visibility: collapse !important;
            }
          }
        '';
      };
    };
  };

  programs.rofi = {
    enable = true;
    theme = "Arc-Dark";
    extraConfig = ''
      rofi.show-icons: true
      rofi.modi: drun,run
    '';
  };

  programs.chromium = {
    enable = true;
    package = pkgs.google-chrome-beta;
  };

  xsession.enable = true;
  xsession.initExtra = "${pkgs.sxhkd}/bin/sxhkd &";
  xsession.importedVariables = [ "PATH" ];
  xsession.windowManager.bspwm = {
    enable = true;
    monitors = {
      DP-0 = [ "I" "II" "III" "IV" "V" ];
      "%DP-2.8" = [ "VI" "VII" "VIII" "IX" "X" ];
    };
    settings = {
      normal_border_color = "#2E3440";
      active_border_color = "#E5E9F0";
      focused_border_color = "#4C566A";
      urgent_border_color = "#BF616A";
      presel_border_color = "#ECEFF4";
      presel_feedback_color = "#3B4252";

      border_width = 3;
      window_gap = 10;
      borderless_monocle = true;
      gapless_monocle = false;
      focus_follows_pointer = true;
    };
    extraConfig = ''
      systemctl --user restart polybar;
    '';
    # rules = {
    #   "Emacs" = {
    # state = "tiled";
    #   };
    # };
  };
  xsession.numlock.enable = true;
  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = [ "google-chrome-beta.desktop" ];
        "x-scheme-handler/http" = [ "google-chrome-beta.desktop" ];
        "x-scheme-handler/https" = [ "google-chrome-beta.desktop" ];
        "x-scheme-handler/about" = [ "google-chrome-beta.desktop" ];
        "x-scheme-handler/unknown" = [ "google-chrome-beta.desktop" ];
      };
    };
    configFile."sxhkd/sxhkdrc".text = concatStringsSep "\n" (
      mapAttrsToList
        (
          hotkey: command:
            optionalString (command != null) ''
              ${hotkey}
                ${command}
            ''
        )
        {
          "super + Return" = "${pkgs.alacritty}/bin/alacritty";
          "super + @space" = "${pkgs.rofi}/bin/rofi -show drun";
          "super + Escape" = "${pkgs.procps}/bin/pkill -USR1 -x sxhkd";

          # bspwm hotkeys
          # quit/restart bspwm
          "super + alt + {q,r}" = "${pkgs.bspwm}/bin/bspc {quit,wm -r}";
          # close and kill
          "super + {_,shift +}w" = "${pkgs.bspwm}/bin/bspc node -{c,k}";
          # alternate between titled and monocle layout
          "super + m" = "${pkgs.bspwm}/bin/bspc desktop -l next";
          # send marked node to newest preselected node"
          "super + y" =
            "${pkgs.bspwm}/bin/bspc node newest.marked.local -n newest.!automatic.local";
          # swap the current node and the biggest node"
          "super + g" = "${pkgs.bspwm}/bin/bspc node -s biggest";

          # state/flags
          # set the window state
          "super + {t,shift + t,s,f}" =
            "${pkgs.bspwm}/bin/bspc node -t {tiled,pseudo_tiled,floating,fullscreen}";
          "super + ctrl + {m,x,y,z}" =
            "${pkgs.bspwm}/bin/bspc node -g {marked,locked,sticky,private}";

          # focus/swap
          # focus the node in the given direction
          "super + {_,shift + }{h,j,k,l}" =
            "${pkgs.bspwm}/bin/bspc node -{f,s} {west,south,north,east}";
          # focus the node for the given path jump
          "super + {p,b,comma,period}" =
            "${pkgs.bspwm}/bin/bspc node -f @{parent,brother,first,second}";
          # focus the next/previous node in the current desktop
          "super + {_,shift +}c" =
            "${pkgs.bspwm}/bin/bspc node -f {next,prev}.local";
          # focus the next/previous desktop in the current monitor
          "super + bracket{left,right}" =
            "${pkgs.bspwm}/bin/bspc desktop -f {prev,next}.local";
          # focus the last node/desktop
          "super + {grave,Tab}" =
            "${pkgs.bspwm}/bin/bspc {node,desktop} -f last";
          # focus the older or newer node in the focus history
          "super + {o,i}" = ''
            ${pkgs.bspwm}/bin/bspc wm -h off; \
            ${pkgs.bspwm}/bin/bspc node {older,newer} -f; \
            ${pkgs.bspwm}/bin/bspc wm -h on
          '';
          # focus or send to the given desktop
          "super + {_,shift +}{1-9,0}" =
            "${pkgs.bspwm}/bin/bspc {desktop -f,node -d} '^{1-9,10}'";

          # preselect
          # preselect the direction
          "super + ctrl + {h,j,k,l}" =
            "${pkgs.bspwm}/bin/bspc node -p {west,south,north,east}";
          # preselect the ratio
          "super + ctrl + {1,9}" = "${pkgs.bspwm}/bin/bspc node -o 0.{1-9}";
          # cancel the preselect for the focused node
          "super + ctrl + space" = "${pkgs.bspwm}/bin/bspc node -p cancel";
          # cancel the preselection for the focused desktop
          "super + ctrl + shift + space" =
            "${pkgs.bspwm}/bin/bspc query -N -d ${pkgs.findutils}/bin/xargs -I id -n 1 ${pkgs.bspwm}/bin/bspc node id -p cancel";

          # move/resize
          # expand a window by moving one of its sides outward
          "super + alt + {h,j,k,l}" =
            "${pkgs.bspwm}/bin/bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";
          # contract a window by moving one its sides inward
          "super + alt + shift + {h,j,k,l}" =
            "${pkgs.bspwm}/bin/bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}";
          # move a floating window
          "super + {Left,Down,Up,Right}" =
            "${pkgs.bspwm}/bin/bspc node -v {-20 0,0 20,0 -20,20 0}";
        }
    );
    configFile."systemd/user/home-terin-GDrive.mount".text = ''
      [Unit]
      Description=Mount Google Drive with google-drive-ocamlfuse

      [Install]
      WantedBy=default.target

      [Mount]
      What=gdfuse#default
      Where=/home/terin/GDrive
      Type=fuse.google-drive-ocamlfuse
      Options=rw,noexec,nosuid,nodev
      TimeoutSec=60
      Environment=BROWSER=${pkgs.google-chrome-beta}/bin/google-chrome-beta
    '';
    configFile."systemd/user/yubikey-agent.service".text = ''
      [Unit]
      Description=Seamless ssh-agent for YubiKeys
      Documentation=https://filippo.io/yubikey-agent

      [Install]
      WantedBy=default.target

      [Service]
      ExecStart=${unstable.yubikey-agent}/bin/yubikey-agent -l %t/yubikey-agent/yubikey-agent.sock
      ExecReload=${pkgs.utillinux}/bin/kill -HUP $MAINPID
      ProtectSystem=strict
      ProtectKernelLogs=yes
      ProtectKernelModules=yes
      ProtectKernelTunables=yes
      ProtectControlGroups=yes
      ProtectClock=yes
      ProtectHostname=yes
      PrivateTmp=yes
      PrivateDevices=yes
      PrivateUsers=yes
      IPAddressDeny=any
      RestrictAddressFamilies=AF_UNIX
      RestrictNamespaces=yes
      RestrictRealtime=yes
      RestrictSUIDSGID=yes
      LockPersonality=yes
      CapabilityBoundingSet=
      SystemCallFilter=@system-service
      SystemCallFilter=~@privileged @resources
      SystemCallErrorNumber=EPERM
      SystemCallArchitectures=native
      NoNewPrivileges=yes
      KeyringMode=private
      UMask=0177
      RuntimeDirectory=yubikey-agent
    '';
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
        text = "JetBrains Mono 10";
        markup = "full";
        format = "<b>%s</b>\\n%b";
        word_wrap = "yes";
        stack_duplicates = true;
        show_indicators = "yes";
        icon_position = "left";
        max_icon_size = 64;
        dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p dunst";
        browser = "${pkgs.google-chrome-beta}/bin/google-chrome-beta";
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

  services.picom = {
    enable = true;
    backend = "glx";
  };

  services.polybar = {
    enable = true;
    config = {
      "bar/left" = {
        monitor = "DP-0";
        width = "100%";
        height = "22";
        wm-restack = "bspwm";

        modules-left = "bspwm";
        modules-center = "xwindow";
        modules-right = "pulseaudio-MGXU pulseaudio-HDAudio date";

        font-0 = "JetBrains Mono:size=10;3";

        tray-position = "right";
      };
      "module/bspwm" = {
        type = "internal/bspwm";
        format = "<label-state>";
        label-focused-occupied-padding = 1;
        label-focused-urgent-padding = 1;
        label-focused-empty-padding = 1;
        label-occupied-padding = 1;
        label-urgent-padding = 1;
        label-empty-padding = 1;
      };
      "module/date" = {
        type = "internal/date";
        internal = 5;
        date = "%y-%m-%d";
        time = "%H:%M";
        label = "%time% %date%";
        label-padding = 1;
      };
      "module/pulseaudio-MGXU" = {
        type = "internal/pulseaudio";
        sink = "alsa_output.usb-Yamaha_Corporation_MG-XU-00.iec958-stereo";
        use-ui-max = false;
        label-volume-padding = 1;
      };
      "module/pulseaudio-HDAudio" = {
        type = "internal/pulseaudio";
        sink = "alsa_output.pci-0000_0c_00.4.analog-stereo";
        use-ui-max = false;
        label-volume-padding = 1;
      };
      "module/xwindow" = {
        type = "internal/xwindow";
        format-padding = 1;
        label = "%title%";
        label-empty = "-- none --";
      };
    };
    script = "polybar left &";
  };

  services.redshift = {
    enable = true;
    latitude = "37.77";
    longitude = "-122.42";
  };

  services.screen-locker = {
    enable = true;
    xssLockExtraOptions =
      [ "-n" "${pkgs.xsecurelock}/libexec/xsecurelock/dimmer" "-l" ];
    lockCmd =
      "/usr/bin/env XSECURELOCK_COMPOSITE_OBSCURER=0 XSECURELOCK_PASSWORD_PROMPT=time_hex XSECURELOCK_SHOW_DATETIME=1 XSECURELOCK_SHOW_USERNAME=1 XSECURELOCK_SINGLE_AUTH_WINDOW=1 XSECURELOCK_SWITCH_USER_COMMAND=${pkgs.gnome3.gdm}/bin/gdmflexiserver ${pkgs.xsecurelock}/bin/xsecurelock";
  };

  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        username = "terinjokes";
        ## todo: switch to password_cmd
        password = pass.spotify;
        backend = "pulseaudio";
        device_name = "Greenwich";
        bitrate = "320";
        device_type = "computer";
      };
    };
  };
}
