{ config, pkgs, lib, ... }:
let
  # home-manager = builtins.fetchTarball { 
  #   url="https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz"; 
  #   sha256="sha256:00wp0s9b5nm5rsbwpc1wzfrkyxxmqjwsc1kcibjdbfkh69arcpsn"; 
  # };
  # home-manager = import ../vars/home-manager.nix;
  mannchriRsaPublic = import ../vars/mannchri-rsa-public.nix;
in
{
  containers.wordpress = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.103.1";
    localAddress = "192.168.103.2";
    hostAddress6 = "fc00::3:1";
    localAddress6 = "fc00::3:2";
    bindMounts = {
      "/var/lib/acme/wordpress.resdigita.com/" = {
        hostPath = "/var/lib/acme/wordpress.resdigita.com/";
        isReadOnly = true;
      };
    };
    config = { config, pkgs, lib, ... }: {
      # imports = [ (import "${home-manager}/nixos") ];
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
        cowsay
        # home-manager
        curl
        wget
        lynx
        git
        tmux
        bat
        python311Packages.pillow
        python311Packages.pylibjpeg-libjpeg
        zlib
        lzlib
        dig
        killall
        pwgen
        openldap
        mysql80
        python311Packages.pypdf2
        python311Packages.python-ldap
        python311Packages.pq
        python311Packages.aiosasl
        python311Packages.psycopg2
        mariadb
        (pkgs.php82.buildEnv {
          extensions = ({ enabled, all }: enabled ++ (with all; [
            imagick
          ]));
          extraConfig = ''
          '';
        })
        php82Extensions.imagick
      ];
      networking = {
        hostName = "wordpress";
        firewall.allowedTCPPorts = [ 22 25 80 443 143 587 993 995 636 ];
        useHostResolvConf = lib.mkForce false;
      };
      system = {
        # copySystemConfiguration = true;
        stateVersion = "24.11";
      };
      environment.sessionVariables = rec {
        EDITOR = "vim";
        WAGTAIL_ENV = "production";
      };
      security.acme = {
        acceptTerms = true;
        defaults.email = "contact@lesgrandsvoisins.com";
        defaults.webroot = "/var/www";
      };
      # ## Adding Linux Containers
      # virtualisation = {
      #   lxd.enable = true;
      #   lxc.enable = true;
      #   lxc.lxcfs.enable = true;
      # };
      time.timeZone = "Europe/Paris";
      i18n.defaultLocale = "fr_FR.UTF-8";
      users.users.mannchri = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
        extraGroups = [ "wheel" ];
      };
      # home-manager.users.mannchri = {pkgs, ...}: {
      #   home.packages = [ pkgs.atool pkgs.httpie ];
      #   home.stateVersion = "24.11";
      #   programs.home-manager.enable = true;
      #   programs.vim = {
      #     enable = true;
      #     plugins = with pkgs.vimPlugins; [ vim-airline ];
      #     settings = { ignorecase = true; tabstop = 2; };
      #     extraConfig = ''
      #       set mouse=a
      #       set nocompatible
      #       colo torte
      #       syntax on
      #       set tabstop     =2
      #       set softtabstop =2
      #       set shiftwidth  =2
      #       set expandtab
      #       set autoindent
      #       set smartindent
      #     '';
      #   };
      # };
      services = {
        resolved.enable = true;
        openssh = {
          enable = true;
          settings.PermitRootLogin = "prohibit-password";
        };
        httpd = {
          enable = true;
          enablePHP = true;
          phpPackage = pkgs.php.buildEnv {
            extensions = ({ enabled, all }: enabled ++ (with all; [
              imagick
            ]));
            extraConfig = ''
            '';
          };
          phpOptions = ''
            upload_max_filesize = 128M
            post_max_size = 256M
            max_execution_time = 300
          '';
          virtualHosts."wordpress.resdigita.com" = {
            serverAliases = [
              "ghh.resdigita.com"
              "*"
            ];
            listen = [{ port = 443; ssl = true; }];
            sslServerCert = "/var/lib/acme/wordpress.resdigita.com/fullchain.pem";
            sslServerChain = "/var/lib/acme/wordpress.resdigita.com/fullchain.pem";
            sslServerKey = "/var/lib/acme/wordpress.resdigita.com/key.pem";
            # enableACME = true;
            # forceSSL = true;
            documentRoot = "/var/www/ghh";
            extraConfig = ''
              <Directory /var/www/ghh>
                DirectoryIndex index.php
                Require all granted
                AllowOverride FileInfo
                FallbackResource /index.php
              </Directory>
            '';
          };
        };
        mysql = {
          package = pkgs.mariadb;
          enable = true;
        };
      };
    };
  };
}
