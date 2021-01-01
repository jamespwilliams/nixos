{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

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

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/875af9d1-6bf8-4844-abc0-f807f579f041";
      fsType = "ext4";
      # Supposedly better for the SSD.
      options = [ "noatime" "nodiratime" "discard" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/5C0D-C9B7";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/84dcf6e8-dff2-44aa-8371-b86336abbfa8"; }
    ];

  nix.maxJobs = lib.mkDefault 12;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware.bluetooth.enable = true;
  hardware.pulseaudio.enable = true;
  sound.enable = true;

}
