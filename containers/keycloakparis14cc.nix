{
  config,
  pkgs,
  lib,
  ...
}: let
in {
  containers.keyparis14cc = {
    bindMounts = {
      "/var/lib/acme/keycloak.paris14.cc/" = {
        hostPath = "/var/lib/acme/keycloak.paris14.cc/";
        isReadOnly = true;
      };
    };
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.110.10";
    localAddress = "192.168.110.11";
    hostAddress6 = "fa10::1";
    localAddress6 = "fa10::2";
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      imports = [
        ../common.nix
      ];
      environment.systemPackages = with pkgs; [
        (
          (vim-full.override {}).customize {
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
      system.stateVersion = "25.11";
      nix.settings.experimental-features = "nix-command flakes";
      networking = {
        interfaces."eth0".useDHCP = true;
        firewall = {
          enable = false;
          allowedTCPPorts = [443 587 14445];
        };
        useHostResolvConf = lib.mkForce false;
      };
      systemd.tmpfiles.rules = [
        # "f /etc/.secret.keycloackparis14ccdata 0660 root root"
        "d /var/lib/acme/keycloak.paris14.cc/ 0750 acme wwwrun"
        "f /etc/.secret.keycloackparis14cc 0660 keycloak postgres"
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
          ensureUsers = [
            {
              name = "keyparis14cc";
              ensureDBOwnership = true;
            }
          ];
          ensureDatabases = ["keyparis14cc"];
        };
        keycloak = {
          enable = true;
          database = {
            # username = "keyparis14cc";
            # name = "keyparis14cc";
            # name="key"; # I think the database is keycloak and not key
            # passwordFile="/etc/.secrets.key";
            passwordFile = "/etc/.secret.keycloackparis14cc";
            # createLocally=false;
            # host="localhost";
            # useSSL = false;
          };
          settings = {
            https-port = 14445;
            http-port = 14085;
            # proxy = "passthrough";
            # proxy = "reencrypt";
            proxy-headers = "xforwarded";
            hostname = "keycloak.paris14.cc";
            # hostname-admin = "adminkeycloak.paris14.cc";
          };
          sslCertificate = "/var/lib/acme/keycloak.paris14.cc/fullchain.pem";
          sslCertificateKey = "/var/lib/acme/keycloak.paris14.cc/key.pem";
          initialAdminPassword = "lksajdflkasjlkghk3573985798214dskjhgfkjsahf";
          # themes = {lesgv = (pkgs.callPackage "/etc/nixos/keycloaktheme/derivation.nix" {});};
        };
      };
    };
  };
}
