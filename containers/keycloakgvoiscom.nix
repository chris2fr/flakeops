{ config, pkgs, lib, ... }:
let
  keyclaokgvoisPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/.secrets.keycloakgvois));
in
{
  containers.keycloakgvois = {
    bindMounts = {
      "/var/lib/acme/keycloak.gvois.com/" = {
        hostPath = "/var/lib/acme/keycloak.gvois.com/";
        isReadOnly = true;
      };
    };
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.113.10";
    localAddress = "192.168.113.11";
    hostAddress6 = "fc00::13:1";
    localAddress6 = "fc00::13:2";
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
        postgresql_17
      ];
      # virtualisation.docker.enable = true;
      system.stateVersion = "25.05";
      nix.settings.experimental-features = "nix-command flakes";
      networking = {
        firewall = {
          enable = false;
          allowedTCPPorts = [ 443 587 14446 ];
        };
        useHostResolvConf = lib.mkForce false;
      };
      systemd.tmpfiles.rules = [
        # "f /etc/.secret.keycloakgvoiscomdata 0660 root root"
        "d /var/lib/acme/keycloak.gvois.com/ 0750 acme wwwrun"
        "f /etc/.secret.keycloakgvoiscom 0660 keycloak postgres"
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
            isSystemUser = true;
          };
        };
      };
      services = {
        resolved.enable = true;
        postgresql = {
          package = pkgs.postgresql_17;
          enable = true;
          ensureUsers = [{
            name = "keycloakgvois";
            ensureDBOwnership = true;
          }];
          ensureDatabases = ["keycloakgvois"];
        };
        keycloak = {
          enable = true;
          database = {
            username = "keycloakgvois";
            # name = "keycloakgvois";
            name="keycloakgvois"; # I think the database is keycloak and not key
            # passwordFile="/etc/.secrets.key";
            passwordFile = "/etc/.secret.keycloakgvois";
            createLocally=false;
            # host="localhost";
            # useSSL = false;
          };
          settings = {
            https-port = 14446;
            http-port = 14086;
            # proxy = "passthrough";
            # proxy = "reencrypt";
            proxy-headers = "xforwarded";
            hostname = "keycloak.gvois.com";
            # hostname-admin = "adminkeycloak.gvois.com";
            initialAdminPassword = "${keyclaokgvoisPassword}";
          };
          sslCertificate = "/var/lib/acme/keycloak.gvois.com/fullchain.pem";
          sslCertificateKey = "/var/lib/acme/keycloak.gvois.com/key.pem";
          initialAdminPassword = "lksajdflkasjlkghk3573985798214dskjhgfkjsahf";
          # themes = {lesgv = (pkgs.callPackage "/etc/nixos/keycloaktheme/derivation.nix" {});};
        };
      };
    };
  };
}
