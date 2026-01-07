{
  config,
  pkgs,
  lib,
  ...
}: let
in {
  home.username = "filebrowser";
  home.homeDirectory = "/home/filebrowser";
  home.packages = with pkgs; [
    filebrowser
  ];
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
}
