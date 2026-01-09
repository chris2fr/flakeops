{
  config,
  pkgs,
  lib,
  ...
}: let
in {
  # containers.key-postgres = {
  #   autoStart = true;
  #   privateNetwork = true;
  #   # macvlans = [
  #   #   "eno1"
  #   # ];
  #   # hostBridge = "brkey";

  #   hostAddress = "192.168.105.10";
  #   localAddress = "192.168.105.11";
  #   hostAddress6 = "2a01:4f8:241:4faa::10:10";
  #   localAddress6 = "2a01:4f8:241:4faa::10:11";
  #   config = { config, pkgs, lib, ... }: {
  #     networking.extraHosts =
  #       ''
  #         192.168.105.11 key-postgres
  #       '';

  #     environment.systemPackages = with pkgs; [
  #       ((vim-full.override { }).customize {
  #         name = "vim";
  #         vimrcConfig.customRC = ''
  #           " your custom vimrc
  #           set mouse=a
  #           set nocompatible
  #           colo torte
  #           syntax on
  #           set tabstop     =2
  #           set softtabstop =2
  #           set shiftwidth  =2
  #           set expandtab
  #           set autoindent
  #           set smartindent
  #           " ...
  #         '';
  #       }
  #       )
  #       git
  #       lynx
  #       openldap
  #       postgresql_15
  #     ];
  #     # virtualisation.docker.enable = true;
  #     system.stateVersion = "25.11";
  #     nix.settings.experimental-features = "nix-command flakes";
  #     networking = {
  #       # firewall = {
  #       #   enable = false;
  #       #   allowedTCPPorts = [ 443 587 14443 ];
  #       # };
  #       useHostResolvConf = lib.mkForce false;
  #     };      systemd.tmpfiles.rules = [
  #       "f /etc/.secret.keydata 0660 root root"
  #     ];
  #     # security.acme.acceptTerms = true;
  #     users = {
  #       groups = {
  #         "acme" = {
  #           gid = 993;
  #           members = [ "acme" ];
  #         };
  #         "wwwrun" = {
  #           gid = 54;
  #           members = [ "acme" "wwwrun" ];
  #         };
  #       };
  #       users = {
  #         "acme" = {
  #           uid = 994;
  #           group = "acme";
  #         };
  #         "wwwrun" = {
  #           uid = 54;
  #           group = "wwwrun";
  #         };
  #       };
  #     };
  #     services = {
  #       resolved.enable = true;
  #       postgresql = {
  #         package = pkgs.postgresql_15;
  #         # settings.port = 5433;
  #         enableTCPIP = true;
  #         enable = true;
  #         settings = {
  #           ssl_cert_file = "/etc/postgresql/server.crt";
  #           ssl_key_file = "/etc/postgresql/server.key";
  #           ssl_ca_file = "/etc/postgresql/root.crt";
  #         };
  #       };
  #     };
  #   };
  # };
  containers.key = {
    bindMounts = {
      "/var/lib/acme/key.lesgrandsvoisins.com/" = {
        hostPath = "/var/lib/acme/key.lesgrandsvoisins.com/";
        isReadOnly = true;
      };
      "/etc/resolv.conf" = {
        hostPath = "/etc/resolv.conf";
        isReadOnly = true;
      };
    };
    autoStart = true;
    privateNetwork = true;
    # # macvlans = [
    # #   "eno1"
    # # ];
    # # hostBridge = "brkey";

    hostAddress = "192.168.105.10";
    localAddress = "192.168.105.11";
    hostAddress6 = "fa01::1";
    localAddress6 = "fa01::2";
    # hostAddress6 = "2a01:4f8:241:4faa::10";
    # localAddress6 = "2a01:4f8:241:4faa::11";

    # forwardPorts = [
    #   {
    #     containerPort = 443;
    #     hostPort = 443;
    #     protocol = "tcp";
    #   }
    #   {
    #     containerPort = 80;
    #     hostPort = 80;
    #     protocol = "tcp";
    #   }
    # ];
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      # networking.extraHosts =
      #   ''
      #     192.168.105.11 key-postgres
      #   '';
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
        postgresql_15
        # inetutils
      ];
      # virtualisation.docker.enable = true;
      system.stateVersion = "25.11";
      nix.settings.experimental-features = "nix-command flakes";
      networking = {
        useNetworkd = true;
        firewall = {
          enable = false;
          allowedTCPPorts = [443 587 14443];
        };
        useHostResolvConf = lib.mkForce false;
        nameservers = ["192.168.105.10"];
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
            members = ["acme" "wwwrun" "keycloak"];
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
        resolved = {
          enable = true;
          extraConfig = ''
            nameserver 192.168.105.10
            nameserver 1.1.1.1
          '';
        };

        postgresql.package = pkgs.postgresql_15;
        # postgresql.settings.port = 5433;
        postgresql.enableTCPIP = true;
        keycloak = {
          enable = true;
          database = {
            username = "key";
            # name="key"; # I think the database is keycloak and not key
            # passwordFile="/etc/.secrets.key";
            passwordFile = "/etc/.secrets.key";
            # createLocally=false;
            # createLocally=true;
            host = "localhost";
            # host="/run/postgresql";
            # useSSL = false;
            # useSSL = true;
            # port = 5433;
            # caCert = "/etc/postgresql/root.crt";
          };
          settings = {
            https-port = 14443;
            http-port = 14080;
            # https-port = 443;
            # http-port = 80;
            # http-host = "192.168.105.11"; # chris2fr 2025-11-30
            # http-host = "2a01:4f8:241:4faa::11";

            # proxy = "passthrough";
            # proxy = "reencrypt";
            # proxy-protocol-enabled = "true";
            proxy-headers = "xforwarded";
            hostname = "key.lesgrandsvoisins.com";
            # https-certificate-file = lib.mkForce "/var/lib/acme/key.lesgrandsvoisins.com/fullchain.pem";
            # https-certificate-key-file = lib.mkForce "/var/lib/acme/key.lesgrandsvoisins.com/key.pem";
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
