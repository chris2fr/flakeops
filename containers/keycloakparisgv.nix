{
  config,
  pkgs,
  lib,
  ...
}: let
in {
  containers.keycloakparisgv = {
    bindMounts = {
      "/var/lib/acme/keycloak.parisgv.com/" = {
        hostPath = "/var/lib/acme/keycloak.parisgv.com/";
        isReadOnly = true;
      };
    };
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.116.10";
    localAddress = "192.168.116.11";
    hostAddress6 = "fc00::116:10";
    localAddress6 = "fc00::116:11";
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
        openssl
      ];
      # virtualisation.docker.enable = true;
      system.stateVersion = "25.11";
      nix.settings.experimental-features = "nix-command flakes";
      networking = {
        interfaces."eth0".useDHCP = true;
        firewall = {
          enable = false;
          allowedTCPPorts = [443 587 14446];
        };
        useHostResolvConf = lib.mkForce false;
      };
      systemd.tmpfiles.rules = [
        # "f /etc/.secret.keycloakparisgvdata 0660 root root"
        "d /var/lib/acme/keycloak.parisgv.com/ 0750 acme wwwrun"
        "d /etc/postgresql/ 0750 postgres keycloak"
        "f /etc/.secret.keycloakparisgv 0660 keycloak postgres"
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
            members = ["acme" "wwwrun" "keycloak"];
          };
          "keycloak" = {
            members = ["keycloak"];
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
      # systemd.services.postgresql.preStart = "cd ~postgres/ && [ -f ~postgres/server.crt ] || openssl req -new -x509 -days 365 -nodes -text -out ~postgres/server.crt  -keyout ~postgres/server.key -subj '/CN=keycloak.parisgv.com'";
      # systemd.services.postgresql.postStart = "cp -a ~postgres/server.crt /run/postgresql/server.crt";
      services = {
        resolved.enable = true;
        postgresql = {
          package = pkgs.postgresql_17;
          enable = true;
          enableTCPIP = true;
          settings = {
            ssl = true;
            ssl_cert_file = "/etc/postgres/server.crt";
          };
          ensureUsers = [
            {
              name = "keycloakparisgv";
              ensureDBOwnership = true;
            }
          ];
          ensureDatabases = ["keycloakparisgv"];
        };
        keycloak = {
          enable = true;
          database = {
            username = "keycloakparisgv";
            # name = "keycloakparisgv";
            name = "keycloakparisgv"; # I think the database is keycloak and not key
            # passwordFile="/etc/.secrets.key";
            passwordFile = "/etc/.secret.keycloakparisgv";
            createLocally = false;
            host = "localhost";
            # useSSL = false;
            caCert = "/etc/postgresql/server.crt";
          };
          settings = {
            https-port = 14446;
            http-port = 14086;
            # proxy = "passthrough";
            # proxy = "reencrypt";
            proxy-headers = "xforwarded";
            hostname = "keycloak.parisgv.com";
            # hostname-admin = "adminkeycloak.parisgv.com";
          };
          sslCertificate = "/var/lib/acme/keycloak.parisgv.com/fullchain.pem";
          sslCertificateKey = "/var/lib/acme/keycloak.parisgv.com/key.pem";
          initialAdminPassword = "lksajdflkasjlkghk3573985afs23344dskjhgfkjsahf";
          # themes = {lesgv = (pkgs.callPackage "/etc/nixos/keycloaktheme/derivation.nix" {});};
        };
      };
    };
  };
}
