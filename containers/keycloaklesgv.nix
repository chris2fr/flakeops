{ config, pkgs, lib, ... }:
let
in
{
  containers.keycloaklesgv = {
    bindMounts = {
      "/var/lib/acme/keycloak.coolgv.com/" = {
        hostPath = "/var/lib/acme/keycloak.coolgv.com/";
        isReadOnly = true;
      };
    };
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.117.10";
    localAddress = "192.168.117.11";
    hostAddress6 = "fc00::117:10";
    localAddress6 = "fc00::117:11";
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
        # "f /etc/.secret.keycloaklesgvorgdata 0660 root root"
        "d /var/lib/acme/keycloak.coolgv.com/ 0750 acme wwwrun"
        "d /var/lib/acme/keycloak.gdvoisins.com/ 0750 acme wwwrun"
        "d /etc/postgresql/ 0750 postgres keycloak"
        "f /etc/.secret.keycloaklesgvorg 0660 keycloak postgres"
      ];
      security.acme.acceptTerms = true;
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
      # systemd.services.postgresql.postStart = "cp -a ~postgres/server.crt /run/postgresql/server.crt";

      services = {
        resolved.enable = true;
        postgresql = {
          package = pkgs.postgresql_17;
          enable = true;
          enableTCPIP = true;
          settings = {
            ssl = true;
            ssl_cert_file = "/etc/postgres-server.crt";
          };
          ensureUsers = [{
            name = "keycloaklesgv";
            ensureDBOwnership = true;
          }];
          ensureDatabases = ["keycloaklesgv"];
        };
        keycloak = {
          enable = true;
          database = {
            username = "keycloaklesgv";
            # name = "keycloaklesgv";
            name="keycloaklesgv"; # I think the database is keycloak and not key
            # passwordFile="/etc/.secrets.key";
            passwordFile = "/etc/.secret.keycloaklesgvorg";
            createLocally=false;
            host="127.0.0.1";
            # useSSL = false;
            caCert = "/etc/postgres-server.crt";
          };
          settings = {
            https-port = 14446;
            http-port = 14086;
            # proxy = "passthrough";
            # proxy = "reencrypt";
            proxy-headers = "xforwarded";
            hostname = "keycloak.gdvoisins.com";
            # hostname = "keycloak.coolgv.com";
            # hostname-admin = "adminkeycloak.coolgv.com";
          };
          sslCertificate = "/var/lib/acme/keycloak.gdvoisins.com/fullchain.pem";
          sslCertificateKey = "/var/lib/acme/keycloak.gdvoisins.com/key.pem";
          initialAdminPassword = "lksajdflkasjlkgh5798214dskjhgfkjsahf";
          # themes = {lesgv = (pkgs.callPackage "/etc/nixos/keycloaktheme/derivation.nix" {});};
        };
      };
    };
  };
}
