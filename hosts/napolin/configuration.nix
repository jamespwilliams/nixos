{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware.nix
      ./networking.nix
      ./packages.nix
      ./services.nix
      ./systemd.nix
      ./yubikey.nix

      ../../packages/vim.nix
    ];

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/London";

  users.users.jpw = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
  };

  system.stateVersion = "20.03";

  environment.pathsToLink = ["/libexec"]; # links /libexec from derivations to /run/current-system/sw 

  nixpkgs.overlays = [
    (self: super: {
      dwm = super.dwm.overrideAttrs (oa: {
        src = pkgs.fetchFromGitHub {
          owner = "jamespwilliams";
          repo = "dwm";
          rev = "63f241c890f2d703fe5a5ba55f9be90533e30930";
          sha256 = "0n2i6csyl4pcxvm5kdbbvb24yp50qj76xbwgm650ag4jn659dbrn";
        };
      });
    })
  ];

  environment.shellInit = ''
    export GPG_TTY="$(tty)"
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  '';

  powerManagement.powerDownCommands = "
    systemctl stop openvpn-work-vpn
  ";

  programs.slock.enable = true;
  security.wrappers.slock = { source="${pkgs.slock}/bin/slock"; };

  fonts.fonts = with pkgs; [
    fira-code
  ];
}
