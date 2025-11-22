{ config, pkgs, lib, ... }:
let
in
{
  containers.wikijs = {
    bindMounts = {
      "/var/lib/acme/www.configmagic.com/" = {
        hostPath = "/var/lib/acme/www.configmagic.com/";
        isReadOnly = true;
      };
    };
    # bindMounts = {
    #   "/var/lib/acme/keycloak.paris14.cc/" = {
    #     hostPath = "/var/lib/acme/keycloak.paris14.cc/";
    #     isReadOnly = true;
    #   };
    # };
    autoStart = true;
    privateNetwork = false;
    # hostAddress = "192.168.112.10";
    # localAddress = "192.168.112.11";
    # hostAddress6 = "fc00::12:1";
    # localAddress6 = "fc00::12:2";
    config = { config, pkgs, lib, ... }: {
      environment.systemPackages = with pkgs; [
        ((vim_configurable.override { }).customize {
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
        git
        lynx
      ];
      # virtualisation.docker.enable = true;
      system.stateVersion = "25.05";
      nix.settings.experimental-features = "nix-command flakes";
      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [25 587 3443 ];
        };
        # useHostResolvConf = lib.mkForce false;
      };
      systemd.tmpfiles.rules = [
        # "f /etc/.secret.keycloackparis14ccdata 0660 root root"
        "d /etc/wikijs/ 0750 wikijs root"
        "f /etc/wikijs/.env 0660 wikijs root"
        "d /var/lib/acme/www.configmagic.com/ 0750 acme wwwrun"
        # "d /var/lib/acme/keycloak.paris14.cc/ 0750 acme wwwrun"
        # "f /etc/.secret.keycloackparis14cc 0660 keycloak postgres"
      ];
      # security.acme.acceptTerms = true;
      users = {
        groups = {
          "acme" = {
            gid = 993;
            members = [ "acme" ];
          };
          "wwwrun" = {
            gid = 54;
            members = [ "acme" "wwwrun" "wikijs" "postgres"];
          };
        };
        users = {
          "acme" = {
            uid = 994;
            group = "acme";
          };
          "wwwrun" = {
            uid = 54;
            group = "wwwrun";
          };
          "wikijs" = {
            isNormalUser = true;
          };
        };
      };
      services.cron.systemCronJobs = [ "0 0 1 * *  root systemctl restart wiki-js"];
      services = {
        # resolved.enable = true;
        # postgresql = {
        #   package = pkgs.postgresql_17;
        #   enable = true;
        #   ensureUsers = [{
        #     name = "keyparis14cc";
        #     ensureDBOwnership = true;
        #   }];
        #   ensureDatabases = ["keyparis14cc"];
        # };
        wiki-js = {
          enable = true;
          environmentFile = "/etc/wikijs/.env";
          settings.db = {
            # host = "2a01:4f8:241:4faa::10";
            # port = 5434;
            # host = "localhost";
            host = "/run/postgresql/.s.PGSQL.5434";
            # host = "/run/postgresql/";
            db = "wikijs";
            user = "wikijs";
            # ssl = true;
          };
          settings.logLevel = "debug";
          settings.ssl = {
            enabled = true;
            port = 3443;
            provider = "custom";
            format = "pem";
            key = "/var/lib/acme/www.configmagic.com/key.pem";
            cert = "/var/lib/acme/www.configmagic.com/fullchain.pem";
          };
          settings.bindIP = "2a01:4f8:241:4faa::10";
        };
        postgresql = {
          enable = true;
          ensureUsers = [{name="wikijs";ensureDBOwnership=true;}];
          ensureDatabases = ["wikijs"];
          # enableTCPIP = true;
          # listen_addresses = "2a01:4f8:241:4faa::10";
          enableTCPIP = false;
          settings = {
            # ssl = true;
            # ssl_key_file = "/var/lib/acme/www.configmagic.com/key.pem";
            # ssl_cert_file = "/var/lib/acme/www.configmagic.com/fullchain.pem";
            port = 5434;
            listen_addresses = lib.mkForce "2a01:4f8:241:4faa::10";
          };
        };
      };
      systemd.services.wiki-js.serviceConfig.User = "wikijs";
    };
  };
}
