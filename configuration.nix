# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let 
in 
{
  nix.settings.experimental-features = "nix-command flakes";
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./common.nix
      ./users.nix
      ./networking.nix
      ./nfs.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  systemd.tmpfiles.rules = [
    "d /export 0755 nfsuser users"
    "d /export/rd1 0755 nfsuser users"
    "d /export/rd2 0755 nfsuser users"
    "d /export/rd3 0755 nfsuser users"
    "d /export/rd4 0755 nfsuser users"
    "d /srv 0755 nfsuser users"
    "d /srv/rd1 0755 nfsuser users"
    "d /srv/rd2 0755 nfsuser users"
    "d /srv/rd3 0755 nfsuser users"
    "d /srv/rd4 0755 nfsuser users"
  ];

  services.openssh = {
    ports = [22 22222];

    enable = true;
  };
  services.locate = {
    enable = true;
    package = pkgs.mlocate;
  };
  
  services.rsyncd = {
    enable = true;
    settings = {
        srv = {
          #"auth users" = "tim";
          comment = "SRV Directories";
          path = "/srv/";
           "read only" = "no";
           list = "yes";
          # "secrets file" = "/var/run/rsyncd/secrets";
        };
      };
    };

  # Configure console keymap
  console.keyMap = "fr";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    apfs-fuse
    fdupes
    findutils
    fuse
    ntfs3g
    pkg-config
    rmlint
    perccli
    lm_sensors
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
