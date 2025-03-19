{ config, pkgs, lib, ... }:
let
in
{
  containers.discourseparis14cc = {
    bindMounts = {
      "/var/lib/acme/discourse.paris14.cc/" = {
        hostPath = "/var/lib/acme/discourse.paris14.cc/";
        isReadOnly = true;
      };
      # "/run/discourse/sockets/unicorn.sock"
    };
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.111.10";
    localAddress = "192.168.111.11";
    hostAddress6 = "fe11::1";
    localAddress6 = "fe11::2";
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
        # postgresql_17
        git
        lynx
      ];
      nixpkgs.config.permittedInsecurePackages = [
        "discourse-3.2.5"
      ];
      virtualisation.docker.enable = true;
      system.stateVersion = "24.11";
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
            members = [ "acme" ];
          };
          "wwwrun" = {
            gid = 54;
            members = [ "nginx" "discourse" ];
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
        resolved.enable = true;
        nginx.virtualHosts."discourse.paris14.cc" = {
          sslCertificate = "/var/lib/acme/discourse.paris14.cc/full.pem";
          sslCertificateKey = "/var/lib/acme/discourse.paris14.cc/key.pem";
          locations."/" = {
            proxyPass = "http://unix:/var/discourse/shared/standalone/nginx.http.sock";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_http_version 1.1;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_ssl_trusted_certificate /var/lib/acme/discourse.paris14.cc/full.pem;
              proxy_ssl_verify off;
            '';
          };
        };
        discourse = {
          enable = true;
          hostname = "discourse.paris14.cc";
          sslCertificate = "/var/lib/acme/discourse.paris14.cc/full.pem";
          sslCertificateKey = "/var/lib/acme/discourse.paris14.cc/key.pem";
          siteSettings = {
            security.forceHttps = true;
          };
          enableACME = false;
          plugins = [
            config.services.discourse.package.plugins.discourse-openid-connect
            # config.services.discourse.package.plugins.discourse-oauth2-basic
            # config.services.discourse.package.plugins.discourse-saml
          ];
          admin = {
            email = "paris14ccadmin@lesgrandsvoisins.com";
            fullName = "Super Admin";
            username = "paris14ccadmin";
            passwordFile = "/etc/discourse/.paris14ccadmin";
          };
          mail = {
            outgoing = {
              serverAddress = "mail.lesgrandsvoisins.com";
              authentication = "plain";
              username = "list@lesgrandsvoisins.com";
              passwordFile = "/etc/.secrets.listlesgrandsvoisins";
              port = 587;
              forceTLS = true;
              # opensslVerifyMode = "none";
            };
          };
        };
        postgresql = {
          enable = true;
          package = pkgs.postgresql_13;
        };
      };
    };
  };
}
