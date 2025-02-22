{ config, pkgs, lib, ... }:
let
in
{
  containers.discourse = {
    bindMounts = {
      "/var/lib/acme/discourse.village.ngo/" = {
        hostPath = "/var/lib/acme/discourse.village.ngo/";
        isReadOnly = true;
      };
      # "/run/discourse/sockets/unicorn.sock"
    };
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.104.10";
    localAddress = "192.168.104.11";
    hostAddress6 = "fe00::1";
    localAddress6 = "fe00::2";
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
        # postgresql_13
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
        nginx.virtualHosts."discourse.village.ngo" = {
          sslCertificate = "/var/lib/acme/discourse.village.ngo/full.pem";
          sslCertificateKey = "/var/lib/acme/discourse.village.ngo/key.pem";
          locations."/" = {
            proxyPass = "http://unix:/var/discourse/shared/standalone/nginx.http.sock";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_http_version 1.1;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_ssl_trusted_certificate /var/lib/acme/discourse.village.ngo/full.pem;
              proxy_ssl_verify off;
            '';
          };
        };
        discourse = {
          enable = true;
          hostname = "discourse.village.ngo";
          sslCertificate = "/var/lib/acme/discourse.village.ngo/full.pem";
          sslCertificateKey = "/var/lib/acme/discourse.village.ngo/key.pem";
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
            email = "gv@village.ngo";
            fullName = "Super Admin";
            username = "admin";
            passwordFile = "/etc/discourse/.admin";
          };
          mail = {
            outgoing = {
              serverAddress = "mail.lesgrandsvoisins.com";
              authentication = "plain";
              username = "gv@village.ngo";
              passwordFile = "/etc/.secrets.gvvillagengo";
              # port = 587;
              # forceTLS = true;
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
