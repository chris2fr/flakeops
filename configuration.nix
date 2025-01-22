{ config, pkgs, lib, ... }:
let 
in
{
  nix.settings.experimental-features = "nix-command flakes";
  system.stateVersion = "24.11";
  imports = [
    ./hardware-configuration.nix
    ./common.nix # Des configurations communes pratiques
    ./networking.nix
    ./users.nix
    ./nfs.nix
  ];
  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  system.copySystemConfiguration = true;

  time.timeZone = "Europe/Paris";

  environment.sessionVariables = {
    EDITOR="vim";
  };

  systemd = {
    extraConfig = ''
      DefaultTimeoutStartSec=600s
    '';
    # tmpfiles.rules = [
    #   "d /export nfsuser users"
    #   "d /export/data1 nfsuser users"
    #   "d /export/data2 nfsuser users"
    #   "d /export/data3 nfsuser users"
    #   "d /export/data4 nfsuser users"
    #   "d /export/data5 nfsuser users"
    #   "d /export/data6 nfsuser users"
    #   "d /export/data7 nfsuser users"
    #   "d /export/data8 nfsuser users"
    #   "d /export/data9 nfsuser users"
    #   "d /srv nfsuser users"
    #   "d /srv/data1 nfsuser users"
    #   "d /srv/data2 nfsuser users"
    #   "d /srv/data3 nfsuser users"
    #   "d /srv/data4 nfsuser users"
    #   "d /srv/data5 nfsuser users"
    #   "d /srv/data6 nfsuser users"
    #   "d /srv/data7 nfsuser users"
    #   "d /srv/data8 nfsuser users"
    #   "d /srv/data9 nfsuser users"
    # ];
  };

  # security.acme = {
  #   acceptTerms = true;
  #   defaults.email = "chris@lesgrandsvoisins.com";
  # };

  services = {
    openssh = {
      enable = true;
      # listenAddresses = [
      #   {
      #     addr = "0.0.0.0";
      #     port = 22;
      #   } 
      # ];
      # settings.PermitRootLogin = "no";
    };
    # rsyncd.enable = true;
    # nginx = {
    #   enable = true;
    #   virtualHosts = {
    #     localhost = {
    #       locations."/" = {
    #         return = "200 '<html><body>It works</body></html>'";
    #         extraConfig = ''
    #           default_type text/html;
    #         '';
    #       };
    #     };
    #   };
    # };
  };
}
