{ config, pkgs, lib, ... }:
let 
in
{
  ############################################################
  # FROM CONFIGURATION.NIX
  ############################################################
  # imports = [
  #   #  <home-manager/nixos>
  #   #  <agenix/modules/age.nix>
  # ];
  # boot.loader.grub.devices = [ "nodev" ];
  # boot.loader.grub.efiSupport = true;
  # age.secrets = {
  #   secret1 = {
  #     file = ./secrets/secret1.age;
  #     owner = "mannchri";
  #     mode = "770";
  #   };
  #   adminresdigitaorg = { file = ./secrets/adminresdigitaorg.age; };
  #   alice = { file = ./secrets/alice.age; };
  #   bob = { file = ./secrets/bob.age; };
  #   bind = { file = ./secrets/bind.age; };
  #   "mailserver.alice" = { file = ./secrets/mailserver.alice.age; };
  #   "mailserver.bob" = { file = ./secrets/mailserver.bob.age; };
  #   "mailserver.bind" = { file = ./secrets/mailserver.bind.age; };
  #   "mailserver.sogo" = { file = ./secrets/mailserver.sogo.age; };
  #   "sogo" = { file = ./secrets/sogo.age; };
  # };
  #  virtualisation.docker.enable = true;
  #  users.extraGroups.docker.members = [ "mannchri" ];
  #  pkgs.dockerTools.pullImage = {
  #    imageName = "dnknth/ldap-ui";
  #    finalImageTag = "latest";
  #    imageDigest = "sha256:c34a8feb5978888ebe5ff86884524b30759469c91761a560cdfe968f6637f051";
  #    sha256 = "";
  #  };
  #  home-manager.users.fossil = {pkgs, ...}: {
  #    home.packages = with pkgs; [ 
  #      fossil
  #    ];
  #    home.stateVersion = "23.05";
  #    programs.home-manager.enable = true;
  #  };
  #  home-manager.users.mannchri = {pkgs, ...}: {
  #    home.packages = [ pkgs.atool pkgs.httpie ];
  #    home.stateVersion = "23.05";
  #    programs.home-manager.enable = true;
  #    programs.vim = {
  #      enable = true;
  #      plugins = with pkgs.vimPlugins; [ vim-airline ];
  #      settings = { ignorecase = true; tabstop = 2; };
  #      extraConfig = ''
  #        set mouse=a
  #        set nocompatible
  #        colo torte
  #        syntax on
  #        set tabstop     =2
  #        set softtabstop =2
  #        set shiftwidth  =2
  #        set expandtab
  #        set autoindent
  #        set smartindent
  #      '';
  #    };
  #  };
  #  users.extraUsers.root.openssh.authorizedKeys.keys =
  #  [ "..." ];
}