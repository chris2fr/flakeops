{ config, pkgs, lib, ... }:
let
in 
{
  home.username = "mannchri";
  home.homeDirectory = "/home/mannchri";
  home.packages = [ 
    pkgs.atool 
    pkgs.httpie 
    pkgs.nodejs_20
  ];
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [ vim-airline ];
    settings = { ignorecase = true; tabstop = 2; };
    extraConfig = ''
      set mouse=a
      set nocompatible
      colo torte
      syntax on
      set tabstop     =2
      set softtabstop =2
      set shiftwidth  =2
      set expandtab
      set autoindent
      set smartindent
    '';
  };
}