{ config, pkgs, lib, ... }:

{
  systemd.services.slocker = {
    description = "Slock on systemctl suspend";
    wantedBy = [ "suspend.target" ];
    environment.DISPLAY = ":0";
    script = config.security.wrapperDir + "/slock";
    serviceConfig.Type = "oneshot";
    serviceConfig.User = "jpw";
  };

  systemd.user.services.dunst = {
    enable = true;
    description = "Shows notifications.";
    wantedBy = [ "default.target" ];
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = 2;
    serviceConfig.ExecStart = "${pkgs.dunst}/bin/dunst";
  };
}
