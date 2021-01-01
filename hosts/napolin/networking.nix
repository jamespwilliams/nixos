{ config, pkgs, lib, ... }:

{
  networking = {
    hostName = "napolin";

    wireless.enable = true;

    useDHCP = false;
    interfaces.wlan0.useDHCP = true;

    firewall.allowedTCPPorts = [ 8080 ];
    firewall.allowedUDPPorts = [ 8080 ];
  };
}
