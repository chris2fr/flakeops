{ config, pkgs, ... }:

let
in
{
  environment.systemPackages = with pkgs; [
    ((vim_configurable.override {  }).customize{
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
        " ...1057,381
      '';
      }
    )
    automake
    atop
    bat
    curl
    dig
    git
    gnumake
    # home-manager
    htop
    inetutils
    killall
    lynx
    lzlib
    nftables
    ntfs3g
    openldap
    pwgen
    python3Full
    tmux
    wget
    zlib
    mlocate
  ];
}
