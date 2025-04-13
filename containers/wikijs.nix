{ config, pkgs, lib, ... }:
let
in
{
  containers.wikijs = {
    # bindMounts = {
    #   "/var/lib/acme/keycloak.paris14.cc/" = {
    #     hostPath = "/var/lib/acme/keycloak.paris14.cc/";
    #     isReadOnly = true;
    #   };
    # };
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.112.10";
    localAddress = "192.168.112.11";
    hostAddress6 = "fa11::1";
    localAddress6 = "fa11::2";
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
      ];
      # virtualisation.docker.enable = true;
      system.stateVersion = "24.11";
      nix.settings.experimental-features = "nix-command flakes";
      networking = {
        firewall = {
          enable = false;
          allowedTCPPorts = [ 443 587 14445 ];
        };
        useHostResolvConf = lib.mkForce false;
      };
      systemd.tmpfiles.rules = [
        # "f /etc/.secret.keycloackparis14ccdata 0660 root root"
        "d /etc/wikijs/ 0750 root root"
        "f /etc/wikijs/.env 0660 root root"
        # "d /var/lib/acme/keycloak.paris14.cc/ 0750 acme wwwrun"
        # "f /etc/.secret.keycloackparis14cc 0660 keycloak postgres"
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
          "wikijs" = {
            isNormalUser = true;
          };
        };
      };
      services = {
        resolved.enable = true;
        # postgresql = {
        #   package = pkgs.postgresql_17;
        #   enable = true;
        #   ensureUsers = [{
        #     name = "keyparis14cc";
        #     ensureDBOwnership = true;
        #   }];
        #   ensureDatabases = ["keyparis14cc"];
        # };
        wiki-js = {
          enable = true;
          environmentFile = "/etc/wikijs/.env";
          settings.db = {
            host = "/run/postgresql";
            db = "wikijsconfigmagic";
            user = "wikijsconfigmagic";
          };
        };
        postgresql = {
          enable = true;
          ensureUsers = [{name="wikijsconfigmagic";ensureDBOwnership=true;}{name="wwwrun";}];
          ensureDatabases = ["wikijsconfigmagic"];
          enableTCPIP = true;
        };
      };
      systemd.services.wiki-js.serviceConfig.User = "wwwrun";
    };
  };
}
