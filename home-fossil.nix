{
  config,
  pkgs,
  lib,
  ...
}: let
in {
  home.username = "fossil";
  home.homeDirectory = "/home/fossil";
  home.packages = with pkgs; [
    fossil
  ];
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
}
