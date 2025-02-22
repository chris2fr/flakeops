{ config, pkgs, lib, ... }:
let
  # home-manager = import vars/home-manager.nix;
  # home-manager = builtins.fetchTarball { 
  #   url="https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz"; 
  #   sha256="sha256:00wp0s9b5nm5rsbwpc1wzfrkyxxmqjwsc1kcibjdbfkh69arcpsn"; 
  #   };
in
{
  # home-manager.users.crabfit = {
  #   home.packages = with pkgs; [ 
  #     yarn
  #   ];
  #   home.stateVersion = "24.11";
  #   programs.home-manager.enable = true;
  # };
  home-manager.users = {
    fossil = { pkgs, ... }: {
      home.packages = with pkgs; [
        fossil
      ];
      home.stateVersion = "24.11";
      programs.home-manager.enable = true;
    };
    # radicale = {pkgs, ...}: {
    #   home.packages = with pkgs; [ 
    #     python311
    #     python311Packages.gunicorn
    #   ];
    #   home.stateVersion = "24.11";
    #   programs.home-manager.enable = true;
    # };
    guichet = { pkgs, ... }: {
      home.packages = with pkgs; [
        go
        gnumake
        python311
        nodejs_20
      ];
      home.stateVersion = "24.11";
      programs.home-manager.enable = true;
    };
    filebrowser = { pkgs, ... }: {
      home.packages = with pkgs; [
        filebrowser
      ];
      home.stateVersion = "24.11";
      programs.home-manager.enable = true;
    };
    mannchri = { pkgs, ... }: {
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
    };
  };
}
