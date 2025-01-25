{ config, pkgs, lib, ... }:
let 
in{
    services.sftpgo = {
      enable = false;
      user = "sftpgo";  
      group = "wwwrun";
      dataDir = "/var/www/dav/data";
      # extraArgs = [
      #   "--log-level"
      #   "info"
      # ];
      settings = {
        # proxy_protocol = 1;
        # proxy_allowed = ["116.202.236.241" "2a01:4f8:241:4faa::" "2a01:4f8:241:4faa::1" "2a01:4f8:241:4faa::2"];
        # acme = {
        #   domains = ["sftpgo.lesgrandsvoisins.com"];
        #   email = "chris@mann.fr";
        #   key_type =  "4096";
        #   certs_path =  "/var/lib/acme/sftpgo.lesgrandsvoisins.com";
        #   ca_endpoint =  "https://acme-v02.api.letsencrypt.org/directory";
        #   renew_days =  30;
        #   http01_challenge =  {
        #     port =  10080;
        #     proxy_header =  "";
        #     webroot =  "/var/www/sftpgo.com";
        #   };
        #   tls_alpn01_challenge =  {
        #     port =  0;
        #   };
        # };
        webdavd.bindings = [
          # {
          #   port = 14443;
          #   address = "116.202.236.241";
          #   certificate_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/full.pem";
          #   certificate_key_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/key.pem";
          #   enable_https = true;
          # }
          {
            port = 443;
            address = "[2a01:4f8:241:4faa::9]";
            certificate_file = "/var/lib/acme/9.lesgrandsvoisins.com/full.pem";
            certificate_key_file = "/var/lib/acme/9.lesgrandsvoisins.com/key.pem";
            enable_https = true;
          }
        ];
        sftpd.bindings = [
          # {
          #   port = 2022;
          #   address = "116.202.236.241";
          # }
          {
            port = 2022;
            address = "[2a01:4f8:241:4faa::8]";
          }
        ];
        httpd = {
          static_files_path = "/var/run/sftpgo/static";
          templates_path = "/var/run/sftpgo/templates";
          bindings = [
          # {
          #   port = 10443;
          #   address = "116.202.236.241";
          #   certificate_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/full.pem";
          #   certificate_key_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/key.pem";
          #   enable_https = true;
          #   enabled_login_methods = 3;
          #   oidc = {
          #     config_url = "https://key.lesgrandsvoisins.com/realms/master";
          #     client_id = "sftpgo";
          #     client_secret = keySftpgo;
          #     username_field = "username";
          #     redirect_base_url = "https://sftpgo.lesgrandsvoisins.com";
          #     # redirect_base_url = "https://sftpgo.lesgrandsvoisins.com:10443";
          #     scopes = [
          #       "openid"
          #       "profile"
          #       "email"
          #     ];
          #     implicit_roles = true;
          #   };
          #   branding = {
          #     web_admin = {
          #       name = "sftpgo.lesgrandsovisins.com : Accès Administrateur au Drive des Grands Voisins";
          #       short_name = "ADMIN du Drive des Grands Voisins";
          #     };
          #     web_client = {
          #       name = "sftpgo.lesgrandsovisins.com : Accès au Drive des Grands Voisins";
          #       short_name = "Drive des Grands Voisins";
          #     };
          #   };
          # }
          {
            port = 443;
            address = "[2a01:4f8:241:4faa::8]";
            certificate_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/full.pem";
            certificate_key_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/key.pem";
            enable_https = true;
            enabled_login_methods = 7;
            # enabled_login_methods = 3;
            oidc = {
              config_url = "https://key.lesgrandsvoisins.com/realms/master";
              client_id = "sftpgo";
              client_secret_file = config.age.secrets."key.sftpgo".path;
              username_field = "preferred_username";
              redirect_base_url = "https://sftpgo.lesgrandsvoisins.com";
              # redirect_base_url = "https://sftpgo.lesgrandsvoisins.com:10443";
              scopes = [
                "openid"
                "profile"
                "email"
              ];
              role_field = "resource_access.sftpgo.roles";
              implicit_roles = true;
              # implicit_roles = true;
            };
            branding = {
              web_admin = {
                name = "sftpgo.lesgrandsovisins.com : Accès Administrateur au Drive des Grands Voisins";
                short_name = "ADMIN du Drive des Grands Voisins";
              };
              web_client = {
                name = "sftpgo.lesgrandsovisins.com : Accès au Drive des Grands Voisins";
                short_name = "Drive des Grands Voisins";
              };
            };
          }
        ];
        };
        data_provider = {
          # driver = "postgresql";
          # name = "sftpgo";
          # host = "localhost";
          # port = "5432";
          # username = "sftpgo";
          # password = $passwordDBSFTPGO;
          # pre_login_hook = "/run/addsftpgouser.sh";
        };
        plugins = [{
          type = "auth";
          cmd = "/run/current-system/sw/bin/sftpgo-plugin-auth";
          args = ["serve"
            "--config-file"
            "/var/run/sftpgo/sftpgo-plugin-auth.json"
          ];
          auth_options.scope = 5;
          auto_mtls = true;
        }];
      };  
    };
}