{ config, pkgs, lib, ... }:

{
  services = {
    dwm-status = {
      enable = true;
      order = [
        "network"
        "audio"
        "cpu_load"
        "time"
      ];
    };

    openvpn.servers = {
      work-vpn = {
        config = "config /root/nixos/openvpn/work-vpn/work-vpn.conf";
        autoStart = false;
        updateResolvConf = true;
      };
    };

    pcscd.enable = true;

    udev.packages = [ pkgs.yubikey-personalization ];

    xserver = {
      enable = true;

      xkbOptions = "caps:escape";

      autoRepeatDelay = 200;
      autoRepeatInterval = 30;

      desktopManager = {
        xterm.enable = false;
      };

      displayManager = {
          defaultSession = "none+dwm";
          sessionCommands = ''
            xautolock -time 10 -locker "systemctl suspend" &
          '';
      };

      windowManager.dwm = {
        enable = true;
      };
    };
  };
}
