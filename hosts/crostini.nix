{ config, lib, pkgs, ... }:

{
  targets.genericLinux.enable = true;
  home.sessionVariables = {
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    TERMINFO_DIRS = "/home/terin/.nix-profile/share/terminfo:$TERMINFO_DIRS";
    LIBGL_DRIVERS_PATH =
      "${lib.makeSearchPathOutput "lib" "lib/dri" [ pkgs.mesa_drivers ]}";
    LD_LIBRARY_PATH =
      "${lib.makeLibraryPath [ pkgs.mesa_drivers ]}:$LD_LIBRARY_PATH";
  };

  home.packages = with pkgs; [ konsole ];

  programs.firefox.enable = true;

  programs.keychain = {
    enable = true;
    enableZshIntegration = true;
    keys = [ "id_ed25519" ];
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "garcon_host_browser.desktop" ];
    "x-scheme-handler/http" = [ "garcon_host_browser.desktop" ];
    "x-scheme-handler/https" = [ "garcon_host_browser.desktop" ];
    "x-scheme-handler/about" = [ "garcon_host_browser.desktop" ];
    "x-scheme-handler/unknown" = [ "garcon_host_browser.desktop" ];
  };
}
