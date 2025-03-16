{ config, pkgs, lib, ... }:
let
in
{
  containers.keyresdigita = {
    bindMounts = {
      "/var/lib/acme/key.resdigita.com/" = {
        hostPath = "/var/lib/acme/key.resdigita.com/";
        isReadOnly = true;
      };
    };
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.106.10";
    localAddress = "192.168.106.11";
    hostAddress6 = "fa02::1";
    localAddress6 = "fa02::2";
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
        openldap
        postgresql_15
      ];
      # virtualisation.docker.enable = true;
      system.stateVersion = "24.11";
      nix.settings.experimental-features = "nix-command flakes";
      networking = {
        firewall = {
          enable = false;
          allowedTCPPorts = [ 443 587 14444 ];
        };
        useHostResolvConf = lib.mkForce false;
      };
      systemd.tmpfiles.rules = [
        "f /etc/.secret.keyresdigitadata 0660 root root"
        "d /var/lib/acme/key.resdigita.com/ 0750 acme wwwrun"
        "f /etc/.secret.keyresdigita 0660 keycloak postgres"
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
            members = [ "acme" "wwwrun" ];
          };
          "keycloak" = {};
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
          "keycloak" = {
            group = "keycloak";
          };
        };
      };
      services = {
        resolved.enable = true;
        postgresql = {
          package = pkgs.postgresql_15;
          enable = true;
          ensureUsers = [{
            name = "keyresdigita";
            ensureDBOwnership = true;
          }];
          ensureDatabases = ["keyresdigita"];
        };
        keycloak = {
          enable = true;
          database = {
            username = "keyresdigita";
            name = "keyresdigita";
            # name="key"; # I think the database is keycloak and not key
            # passwordFile="/etc/.secrets.key";
            passwordFile = "/etc/.secret.keyresdigita";
            # createLocally=false;
            # host="localhost";
            # useSSL = false;
          };
          settings = {
            https-port = 14444;
            http-port = 14084;
            # proxy = "passthrough";
            # proxy = "reencrypt";
            proxy-headers = "xforwarded";
            hostname = "key.resdigita.com";
            # hostname-admin = "adminkey.resdigita.com";
          };
          sslCertificate = "/var/lib/acme/key.resdigita.com/fullchain.pem";
          sslCertificateKey = "/var/lib/acme/key.resdigita.com/key.pem";
          # themes = {lesgv = (pkgs.callPackage "/etc/nixos/keycloaktheme/derivation.nix" {});};
        };
      };
    };
  };
}
