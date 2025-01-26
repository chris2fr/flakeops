# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{ config, pkgs, lib, ... }:
let
  home-manager = import vars/home-manager.nix;
in
{
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.config.allowUnfree = true; 
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 113272;
    "fs.inotify.max_user_instances" = 256;
    "fs.inotify.max_queued_events" = 32768;
  };
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./httpd.nix
    ./mailserver.nix
    ./guichet.nix
    ./postgresql.nix
    ./users.nix
    ./systemd.nix
    ./wagtail.nix
    ./common.nix # Des configurations communes pratiques
    ./servers.nix # I am migrating other services here
    ./services.nix
    ./containers.nix
    ./nginx.nix
    ./security.nix
    ./networking.nix
    ./home-manager.nix
    (import "${home-manager}/nixos")
  ];
  systemd.tmpfiles.rules = [
    "d /var/www/key.lesgrandsvoisins.com 0755 www users -"
    "d /var/www/lesgrandsvoisins.com 0755 www users -"
    "d /var/www/lesgrandsvoisins 0755 wagtail users -"
    "d /var/www/lesgrandsvoisins/static 0755 wagtail users -"
    "d /var/www/lesgrandsvoisins/medias 0755 wagtail users -"
    "d /run/wagtail-sockets 0770 wagtail wwwrun -"
    "f /run/wagtail-sockets/wagtail.sock 0660 wagtail wwwrun"
  ];
  # Use the systemd-boot EFI boot loader.
  environment.systemPackages = with pkgs; [
    yarn
    filebrowser
    cacert
    # burp
    openssl
    # postgresql_14
    qemu
    # (pkgs.callPackage ./etc/sftpgo/sftpgo/default.nix { }  )
    (pkgs.callPackage ./etc/sftpgo/sftpgo-plugin-auth/sftpgoPluginAuth.nix { }  )
  ];
  age.secrets = {
    "keylesgrandsvoisins.vikunja" = { file = ./secrets/keylesgrandsvoisins.vikunja.age; owner = "vikunja";};
    "key.sftpgo" = { file = ./secrets/key.sftpgo.age; owner = "sftpgo";};
    "keycloak.vikunja" = { file = ./secrets/keycloak.vikunja.age;};
    "email.list" = { file = ./secrets/email.list.age; group="wwwrun"; mode="770";};
    # "bind.slappasswd" = { file = ./secrets/bind.slappasswd.age;};
    "vikunja.env" = { 
      file = ./secrets/vikunja.env.age; 
      owner = "vikunja";
    };
  };
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  # Set your time zone.
  time.timeZone = "Europe/Paris";
  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
  environment.sessionVariables = rec {
    EDITOR="vim";
    WAGTAIL_ENV = "production";
  };
  virtualisation.libvirtd.enable = true;
}