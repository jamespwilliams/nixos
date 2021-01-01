# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./vim.nix
    ] ++ lib.optional (builtins.pathExists ./configuration-local.nix) ./configuration-local.nix;

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

  networking.hostName = "napolin"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Enables wireless support via networkmanager

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlan0.useDHCP = true;

  networking.firewall.allowedTCPPorts = [ 8080 ];
  networking.firewall.allowedUDPPorts = [ 8080 ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Set your time zone.
  time.timeZone = "Europe/London";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  # List services that you want to enable:

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jpw = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

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
