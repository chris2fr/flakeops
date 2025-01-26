{ config, pkgs, lib, ... }:
let
in
{
  containers.key = {
    bindMounts = {
      "/var/lib/acme/key.lesgrandsvoisins.com/" = {
        hostPath = "/var/lib/acme/key.lesgrandsvoisins.com/";
        isReadOnly = true;
      }; 
    };
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.105.10";
    localAddress = "192.168.105.11";
    hostAddress6 = "fa01::1";
    localAddress6 = "fa01::2";
    config = { config, pkgs, lib, ...  }: {
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
            " ...
          '';
          }
        )
        git
        lynx
        openldap
        postgresql
      ];
      # virtualisation.docker.enable = true;
      system.stateVersion = "24.11";
      nix.settings.experimental-features = "nix-command flakes";
      networking = {
        firewall = {
          enable = false;
          allowedTCPPorts = [  443 587 14443 ]; 
        };
        useHostResolvConf = lib.mkForce false;
      };
      systemd.tmpfiles.rules = [
       "f /etc/.secret.keydata 0660 root root"
      ];
      # security.acme.acceptTerms = true;
      users = {
        groups = {
          "acme" = {
            gid = 993;
            members = ["acme"];
          };
          "wwwrun" = {
            gid = 54;
            members = ["acme" "wwwrun"];
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
        };
      };
      services = {
        resolved.enable = true;
        postgres.package = postgresql_15;
        keycloak = {
          enable = true;
          database = {
            username="key";
            name="key";
            # passwordFile="/etc/.secrets.key";
            passwordFile="/etc/.secrets.key";
            # createLocally=false;
            # host="localhost";
            # useSSL = false;
          };
          settings = {
            https-port = 14443;
            http-port = 14080;
            # proxy = "passthrough";
            # proxy = "reencrypt";
            proxy-headers = "xforwarded";
            hostname = "key.lesgrandsvoisins.com";
            # hostname-admin = "adminkey.lesgrandsvoisins.com";
          };
          sslCertificate = "/var/lib/acme/key.lesgrandsvoisins.com/fullchain.pem";
          sslCertificateKey = "/var/lib/acme/key.lesgrandsvoisins.com/key.pem";
          # themes = {lesgv = (pkgs.callPackage "/etc/nixos/keycloaktheme/derivation.nix" {});};
        };
      };
    };
  };
}