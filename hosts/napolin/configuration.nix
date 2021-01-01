{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../packages/vim.nix
    ];

  nixpkgs.config.allowUnfree = true;

  # Supposedly better for the SSD.
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/52560806-3f7f-456d-902a-e68805f0f5e9";
      preLVM = true;
      allowDiscards = true;
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # wpa_supplicant fails to start because the interface name assigned when net.ifnames=1 becomes
  # too long when p2p-dev- is prepended:
  boot.kernelParams = [ "net.ifnames=0" ];

  networking.hostName = "napolin";
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  networking.useDHCP = false;
  networking.interfaces.wlan0.useDHCP = true;

  networking.firewall.allowedTCPPorts = [ 8080 ];
  networking.firewall.allowedUDPPorts = [ 8080 ];

  time.timeZone = "Europe/London";

  environment.systemPackages = with pkgs; [
    alacritty
    bc
    chromium
    dmenu
    dunst
    feh
    fzf
    gcc
    git
    gnumake
    libnotify
    pamixer
    stow
    thunderbird
    tmux
    wget
    xautolock
    xorg.libX11
  ];

  hardware.bluetooth.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  users.users.jpw = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
  };

  system.stateVersion = "20.03";

  environment.pathsToLink = ["/libexec"]; # links /libexec from derivations to /run/current-system/sw 

  services.xserver = {
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

  services.dwm-status = {
    enable = true;
    order = [
      "network"
      "audio"
      "cpu_load"
      "time"
    ];
  };

  nixpkgs.overlays = [
    (self: super: {
      dwm = super.dwm.overrideAttrs (_: {
        src = /home/jpw/dwm; # builtins.fetchGit https://github.com/LukeSmithxyz/dwm.git;
      });
    })
  ];

  services.openvpn.servers = {
    work-vpn = {
      config = "config /root/nixos/openvpn/work-vpn/work-vpn.conf";
      autoStart = false;
      updateResolvConf = true;
    };
  };

  # YubiKey/gpg setup:
  services.udev.packages = [ pkgs.yubikey-personalization ];

  services.pcscd.enable = true;
  environment.shellInit = ''
    export GPG_TTY="$(tty)"
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  '';

  programs = {
    ssh.startAgent = false;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # /end YubiKey/gpg setup

  powerManagement.powerDownCommands = "
    systemctl stop openvpn-work-vpn
  ";

  programs.slock.enable = true;
  security.wrappers.slock = { source="${pkgs.slock}/bin/slock"; };

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

  fonts.fonts = with pkgs; [
    fira-code
  ];
}
