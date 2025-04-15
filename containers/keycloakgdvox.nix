{ config, pkgs, lib, ... }:
let
in
{
  containers.keycloakgdvox = {
    bindMounts = {
      "/var/lib/acme/keycloak.gdvox.com/" = {
        hostPath = "/var/lib/acme/keycloak.gdvox.com/";
        isReadOnly = true;
      };
    };
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.115.10";
    localAddress = "192.168.115.11";
    hostAddress6 = "fc00::115:10";
    localAddress6 = "fc00::115:11";
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
        openssl
      ];
      # virtualisation.docker.enable = true;
      system.stateVersion = "24.11";
      nix.settings.experimental-features = "nix-command flakes";
      networking = {
        firewall = {
          enable = false;
          allowedTCPPorts = [ 443 587 14446 ];
        };
        useHostResolvConf = lib.mkForce false;
      };
      systemd.tmpfiles.rules = [
        # "f /etc/.secret.keycloakgdvoxcomdata 0660 root root"
        "d /var/lib/acme/keycloak.gdvox.com/ 0750 acme wwwrun"
        "f /etc/.secret.keycloakgdvoxcom 0660 keycloak postgres"
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
            members = [ "acme" "wwwrun" "keycloak"];
          };
          "keycloak" = {
            members = [ "keycloak" ];
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
          enableTCPIP = true;
          settings = {
            ssl = true;
          };
          ensureUsers = [{
            name = "keycloakgdvox";
            ensureDBOwnership = true;
          }];
          ensureDatabases = ["keycloakgdvox"];
        };
        # keycloak = {
        #   enable = true;
        #   database = {
        #     username = "keycloakgdvox";
        #     # name = "keycloakgdvox";
        #     name="keycloakgdvox"; # I think the database is keycloak and not key
        #     # passwordFile="/etc/.secrets.key";
        #     passwordFile = "/etc/.secret.keycloakgdvoxcom";
        #     createLocally=false;
        #     host="127.0.0.1";
        #     # useSSL = false;
        #   };
        #   settings = {
        #     https-port = 14446;
        #     http-port = 14086;
        #     # proxy = "passthrough";
        #     # proxy = "reencrypt";
        #     proxy-headers = "xforwarded";
        #     hostname = "keycloak.gdvox.com";
        #     hostname-admin = "adminkeycloak.gdvox.com";
        #   };
        #   sslCertificate = "/var/lib/acme/keycloak.gdvox.com/fullchain.pem";
        #   sslCertificateKey = "/var/lib/acme/keycloak.gdvox.com/key.pem";
        #   initialAdminPassword = "lksajdflkasjlkghk3573985798214dskjhgfkjsahf";
        #   # themes = {lesgv = (pkgs.callPackage "/etc/nixos/keycloaktheme/derivation.nix" {});};
        # };
      };
    };
  };
}
