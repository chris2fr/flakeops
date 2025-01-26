  # containers.sftpgo = {
  #   autoStart = true;
  #   privateNetwork = true;
  #   hostAddress = "192.168.108.1";
  #   localAddress = "192.168.108.2";
  #   hostAddress6 = "fc00::4:1";
  #   localAddress6 = "fc00::4:2"; 
  #   # bindMounts = {
  #   #   "/var/lib/acme/sftpgo.lesgrandsvoisins.com/" = {
  #   #     hostPath = "/var/lib/acme/wordpress.resdigita.com/";
  #   #     isReadOnly = true;
  #   #   }; 
  #   #   "/var/www/dav/data/" = {
  #   #     hostPath = "//var/www/dav/data/";
  #   #     isReadOnly = false;
  #   #   }; 
  #   #   "/var/run/sftpgo/" = {
  #   #     hostPath = "/var/run/sftpgo/";
  #   #     isReadOnly = false;
  #   #   }; 
  #   # };
  #   config = { config, pkgs, lib, ... }: {
  #     nix.settings.experimental-features = "nix-command flakes";
  #     # imports = [ (import "${home-manager}/nixos") ];
  #     environment.systemPackages = with pkgs; [
  #       ((vim_configurable.override {  }).customize{
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
  #         }
  #       )
  #     ];
  #     # users = {
  #     #   users = {
  #     #     sftpgo = {
  #     #       uid = 1020;
  #     #       group = "sftpgo";
  #     #     };
  #     #   };
  #     #   groups = {
  #     #     sftpgo = {
  #     #       gid = 979;
  #     #       name = "sftpgo";
  #     #     };
  #     #     wwwrun = {
  #     #       gid = 54;
  #     #       members = ["wwwrun"];
  #     #     };
  #     #   };
  #     # };
  #     nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
  #       "sftpgo"
  #     ];
  #     networking = {
  #       hostName = "sftpgo"; 
  #       firewall.allowedTCPPorts = [ 22 25 80 443 143 587 993 995 636 ];
  #       useHostResolvConf = lib.mkForce false;
  #     };
  #     system = {
  #       # copySystemConfiguration = true;
  #       stateVersion = "24.11";
  #     };
  #     time.timeZone = "Europe/Paris";
  #     i18n.defaultLocale = "fr_FR.UTF-8";  
  #     environment.sessionVariables = rec {
  #       EDITOR="vim";
  #     };
  #     services = {
  #       resolved.enable = true;
  #       openssh = {
  #         enable = true;
  #         settings.PermitRootLogin = "prohibit-password";
  #       };
  #       sftpgo = {
  #         enable = true;
  #         user = "sftpgo";  
  #         group = "wwwrun";
  #         dataDir = "/var/www/dav/data";
  #         extraArgs = [
  #             "--log-level"
  #             "info"
  #           ];
  #         settings = {
  #           proxy_protocol = 0;
  #           webdavd.bindings = [
  #             {
  #               port = 80;
  #               address = "192.168.108.2";
  #               # certificate_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/full.pem";
  #               # certificate_key_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/key.pem";
  #               # enable_https = true;
  #             }
  #             {
  #               port = 80;
  #               address = "[fc00::4:2]";
  #               # certificate_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/full.pem";
  #               # certificate_key_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/key.pem";
  #               # enable_https = true;
  #             }
  #           ];
  #           sftpd.bindings = [
  #             {
  #               port = 2022;
  #               address = "192.168.108.2";
  #             }
  #             {
  #               port = 2022;
  #               address = "[fc00::4:2]";
  #             }
  #           ];
  #           httpd = {
  #             static_files_path = "/var/run/sftpgo/static";
  #             templates_path = "/var/run/sftpgo/templates";
  #             bindings = [
  #             {
  #               port = 80;
  #               address = "192.168.108.2";
  #               # certificate_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/full.pem";
  #               # certificate_key_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/key.pem";
  #               # enable_https = true;
                

  #               # oidc = {
  #               #   config_url = "https://key.lesgrandsvoisins.com/realms/master";
  #               #   client_id = "sftpgo";
  #               #   client_secret = keySftpgo;
  #               #   username_field = "username";
  #               #   redirect_base_url = "https://sftpgo.lesgrandsvoisins.com:10443";
  #               #   scopes = [
  #               #     "openid"
  #               #     "profile"
  #               #     "email"        
  #               #   ];
  #               #   implicit_roles = true;
  #               # };
  #               branding = {
  #                 web_admin = {
  #                   name = "sftpgo.lesgrandsovisins.com : Accès Administrateur au Drive des Grands Voisins";
  #                   short_name = "ADMIN du Drive des Grands Voisins";
  #                 };
  #                 web_client = {
  #                   name = "sftpgo.lesgrandsovisins.com : Accès au Drive des Grands Voisins";
  #                   short_name = "Drive des Grands Voisins";
  #                 };
  #               };
  #             }
  #             {
  #               port = 80;
  #               address = "[fc00::4:2]";
  #               # certificate_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/full.pem";
  #               # certificate_key_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/key.pem";
  #               # enable_https = true;
  #               # oidc = {
  #               #   config_url = "https://key.lesgrandsvoisins.com/realms/master";
  #               #   client_id = "sftpgo";
  #               #   client_secret = keySftpgo;
  #               #   redirect_base_url = "https://sftpgo.lesgrandsvoisins.com:10443";
  #               #   username_field = "username";
  #               #   scopes = [
  #               #     "openid"
  #               #     "profile"
  #               #     "email"
  #               #   ];
  #               #   implicit_roles = true;
  #               # };
  #               branding = {
  #                 web_admin = {
  #                   name = "sftpgo.lesgrandsovisins.com : Accès Administrateur au Drive des Grands Voisins";
  #                   short_name = "ADMIN du Drive des Grands Voisins";
  #                 };
  #                 web_client = {
  #                   name = "sftpgo.lesgrandsovisins.com : Accès au Drive des Grands Voisins";
  #                   short_name = "Drive des Grands Voisins";
  #                 };
  #               };
  #             }
  #           ];
  #           };
  #           plugins = [{
  #             type = "auth";
  #             cmd = "/run/current-system/sw/bin/sftpgo-plugin-auth";
  #             args = ["serve"
  #               "--config-file"
  #               "/var/run/sftpgo/sftpgo-plugin-auth.json"
  #             ];
  #             auth_options.scope = 5;
  #             auto_mtls = true;
  #           }];
  #         };  
  #       };
  #     };
  #   };
  # };