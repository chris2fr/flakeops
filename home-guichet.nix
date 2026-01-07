{
  config,
  pkgs,
  lib,
  ...
}: let
in {
  home.username = "guichet";
  home.homeDirectory = "/home/guichet";
  home.packages = with pkgs; [
    go
    gnumake
    python311
    nodejs_20
  ];
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
}
