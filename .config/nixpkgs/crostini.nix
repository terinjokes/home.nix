{ config, pkgs, lib, ... }:

{
  imports = [
    ./common.nix
  ];

  nixpkgs.overlays = [
    (_self: super: { })
  ];

  targets.genericLinux.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "terin";
  home.homeDirectory = "/home/terin";
  home.language.base = "en_US.utf-8";
  home.sessionVariables = {
    PATH = "${config.home.homeDirectory}/go/bin:$PATH";
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    TERMINFO_DIRS = "/home/terin/.nix-profile/share/terminfo:$TERMINFO_DIRS";
    LIBGL_DRIVERS_PATH = "${lib.makeSearchPathOutput "lib" "lib/dri" [ pkgs.mesa_drivers ]}";
    LD_LIBRARY_PATH = "${lib.makeLibraryPath [ pkgs.mesa_drivers ]}:$LD_LIBRARY_PATH";
  };


  home.packages = with pkgs; [
    openssh
    coreutils-full
  ];

  programs.keychain = {
    enable = true;
    enableZshIntegration = true;
    keys = [ "id_ed25519" ];
  };

  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        id = 0;
        settings = {
          "browser.rights.3.shown" = true;
          "browser.shell.checkDefaultBrowser" = false;
          "layout.css.devPixelsPerPx" = 1;

          "browser.aboutConfig.showWarning" = false;
          "extensions.pocket.enabled" = false;
          "browser.newtabpage.activity-stream.discoverystream.enabled" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.feeds.snippets" = false;
          "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
          "browser.newtabpage.pinned" = "[]";
          "browser.urlbar.placeholderName" = "DuckDuckGo";

          "trailhead.firstrun.didSeeAboutWelcome" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
        userChrome = ''
          /* Hide tab bar in FF Quantum */
          #TabsToolbar {
            visibility: collapse !important;
            margin-bottom: 21px !important;
          }

          #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
            visibility: collapse !important;
          }
        '';
      };
    };
  };

  xdg = {
    mimeApps = {
      defaultApplications = {
        "text/html" = [ "garcon_host_browser.desktop" ];
        "application/pdf" = [ "okularApplication_pdf.desktop" ];
        "x-scheme-handler/http" = [ "garcon_host_browser.desktop" ];
        "x-scheme-handler/https" = [ "garcon_host_browser.desktop" ];
        "x-scheme-handler/about" = [ "garcon_host_browser.desktop" ];
        "x-scheme-handler/unknown" = [ "garcon_host_browser.desktop" ];
      };
    };
  };
}
