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
      dwm = super.dwm.overrideAttrs (_: {
        src = /home/jpw/dwm; # builtins.fetchGit https://github.com/LukeSmithxyz/dwm.git;
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
