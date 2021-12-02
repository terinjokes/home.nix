{ config, lib, pkgs, ... }:

let
  cfg = config.services.xsecurelock;
  locker = pkgs.writeScript "lock.sh" ''
    #!${pkgs.bash}/bin/bash
    export XSECURELOCK_BLANK_DPMS_STATE=suspend
    export XSECURELOCK_BLANK_TIMEOUT=30
    export XSECURELOCK_BURNIN_MITIGATION=100
    export XSECURELOCK_DATETIME_FORMAT="%a %Y-%m-%d %H:%M:%S"
    export XSECURELOCK_FONT="Iosevka-10"
    export XSECURELOCK_PASSWORD_PROMPT=time_hex
    export XSECURELOCK_SHOW_DATETIME=1
    export XSECURELOCK_SHOW_HOSTNAME=1
    export XSECURELOCK_USERNAME=1
    export XSECURELOCK_WANT_FIRST_KEYPRESS=1

    exec "${pkgs.xsecurelock}/bin/xsecurelock"
  '';
in {
  options.services.xsecurelock = {
    enable = lib.mkEnableOption "xsecurelock locker";
  };

  config = lib.mkIf cfg.enable {
    services.screen-locker = {
      enable = true;
      lockCmd = "${locker}";
      xss-lock.extraOptions = [ "-l" ];
    };
  };
}
