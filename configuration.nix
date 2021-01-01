{ config, pkgs, lib, ... }:

{
  imports =
    [
      # change this if on different machine:
      ./hosts/napolin/configuration.nix
    ];
}
