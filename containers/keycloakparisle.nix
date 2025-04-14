{ config, pkgs, lib, ... }:
let
in
{
  containers.keycloakparisle = {
    bindMounts = {
      "/var/lib/acme/keycloak.parisle.com/" = {
        hostPath = "/var/lib/acme/keycloak.parisle.com/";
        isReadOnly = true;
      };
    };
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.114.10";
    localAddress = "192.168.114.11";
    hostAddress6 = "fc00::14:1";
    localAddress6 = "fc00::14:2";
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
        # "f /etc/.secret.keycloackparislecomdata 0660 root root"
        "d /var/lib/acme/keycloak.parisle.com/ 0755 acme wwwrun"
        "f /etc/.secret.keycloakparislecom 0664 keycloak postgres"
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
          enableTCPIP = true;
          ensureUsers = [{
            name = "keycloakparisle";
            ensureDBOwnership = true;
          }];
          ensureDatabases = ["keycloakparisle"];

        };
        keycloak = {
          enable = true;
          database = {
            # username = "keycloak";
            username = "keycloakparisle";
            name="keycloakparisle"; # I think the database is keycloak and not key
            # passwordFile="/etc/.secrets.key";
            passwordFile = "/etc/.secret.keycloakparisle";
            createLocally=false;
            host="localhost";
            # useSSL = false;
            # host = "/run/postgresql";
          };
          settings = {
            https-port = 14447;
            http-port = 14087;
            # proxy = "passthrough";
            # proxy = "reencrypt";
            proxy-headers = "xforwarded";
            hostname = "keycloak.parisle.com";
            # hostname-admin = "adminkeycloak.parisle.com";
          };
          sslCertificate = "/var/lib/acme/keycloak.parisle.com/fullchain.pem";
          sslCertificateKey = "/var/lib/acme/keycloak.parisle.com/key.pem";
          initialAdminPassword = "lksajdflkasjlkghk3573985798214dskjhgfkjsahf";
          # themes = {lesgv = (pkgs.callPackage "/etc/nixos/keycloaktheme/derivation.nix" {});};
        };
      };
    };
  };
}
