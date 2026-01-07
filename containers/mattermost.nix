{
  config,
  pkgs,
  lib,
  ...
}: let
in {
  containers.mm = {
    bindMounts = {
      "/var/lib/acme/mm.lgv.info/" = {
        hostPath = "/var/lib/acme/mm.lgv.info/";
        isReadOnly = true;
      };
      # "/run/discourse/sockets/unicorn.sock"
    };
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.119.10";
    localAddress = "192.168.119.11";
    hostAddress6 = "fe19::1";
    localAddress6 = "fe19::2";
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
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
        # postgresql_17
        git
        lynx
        # mattermostLatest
      ];
      # nixpkgs.config.permittedInsecurePackages = [
      #   "discourse-3.2.5"
      #   "discourse-3.4.7"
      #   "discourse-3.5.0"
      # ];
      # virtualisation.docker.enable = true;
      system.stateVersion = "25.11";
      nix.settings.experimental-features = "nix-command flakes";
      networking = {
        firewall.enable = false;
        # firewall = {
        #   enable = true;
        #   allowedTCPPorts = [ 80 443 ];
        # };
        # Use systemd-resolved inside the container
        useHostResolvConf = lib.mkForce false;
      };
      security.acme.acceptTerms = true;
      # users.users = {
      #   "discourse" = {
      #     createHome = true;
      #   };
      # };
      users = {
        groups = {
          "acme" = {
            gid = 993;
            members = ["acme"];
          };
          "wwwrun" = {
            gid = 54;
            members = ["nginx" "mattermost" "wwwrun"];
          };
          "mattermost" = {
            members = ["nginx" "wwwrun" "mattermost"];
          };
          # "discourse" = {
          #     members = [ "nginx" "discourse" "wwwrun" ];
          # };
        };
        users = {
          # "nodebb" = {
          #   isNormalUser = true;
          #   group = "nodebb";
          # };
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
        resolved.enable = true;
        mattermost = {
          enable = true;
          siteName = "MaterMost MM.LGV.INFO";
          host = "192.168.119.11";
          mutableConfig = true;
          siteUrl = "https://mm.lgv.info";
          plugins = [];
          settings = {};
        };
      };
    };
  };
}
