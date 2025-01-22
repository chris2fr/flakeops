{ config, pkgs, lib, ... }:
let 
in
{
  nix.settings.experimental-features = "nix-command flakes";
  imports = [
    ./hardware-configuration.nix
    ./common.nix # Des configurations communes pratiques
    ./networking.nix
    ./users.nix
    ./nfs.nix
  ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh = {
    enable = true;
    listenAddresses = [
      {
        addr = "0.0.0.0";
        port = 22;
      } 
    ];
  };
  services.openssh.settings.PermitRootLogin = "no";
  services.rsyncd.enable = true;
  
  systemd.extraConfig = ''
    DefaultTimeoutStartSec=600s
  '';

  systemd.tmpfiles.rules = [
    "d /export nfsuser nfsuser"
    "d /export/data1 nfsuser nfsuser"
    "d /export/data2 nfsuser nfsuser"
    "d /export/data3 nfsuser nfsuser"
    "d /export/data4 nfsuser nfsuser"
    "d /export/data5 nfsuser nfsuser"
    "d /export/data6 nfsuser nfsuser"
    "d /export/data7 nfsuser nfsuser"
    "d /export/data8 nfsuser nfsuser"
    "d /export/data9 nfsuser nfsuser"
    "d /srv nfsuser nfsuser"
    "d /srv/data1 nfsuser nfsuser"
    "d /srv/data2 nfsuser nfsuser"
    "d /srv/data3 nfsuser nfsuser"
    "d /srv/data4 nfsuser nfsuser"
    "d /srv/data5 nfsuser nfsuser"
    "d /srv/data6 nfsuser nfsuser"
    "d /srv/data7 nfsuser nfsuser"
    "d /srv/data8 nfsuser nfsuser"
    "d /srv/data9 nfsuser nfsuser"
  ];

  time.timeZone = "Europe/Paris";

  system.stateVersion = "24.11";

  environment.sessionVariables = rec {
    EDITOR="vim";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "chris@lesgrandsvoisins.com";
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      localhost = {
        locations."/" = {
          return = "200 '<html><body>It works</body></html>'";
          extraConfig = ''
            default_type text/html;
          '';
        };
      };
    };
  };
}
