{ pkgs, ... }:
{
  environment.variables = { EDITOR = "vim"; };

  environment.systemPackages = with pkgs; [
    ((vim_configurable.override { python = python3; }).customize{
      name = "vim";
      vimrcConfig.customRC = "";
    }
  )];
}
