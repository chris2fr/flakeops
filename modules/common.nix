{
  config,
  pkgs,
  lib,
  caddy-ui-lesgv,
  ...
}: let
in {
  environment.systemPackages = with pkgs; [
    (
      (vim-full.override {}).customize {
        name = "vim";
        vimrcConfig.customRC = ''
          " your custom vimrc
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
          " ...
        '';
      }
    )
    home-manager
    # automake
    bat
    curl
    dig
    git
    gnumake
    inetutils
    killall
    lynx
    lzlib
    nftables
    ntfs3g
    openldap
    pwgen
    python3
    tmux
    wget
    zlib
    nftables
    firefox
    seafile-client
    parted
    python313Packages.pillow
    python313Packages.pypillowfight
    ffmpeg-full
    net-tools
  ];
}
