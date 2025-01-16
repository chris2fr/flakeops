{ config, pkgs, lib, ... }:
let 
  mannchriRsaPublic = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAuBWybYSoR6wyd1EG5YnHPaMKE3RQufrK7ycej7avw3Ug8w8Ppx2BgRGNR6EamJUPnHEHfN7ZZCKbrAnuP3ar8mKD7wqB2MxVqhSWvElkwwurlijgKiegYcdDXP0JjypzC7M73Cus3sZT+LgiUp97d6p3fYYOIG7cx19TEKfNzr1zHPeTYPAt5a1Kkb663gCWEfSNuRjD2OKwueeNebbNN/OzFSZMzjT7wBbxLb33QnpW05nXlLhwpfmZ/CVDNCsjVD1+NXWWmQtpRCzETL6uOgirhbXYW8UyihsnvNX8acMSYTT9AA3jpJRrUEMum2VizCkKh7bz87x7gsdA4wF0/w== rsa-key-20220407";
in
{
  nix.settings.experimental-features = "nix-command flakes";
  imports = [
    ./hardware-configuration.nix
    ./common.nix # Des configurations communes pratiques
  #  <home-manager/nixos>
  #  <agenix/modules/age.nix>
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.efiSupport = true;


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

  # users.users.fossil = rec {
  #     isNormalUser = true;
  #     openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
  # };
  users.users.mannchri = rec {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
      extraGroups = [ "wheel" "networkmanager" ];
  };
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
#
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "no";
  #users.extraUsers.root.openssh.authorizedKeys.keys =
  #  [ "..." ];
  
  networking.firewall.allowedTCPPorts = [ 22 80 443 636 ];
  # Networking
  networking.hostName = "t330roses"; # Define your hostname.
  networking.enableIPv6 = true;
  # networking.firewall.package
  networking.nftables.enable = true;
  
  systemd.extraConfig = ''
    DefaultTimeoutStartSec=600s
  '';

  time.timeZone = "Europe/Paris";

  system.stateVersion = "24.11";

  environment.sessionVariables = rec {
    EDITOR="vim";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "chris@lesgrandsvoisins.com";
  };
}
