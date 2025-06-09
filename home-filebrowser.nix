{ config, pkgs, lib, ... }:
let
in
{
  home.username = "filebrowser";
  home.homeDirectory = "/home/filebrowser";
  home.packages = with pkgs; [
    filebrowser
  ];
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
