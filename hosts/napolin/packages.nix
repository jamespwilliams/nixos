{ config, pkgs, lib, ... }:

{
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
}
