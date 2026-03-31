{
  config,
  pkgs,
  lib,
  ...
}: let
  mannchriRsaPublic = lib.removeSuffix "\n" (builtins.readFile mailserver/vars/cert-public.nix);
  # home-manager = builtins.fetchTarball {
  #   url="https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz";
  #   sha256="sha256:1rj0cazl5kjcfn4433fj31293yx421wbawryp5q3bq3fsmhkkr9h";
  # };
  ghostTemplate = pkgs.callPackage ./derivations/ghost-lgv-headline/package.nix {};
in {
  # imports = [
  #   (import "${home-manager}/nixos")
  # ];
  ## Apostrophe CMS
  systemd.tmpfiles.rules = [
    "L /var/www/ghost/content/themes/current - - - - symlink/${ghostTemplate}"
    "L /var/www/ghost/content/themes/lgvblog - - - - symlink/${ghostTemplate}"
  ];
  users.users.aaa = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [mannchriRsaPublic];
    packages = with pkgs; [nodejs_20];
  };
  #   home-manager.users.aaa = {pkgs, ...}: {
  #     # I'll use Mongo in a Docker Container
  # #    nixpkgs = {
  # #      config = {
  # #        allowUnfree = true;
  # #        allowUnfreePredicate = (_: true);
  # #      };
  # #    };
  #     home.stateVersion = "25.11";
  #     programs.home-manager.enable = true;
  #     home.packages = with pkgs; [
  #       nodejs_20
  # #      mongodb
  #     ];
  #   };
  ## GHOSTIO
  users.users.ghostio = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [mannchriRsaPublic];
    extraGroups = ["wwwrun"];
  };
  ## ODOO FOR
  users.users.odoofor = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [mannchriRsaPublic];
  };
  ## ODOO THREE
  users.users.odoothree = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [mannchriRsaPublic];
  };
  ## ODOO TOO
  users.users.odootoo = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [mannchriRsaPublic];
  };
  ## ODOO
  users.users.odoo = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [mannchriRsaPublic];
  };
  # Docker
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  users.extraGroups.docker.members = ["mannchri"];
  services.mysql.enable = true;
  services.mysql.package = pkgs.mysql80;

  systemd.services.ghostio = {
    enable = true;
    description = "Ghost systemd service for blog.lesgrandsvoisins.fr: localhost";
    environment = {
      NODE_ENV = "production";
    };
    documentation = ["https://ghost.org/docs/"];
    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/var/www/ghost";
      User = "ghost";
      ExecStart = "/home/ghost/.nix-profile/bin/node /home/ghost/node_modules/ghost-cli/bin/ghost run";
      Restart = "always";
    };
    wantedBy = ["multi-user.target"];
  };
  systemd.services.ghostlesgrandsvoisinscom = {
    enable = true;
    description = "Ghost systemd service for blog.lesgrandsvoisins.com: localhost";
    environment = {
      NODE_ENV = "production";
    };
    documentation = ["https://ghost.org/docs/"];
    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/var/www/ghostlesgrandsvoisinscom";
      User = "ghost";
      ExecStart = "/home/ghost/.nix-profile/bin/node /home/ghost/node_modules/ghost-cli/bin/ghost run";
      Restart = "always";
    };
    wantedBy = ["multi-user.target"];
  };
  systemd.services.ghostresdigitacom = {
    enable = true;
    description = "Ghost systemd service for ghost.resdigita.com: localhost";
    environment = {
      NODE_ENV = "production";
    };
    documentation = ["https://ghost.org/docs/"];
    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/var/www/ghostresdigitacom";
      User = "ghost";
      ExecStart = "/home/ghost/.nix-profile/bin/node /home/ghost/node_modules/ghost-cli/bin/ghost run";
      Restart = "always";
    };
    wantedBy = ["multi-user.target"];
  };
  users.users.ghost = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [mannchriRsaPublic];
    extraGroups = ["wwwrun"];
    packages = with pkgs; [
      nodejs_20
      # nodejs_18
    ];
  };
  services.mysql = {
    ensureDatabases = [
      "ghost"
      "ghostlesgrandsvoisinscom"
      "ghostresdigitacom"
    ];
    ensureUsers = [
      {
        name = "gvoisin";
        ensurePermissions = {
          "ghost.*" = "ALL PRIVILEGES";
          "gvoisin.*" = "ALL PRIVILEGES";
          "ghostlesgrandsvoisinscom.*" = "ALL PRIVILEGES";
          "ghostresdigitacom.*" = "ALL PRIVILEGES";
          # "*.*" = "SELECT, LOCK TABLES, SHOW VIEW, RELOAD";
        };
      }
      {
        name = "ghostlesgrandsvoisinscom";
        ensurePermissions = {
          "ghostlesgrandsvoisinscom.*" = "ALL PRIVILEGES";
        };
      }
      {
        name = "ghostresdigitacom";
        ensurePermissions = {
          "ghostresdigitacom.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };
  # home-manager.users.ghost = {pkgs, ...}: {
  #   home.stateVersion = "25.11";
  #   programs.home-manager.enable = true;
  #   home.packages = with pkgs; [
  #     nodejs_18
  #   ];
  # };
  # virtualisation.lxd.enable = true;
  # chris2fr 2025-08-24 chris2
  # virtualisation.lxd.enable = false;
  virtualisation.lxc.enable = true;
  virtualisation.lxc.lxcfs.enable = true;
}
