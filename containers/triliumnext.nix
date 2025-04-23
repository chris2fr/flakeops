{ config, pkgs, lib, ... }:
let
in
{
  containers.triliumnext = {
    bindMounts = {
      "/var/lib/acme/triliumnext.lesgv.com/" = {
        hostPath = "/var/lib/acme/triliumnext.lesgv.com/";
        isReadOnly = true;
      };
    };
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.118.10";
    localAddress = "192.168.118.11";
    hostAddress6 = "fc00::118:10";
    localAddress6 = "fc00::118:11";
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
        postgresql
        openssl
        nodejs_22
        yarn
        libpng
        libtool
        autoconf
        libgcc
        imagemagick
        gccStdenv
        gnumake
        distccWrapper
        coreutils-full
        libjpeg
        gettext
        sqlite
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
        # "f /etc/.secret.keycloaklesgvorgdata 0660 root root"
        "d /var/lib/acme/triliumnext.lesgv.com/ 0750 acme wwwrun"
        # "d /etc/postgresql/ 0750 postgres keycloak"
        # "f /etc/.secret.keycloaklesgvorg 0660 keycloak postgres"
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
            members = [ "acme" "wwwrun" "triliumnext"];
          };
          "triliumnext" = {
            members = [ "triliumnext" ];
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
          "triliumnext" = {
            group = "triliumnext";
            isNormalUser = true;
          };
        };
      };
      # systemd.services.postgresql.postStart = "cp -a ~postgres/server.crt /run/postgresql/server.crt";

      services = {
        resolved.enable = true;
        # postgresql = {
        # #   package = pkgs.postgresql_17;
        #   enable = true;
        #   enableTCPIP = true;
        #   settings = {
        #     ssl = true;
        #     ssl_cert_file = "/etc/postgres-server.crt";
        #   };
        #   ensureUsers = [{
        #     name = "keycloaklesgv";
        #     ensureDBOwnership = true;
        #   }];
        #   ensureDatabases = ["keycloaklesgv"];
        # };
      };
    };
  };
}
