{
  config,
  pkgs,
  lib,
  ...
}: let
  nginxLocationWagtailExtraConfig = ''
    proxy_redirect off;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    # proxy_http_version 1.1;
    proxy_set_header Host $host;
    # proxy_set_header Upgrade $http_upgrade;
    # proxy_set_header Connection $connection_upgrade_keepalive;
  '';
  nginxSsoProxExtraConfig = ''

      proxy_set_header X-Origin-URI $request_uri;
      proxy_set_header X-Host $host;
      # proxy_set_header X-Real-IP $remote_addr;
      # proxy_set_header REMOTE_ADDR $remote_addr;
      # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_redirect off;
      # proxy_redirect default;
      proxy_http_version 1.1;
      proxy_set_header   Upgrade $http_upgrade;
      proxy_set_header   Connection "upgrade";
      proxy_read_timeout 90;

      proxy_set_header  X-Url-Scheme $scheme;

      proxy_set_header X-Forwarded-Host $host;
      proxy_set_header X-Forwarded-Server $host;


    # # Set custom information for ACL matching: Each one is available as
    # # a field for matching: X-Host = x-host, ...
    # proxy_set_header X-Origin-URI $request_uri;
    # proxy_set_header X-Host $host;
    # proxy_set_header X-Real-IP $remote_addr;
    # # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    # proxy_set_header X-Forwarded-For $remote_addr;
    # proxy_set_header X-Forwarded-Proto $scheme;
    # # # Extra
    # # proxy_set_header X-Application "nsso";
    # # proxy_redirect    off;
    # # proxy_max_temp_file_size 0;
    # # proxy_set_header  X-Url-Scheme $scheme;
  '';
  nginxSsoLocations = {
    "/".extraConfig = ''
      #   # Protect this location using the auth_request
        auth_request /sso-auth;

        ## Optionally set a header to pass through the username
        auth_request_set $username $upstream_http_x_username;
        proxy_set_header X-User $username;

        # Automatically renew SSO cookie on request
        auth_request_set $cookie $upstream_http_set_cookie;
        add_header Set-Cookie $cookie;

          proxy_set_header X-Origin-URI $request_uri;
          proxy_set_header X-Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          # proxy_set_header X-Forwarded-For $remote_addr;
          proxy_set_header X-Forwarded-Proto $scheme;
    '';
    "/logout".extraConfig = ''
      # Another server{} directive also proxying to http://[::1]:8082
      return 302 https://login.gdvoisins.com/logout?go=$scheme://$host/;
    '';
    "/sso-auth" = {
      proxyPass = "https://login.gdvoisins.com/auth";
      # proxyPass = "http://[::1]:8082/auth";
      # proxyPass = "http://[::1]:8082/auth";
      extraConfig = ''
        # Do not allow requests from outside
        # internal;
        # # Access /auth endpoint to query login state
        # proxy_pass http://[::1]:8082/auth;
        # Do not forward the request body (nginx-sso does not care about it)
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";

        proxy_set_header X-Origin-URI $request_uri;
        proxy_set_header X-Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header REMOTE_ADDR $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
        # proxy_redirect default;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection "upgrade";
        proxy_read_timeout 90;

        proxy_set_header  X-Url-Scheme $scheme;

        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Server $host;


        # proxy_ssl_verify off;





        # Set custom information for ACL matching: Each one is available as
        # a field for matching: X-Host = x-host, ...
        # proxy_set_header X-Origin-URI $request_uri;
        # proxy_set_header X-Host $host;
        # proxy_set_header X-Real-IP $remote_addr;
        ## proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        # proxy_set_header X-Forwarded-For $remote_addr;
        # proxy_set_header X-Forwarded-Proto $scheme;
        # Extra
        # proxy_set_header X-Application "nsso";
        # proxy_redirect    off;
        # proxy_max_temp_file_size 0;
        # proxy_set_header  X-Url-Scheme $scheme;

      '';
    };
    # "/login" = {
    #   proxyPass = "http://[::1]:8082/login";
    #   extraConfig = ''
    #     proxy_set_header X-Origin-URI $request_uri;
    #     proxy_set_header X-Host $host;
    #     # proxy_set_header X-Real-IP $remote_addr;
    #     # proxy_set_header REMOTE_ADDR $remote_addr;
    #     # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #     proxy_set_header X-Forwarded-Proto $scheme;
    #     proxy_redirect off;
    #     # proxy_redirect default;
    #     proxy_http_version 1.1;
    #     proxy_set_header   Upgrade $http_upgrade;
    #     proxy_set_header   Connection "upgrade";
    #     proxy_read_timeout 90;

    #     proxy_set_header  X-Url-Scheme $scheme;

    #     proxy_set_header X-Forwarded-Host $host;
    #     proxy_set_header X-Forwarded-Server $host;
    #   '';
    # };
    "@error401".extraConfig = ''
      # Another server{} directive also proxying to http://[::1]:8082
      return 302 https://login.gdvoisins.com/login?go=$scheme://$host$request_uri;
    '';
  };
in {
  imports = [
    ./nginx/authentik.nix
    ./nginx/crabfit.nix
    ./nginx/ghostio.nix
    ./nginx/guichet.nix
    ./nginx/hedgedoc.nix
    ./nginx/odoo.nix
    ./nginx/static.nix
    ./nginx/wagtail.nix
    ./nginx/webdav.nix
  ];
  users.users.nginx.group = "wwwrun";
  services = {
    nginx = {
      group = "wwwrun";
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      # defaultListenAddresses = ["127.0.0.1" "116.202.236.241" "[::1]"];
      defaultListenAddresses = ["127.0.0.1" "116.202.236.241" "[2a01:4f8:241:4faa::]" "[2a01:4f8:241:4faa::10]" "[::1]"];
      # defaultListen = [
      #   { addr = "116.202.236.241"; proxyProtocol = true;  }
      #   # { addr = "116.202.236.241";  }
      #   # { addr = "127.0.0.1"; port = 80; }
      #   # { addr = "[::1]"; port = 80; }
      #   { addr = "[2a01:4f8:241:4faa::]"; proxyProtocol = true;  }
      #   # { addr = "[2a01:4f8:241:4faa::10]"; proxyProtocol = true; ssl = true;  }
      #   # { addr = "[2a01:4f8:241:4faa::]";  }
      #   { addr = "0.0.0.0";  }
      #   { addr = "[::0]";  }
      # ];
      appendHttpConfig = ''
        proxy_headers_hash_max_size 16384;
        server_names_hash_max_size 16384;
        # server_names_hash_bucket_size: 64;
        proxy_headers_hash_bucket_size 512;
        proxy_buffer_size   256k;
        proxy_buffers   4 256k;
        proxy_busy_buffers_size   256k;
        # Upgrade WebSocket if requested, otherwise use keepalive
        map $http_upgrade $connection_upgrade_keepalive {
            default upgrade;
        }
      '';
      upstreams = {
        "authentik" = {
          extraConfig = ''
            server 10.245.101.35:9000;
            # Improve performance by keeping some connections alive.
            keepalive 10;
          '';
        };
        "wagtailstatic".servers = {"10.245.101.15:8888" = {};};
        "wagtailmedia".servers = {"10.245.101.15:8889" = {};};
        # "keylesgrandsvoisinscom".servers = {""};
        # "main-relay".servers = { "116.202.236.241:12443" = { }; };
        # "noproxy-relay".servers = { "116.202.236.241:12444" = { }; };
        # "proxy-relay".servers = { "116.202.236.241:12444" = { }; };
        # "main-relay6".servers = { "[2a01:4f8:241:4faa::]:12443" = { }; };
        # "noproxy-relay6".servers = { "[2a01:4f8:241:4faa::]:12444" = { }; };
        # "proxy-relay6".servers = { "[2a01:4f8:241:4faa::]:12444" = { }; };
      };
      sso = {
        enable = true;
        configuration = {
          acl = {
            rule_sets = [
              {
                rules = null;
                allow = [
                  "chris"
                ];
              }
            ];
          };
          audit_log = {
            events = [
              "access_denied"
              "login_success"
              "login_failure"
              "logout"
              "validate"
            ];
            headers = [
              "x-origin-uri"
            ];
            targets = [
              "fd://stdout"
              "file:///var/lib/nginx-sso/audit.jsonl"
            ];
            trusted_ip_headers = [
              "X-Forwarded-For"
              "RemoteAddr"
              "X-Real-IP"
            ];
          };
          cookie = {
            authentication_key = "Ff1uWJcLouKu9kwxgbnKcU3ps47gps72sxEz79TGHFCpJNfeew66FDisM4MWbstH";
            domain = ".gdvoisins.com";
          };
          listen = {
            addr = "127.0.0.1";
            port = 8082;
          };
          login = {
            default_method = "oidc";
            default_redirect = "https://login.gdvoisins.com/login";
            names = {
              oidc = "OIDC avec Key Lesgrandsvoisins Com";
            };
            title = "key lesgrandsvoisins com";
          };
          plugins = {
            directory = "/var/lib/nginx-sso/plugins/";
          };
          providers = {
            oidc = {
              client_id = "nsso";
              client_secret = "tnyynKSrchCcAXxrDmGbTStmBMPJXlWf";
              issuer_name = "Key.Lesgrandsvoisins.com";
              issuer_url = "https://key.lesgrandsvoisins.com/realms/master";
              redirect_url = "https://login.gdvoisins.com/login";
              # Optional, defaults to no limitations
              # require_domain = "gdvoisins.com";
              # Optional, defaults to "subject"
              # user_id_method = "username";
            };
          };
        };
      };
      virtualHosts = {
        # "oauth.gdvoisins.com" = {
        #   forceSSL = true;
        #   enableACME = true;
        #   root = "/var/www/html";
        # };
        # services.acme-dns = {
        #   enable = true;

        # };

        # "keycloak.gdvox.com" = {
        #   listen = [
        #     {addr = "116.202.236.241"; port = 444 ; ssl = true; proxyProtocol = true; }
        #     {addr = "[2a01:4f8:241:4faa::]"; port = 444 ; ssl = true; proxyProtocol = true; }
        #     ];
        #   sslCertificate = "/var/lib/acme/keycloak.gdvox.com/fullchain.pem";
        #   sslCertificateKey = "/var/lib/acme/keycloak.gdvox.com/key.pem";
        #   locations."/" = {
        #     proxyPass = "";
        #     extraConfig = ''
        #       real_ip_header proxy_protocol;
        #       set_real_ip_from 192.168.115.10/24;  # Where HAProxy lives
        #     '';
        #   };
        # };

        "protection.gdvoisins.com" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/html";
          extraConfig = ''
            # proxy_protocol off;
            # Redirect the user to the login page when they are not logged in
            error_page 401 = @error401;
            # Protect this server using the auth_request
            auth_request /sso-auth;
          '';
          locations = nginxSsoLocations;
        };
        "login.gdvoisins.com" = {
          extraConfig = "# proxy_protocol off;";
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            # proxyPass = "http://[::1]:8082";
            # proxyPass = "http://127.0.0.1:8082";
            proxyPass = "https://login.gdvoisins.com:41443";
            extraConfig = ''
              proxy_set_header X-Origin-URI $request_uri;
              proxy_set_header X-Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

              auth_request_set $cookie $upstream_http_set_cookie;
              add_header Set-Cookie $cookie;

              add_header Cache-Control 'no-cache';
              proxy_no_cache 1;
              proxy_cache_bypass 1;
            '';
            # extraConfig = nginxSsoProxExtraConfig;
          };
          # locations = {
          #   "/login" = {
          #     proxyPass = "http://[::1]:8082/login";
          #     extraConfig = nginxSsoProxExtraConfig;
          #   };
          #   "/logout" = {
          #     proxyPass = "http://[::1]:8082/logout";
          #     extraConfig = nginxSsoProxExtraConfig;
          #   };
          #   # "/auth" = {
          #   #   proxyPass = "http://[::1]:8082/auth";
          #   #   extraConfig = nginxSsoProxExtraConfig;
          #   # };
          # };
        };
        "nsso.gdvoisins.com" = {
          forceSSL = true;
          enableACME = true;
          extraConfig = ''
            # proxy_protocol off;
            # Redirect the user to the login page when they are not logged in
            error_page 401 = @error401;
            ## Protect this server using the auth_request
            # auth_request /sso-auth;
          '';
          root = "/var/www/html/";
          locations = nginxSsoLocations;
        };
        "triliumnext.lesgv.com" = {
          serverAliases = [
            "notes.lesgv.com"
            "note.lesgv.com"
          ];
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            extraConfig = ''
              proxy_pass https://192.168.118.11:8080;
              proxy_set_header Host "triliumnext.lesgv.com";
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host "triliumnext.lesgv.com";
              proxy_set_header X-Forwarded-Proto "https";
              proxy_set_header X-Scheme $scheme;
              proxy_redirect default;
              # proxy_redirect http://127.0.0.1:8080 https://trilium.lesgv.com; # change them based on your IP, port and domain
              proxy_http_version 1.1;
              proxy_set_header   Upgrade $http_upgrade;
              proxy_set_header   Connection "upgrade";
              proxy_read_timeout 90;
              # add_header Content-Security-Policy "frame-src *; frame-ancestors *; object-src *;";
              # add_header Access-Control-Allow-Credentials true;
              if ($host != "triliumnext.lesgv.com") {
                return 302 $scheme://triliumnext.lesgv.com$request_uri;
              }
              proxy_ssl_verify off;
            '';
          };
        };
        "triliumnext.mann.fr" = {
          # serverAliases = ["notes.mann.fr" "note.mann.fr"];
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            extraConfig = ''
              proxy_pass https://192.168.118.11:8443;
              proxy_set_header Host "triliumnext.mann.fr";
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host "triliumnext.mann.fr";
              proxy_set_header X-Forwarded-Proto "https";
              proxy_set_header X-Scheme $scheme;
              proxy_redirect default;
              # proxy_redirect http://127.0.0.1:8443 https://triliumnext.mann.fr; # change them based on your IP, port and domain
              proxy_http_version 1.1;
              proxy_set_header   Upgrade $http_upgrade;
              proxy_set_header   Connection "upgrade";
              proxy_read_timeout 90;
              # add_header Content-Security-Policy "frame-src *; frame-ancestors *; object-src *;";
              # add_header Access-Control-Allow-Credentials true;
              if ($host != "triliumnext.mann.fr") {
                return 302 $scheme://triliumnext.mann.fr$request_uri;
              }
              proxy_ssl_verify off;
            '';
          };
        };
        "triliumnext.resdigita.com" = {
          serverAliases = ["notes.resdigita.com" "note.resdigita.com"];
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            extraConfig = ''
              proxy_pass https://192.168.118.11:8444;
              proxy_set_header Host "triliumnext.mann.fr";
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host "triliumnext.mann.fr";
              proxy_set_header X-Forwarded-Proto "https";
              proxy_set_header X-Scheme $scheme;
              proxy_redirect default;
              # proxy_redirect http://127.0.0.1:8444 https://triliumnext.mann.fr; # change them based on your IP, port and domain
              proxy_http_version 1.1;
              proxy_set_header   Upgrade $http_upgrade;
              proxy_set_header   Connection "upgrade";
              proxy_read_timeout 90;
              # add_header Content-Security-Policy "frame-src *; frame-ancestors *; object-src *;";
              # add_header Access-Control-Allow-Credentials true;
              if ($host != "triliumnext.resdigita.com") {
                return 302 $scheme://triliumnext.resdigita.com$request_uri;
              }
              proxy_ssl_verify off;
            '';
          };
        };
        "www.paris14.cc" = {
          extraConfig = "# proxy_protocol off;";
          forceSSL = true;
          enableACME = true;
          serverAliases = ["paris14.cc"];
          root = "/var/www/paris14cc/";
          locations = {
            "/media/cr".basicAuth = {cc14 = "cc14";};
            "/".extraConfig = ''
              if ($host = 'paris14.cc') {
                return 301 $scheme://www.paris14.cc$request_uri;
              }
              add_header Last-Modified $date_gmt;
              add_header Cache-Control 'no-store, no-cache';
              if_modified_since off;
              expires off;
              etag off;
            '';
          };
        };
        "publii.paris14.cc" = {
          extraConfig = "# proxy_protocol off;";
          forceSSL = true;
          enableACME = true;
          root = "/var/www/publiiparis14cc/";
          locations."/" = {
            basicAuth = {cc14 = "cc14";};
            extraConfig = ''
              add_header Last-Modified $date_gmt;
              add_header Cache-Control 'no-store, no-cache';
              if_modified_since off;
              expires off;
              etag off;
            '';
          };
        };
        "0.ipv6.lesgrandsvoisins.com" = {
          listen = [
            {
              addr = "[2a01:4f8:241:4faa::0]";
              port = 80;
            }
          ];
          root = "/var/www/html/";
        };
        "ld.gdvoisins.com" = {
          serverAliases = ["linkding.lesgrandsvoisins.com"];
          root = "/var/www/linkding/";
          forceSSL = true;
          enableACME = true;
          locations."/static/" = {proxyPass = null;};
          locations."^/login/$" = {
            extraConfig = ''
              return 302 $scheme://linkding.lesgrandsvoisins.com/oidc/authenticate/;
            '';
          };
          locations."/" = {
            extraConfig = ''
              proxy_pass http://localhost:8901;
              proxy_set_header Host "linkding.lesgrandsvoisins.com";
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host "linkding.lesgrandsvoisins.com";
              proxy_set_header X-Forwarded-Proto "https";
              proxy_set_header    X-Scheme $scheme;
              proxy_redirect default;
              proxy_http_version 1.1;
              proxy_set_header   Upgrade $http_upgrade;
              proxy_set_header   Connection "upgrade";
              # add_header Content-Security-Policy "frame-src *; frame-ancestors *; object-src *;";
              # add_header Access-Control-Allow-Credentials true;
              # if ($host != "linkding.lesgrandsvoisins.com") {
              #   return 302 $scheme://linkding.lesgrandsvoisins.com$request_uri;
              # }
            '';
          };
        };
        # "www.villagegv.com" = {
        #   forceSSL = true;
        #   enableACME = true;
        #   serverAliases = ["villagegv.com" "www.villagegv.org" "villagegv.org"];
        #   root = "/var/www/village/";
        #   extraConfig = ''
        #     # proxy_protocol off;
        #     return 302 $scheme://www.village.ngo$request_uri;
        #   '';
        # };
        "www.l14s.com" = {
          extraConfig = "# proxy_protocol off;";
          forceSSL = true;
          enableACME = true;
          root = "/var/www/l14s/";
        };
        "www.gdv1.com" = {
          extraConfig = "# proxy_protocol off;";
          serverAliases = ["www.gdv1.org"];
          forceSSL = true;
          enableACME = true;
          root = "/var/www/gdv1/";
        };
        "dash.gdvoisins.com" = {
          extraConfig = "# proxy_protocol off;";
          forceSSL = true;
          enableACME = true;
          # serverAliases =
          #   ["www.gdvoisins.org" ];
          root = "/var/www/gdvoisins/";
          locations."/".extraConfig = ''
            # kill cache
            add_header Last-Modified $date_gmt;
            add_header Cache-Control 'no-store, no-cache';
            if_modified_since off;
            expires off;
            etag off;
          '';
        };
        "keycloak.village.ngo" = {
          extraConfig = "# proxy_protocol off;";
          enableACME = true;
          forceSSL = true;
          root = "/var/www/keycloakvillagengo";
          # globalRedirect = "keycloak.village.ngo:12443";
          locations."/" = {
            proxyPass = "https://keycloak.village.ngo:12443";
            extraConfig = ''
              proxy_set_header   X-Real-IP $remote_addr;
              proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header   Host $host;
              # proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Proto $scheme;
              add_header Content-Security-Policy "frame-src *; frame-ancestors *; object-src *;";
              add_header Access-Control-Allow-Credentials true;
            '';
          };
        };
        "key.lesgrandsvoisins.com" = {
          extraConfig = "# proxy_protocol off;";
          enableACME = true;
          forceSSL = true;
          serverAliases = ["adminkey.lesgrandsvoisins.com"];
          root = "/var/www/key.lesgrandsvoisins.com";
          # globalRedirect = "key.lesgrandsvoisins.com:14443";
          # listen = [
          #  { addr = "116.202.236.241"; proxyProtocol = true; ssl = true; port = 443; }
          #  { addr = "116.202.236.241"; ssl = false; port = 80; }
          #  { addr = "[2a01:4f8:241:4faa::]"; proxyProtocol = true; ssl = true; port = 443; }
          #  { addr = "[2a01:4f8:241:4faa::]"; ssl = false; port = 80; }
          # ];
          locations."/" = {
            # proxyPass = "https://[2a01:4f8:241:4faa::]:14443";
            proxyPass = "https://192.168.105.11:14443";
            # proxyPass = "https://10.ipv6.configmagic.com";
            extraConfig = ''
              rewrite ^/$ https://key.lesgrandsvoisins.com/realms/master/account/applications redirect;
              proxy_set_header Host $host;
              # proxy_set_header X-Real-IP $proxy_protocol_addr;
              # proxy_set_header X-Forwarded-For $proxy_protocol_addr;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_ssl_certificate     /var/lib/acme/key.lesgrandsvoisins.com/fullchain.pem;
              proxy_ssl_certificate_key /var/lib/acme/key.lesgrandsvoisins.com/key.pem;

              # Config Magic
              add_header Content-Security-Policy "frame-src *; frame-ancestors *; object-src *;";
              add_header Access-Control-Allow-Credentials true;
            '';
          };
        };
        "key.resdigita.com" = {
          extraConfig = "# proxy_protocol off;";
          enableACME = true;
          forceSSL = true;
          serverAliases = ["adminkey.resdigita.com"];
          root = "/var/www/key.resdigita.com";
          # globalRedirect = "key.resdigita.com:14443";
          locations."/" = {
            proxyPass = "https://192.168.106.11:14444";
            extraConfig = ''
              rewrite ^/$ https://key.resdigita.com/realms/master/account/applications redirect;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Proto $scheme;
              add_header Content-Security-Policy "frame-src *; frame-ancestors *; object-src *;";
              add_header Access-Control-Allow-Credentials true;
              proxy_ssl_certificate     /var/lib/acme/key.resdigita.com/fullchain.pem;
              proxy_ssl_certificate_key /var/lib/acme/key.resdigita.com/key.pem;
            '';
          };
        };
        "keycloak.paris14.cc" = {
          extraConfig = "# proxy_protocol off;";
          enableACME = true;
          forceSSL = true;
          root = "/var/www/keycloak.paris14.cc";
          serverAliases = ["adminkeycloak.paris14.cc"];
          # globalRedirect = "keycloak.paris14.cc:14443";
          locations."/" = {
            # basicAuth = { cc14 = "cc14"; };
            proxyPass = "https://192.168.110.11:14445";
            extraConfig = ''
              rewrite ^/$ https://keycloak.paris14.cc/realms/master/account/applications redirect;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Proto $scheme;
              add_header Content-Security-Policy "frame-src *; frame-ancestors *; object-src *;";
              add_header Access-Control-Allow-Credentials true;
              proxy_ssl_certificate     /var/lib/acme/keycloak.paris14.cc/fullchain.pem;
              proxy_ssl_certificate_key /var/lib/acme/keycloak.paris14.cc/key.pem;
            '';
          };
        };
        # "keycloak.gdvox.com" = {
        #   extraConfig = "# proxy_protocol off;";
        #   enableACME = true;
        #   forceSSL = true;
        #   root = "/var/www/keycloak.gvois.com";
        #   serverAliases = ["adminkeycloak.gdvox.com"];
        #   locations."/" = {
        #     proxyPass = "https://192.168.115.11:14446";
        #     extraConfig = ''
        #       rewrite ^/$ https://keycloak.gdvox.com/realms/master/account/applications redirect;
        #       proxy_set_header Host $host;
        #       proxy_set_header X-Real-IP $remote_addr;
        #       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        #       proxy_set_header X-Forwarded-Host $host;
        #       proxy_set_header X-Forwarded-Proto $scheme;
        #       add_header Content-Security-Policy "frame-src *; frame-ancestors *; object-src *;";
        #       add_header Access-Control-Allow-Credentials true;
        #       proxy_ssl_certificate     /var/lib/acme/keycloak.gdvox.com/fullchain.pem;
        #       proxy_ssl_certificate_key /var/lib/acme/keycloak.gdvox.com/key.pem;
        #     '';
        #   };
        # };
        "keycloak.lesgv.org" = {
          extraConfig = "# proxy_protocol off;";
          enableACME = true;
          forceSSL = true;
          root = "/var/www/keycloak.gvois.com";
          serverAliases = ["adminkeycloak.lesgv.org"];
          locations."/" = {
            proxyPass = "https://192.168.117.11:14446";
            extraConfig = ''
              rewrite ^/$ https://keycloak.lesgv.org/realms/master/account/applications redirect;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Proto $scheme;
              add_header Content-Security-Policy "frame-src *; frame-ancestors *; object-src *;";
              add_header Access-Control-Allow-Credentials true;
              proxy_ssl_certificate     /var/lib/acme/keycloak.lesgv.org/fullchain.pem;
              proxy_ssl_certificate_key /var/lib/acme/keycloak.lesgv.org/key.pem;
            '';
          };
        };
        "keycloak.gdvoisins.com" = {
          extraConfig = "# proxy_protocol off;";
          enableACME = true;
          forceSSL = true;
          root = "/var/www/keycloak.gvois.com";
          serverAliases = ["adminkeycloak.coolgv.com"];
          locations."/" = {
            proxyPass = "https://192.168.117.11:14446";
            extraConfig = ''
              rewrite ^/$ https://keycloak.gdvoisins.com/realms/master/account/applications redirect;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Proto $scheme;
              add_header Content-Security-Policy "frame-src *; frame-ancestors *; object-src *;";
              add_header Access-Control-Allow-Credentials true;
              proxy_ssl_certificate     /var/lib/acme/keycloak.gdvoisins.com/fullchain.pem;
              proxy_ssl_certificate_key /var/lib/acme/keycloak.gdvoisins.com/key.pem;
            '';
          };
        };
        # "keycloak.parisgv.com" = {
        #   extraConfig = "# proxy_protocol off;";
        #   enableACME = true;
        #   forceSSL = true;
        #   root = "/var/www/keycloak.parisgv.com";
        #   serverAliases = ["adminkeycloak.parisgv.com" "keycloak.parisgv.org" "adminkeycloak.parisgv.org"];
        #   locations."/" = {
        #     proxyPass = "https://192.168.116.11:14446";
        #     extraConfig = ''
        #       rewrite ^/$ https://keycloak.parisgv.com/realms/master/account/applications redirect;
        #       proxy_set_header Host $host;

        #       proxy_set_header X-Real-IP $remote_addr;
        #       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        #       proxy_set_header X-Forwarded-Host $host;
        #       proxy_set_header X-Forwarded-Proto $scheme;
        #       add_header Content-Security-Policy "frame-src *; frame-ancestors *; object-src *;";
        #       add_header Access-Control-Allow-Credentials true;
        #       proxy_ssl_certificate     /var/lib/acme/keycloak.parisgv.com/fullchain.pem;
        #       proxy_ssl_certificate_key /var/lib/acme/keycloak.parisgv.com/key.pem;
        #       if ($host = "keycloak.parisgv.org") {
        #         return 302 $scheme://keycloak.parisgv.com$request_uri;
        #       }
        #       if ($host = "adminkeycloak.parisgv.org") {
        #         return 302 $scheme://adminkeycloak.parisgv.com$request_uri;
        #       }
        #     '';
        #   };
        # };
        "keycloak.gvois.com" = {
          extraConfig = "# proxy_protocol off;";
          enableACME = true;
          forceSSL = true;
          root = "/var/www/keycloak.gvois.com";
          serverAliases = ["adminkeycloak.gvois.com"];
          # globalRedirect = "keycloak.gvois.com:14443";
          locations."/" = {
            proxyPass = "https://192.168.113.11:14446";
            extraConfig = ''
              rewrite ^/$ https://keycloak.gvois.com/realms/master/account/applications redirect;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Proto $scheme;
              add_header Content-Security-Policy "frame-src *; frame-ancestors *; object-src *;";
              add_header Access-Control-Allow-Credentials true;
              proxy_ssl_certificate     /var/lib/acme/keycloak.gvois.com/fullchain.pem;
              proxy_ssl_certificate_key /var/lib/acme/keycloak.gvois.com/key.pem;
            '';
          };
        };
        "keycloak.parisle.com" = {
          extraConfig = "# proxy_protocol off;";
          enableACME = true;
          forceSSL = true;
          root = "/var/www/keycloak.parisle.com";
          serverAliases = ["adminkeycloak.parisle.com"];
          # globalRedirect = "keycloak.parisle.com:14443";
          locations."/" = {
            proxyPass = "https://192.168.114.11:14447";
            extraConfig = ''
              rewrite ^/$ https://keycloak.parisle.com/realms/master/account/applications redirect;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Proto $scheme;
              add_header Content-Security-Policy "frame-src *; frame-ancestors *; object-src *;";
              add_header Access-Control-Allow-Credentials true;
              proxy_ssl_certificate     /var/lib/acme/keycloak.parisle.com/fullchain.pem;
              proxy_ssl_certificate_key /var/lib/acme/keycloak.parisle.com/key.pem;
            '';
          };
        };
        "link.lesgrandsvoisins.com" = {
          extraConfig = "# proxy_protocol off;";
          serverAliases = ["link.gv.coop"];
          forceSSL = true;
          enableACME = true;
          locations."/.well-known" = {proxyPass = null;};
          locations."/" = {
            extraConfig = ''
              if ($host != "link.lesgrandsvoisins.com") {
                return 302 $scheme://link.lesgrandsvoisins.com$request_uri;
              }
              rewrite ^/$ https://link.lesgrandsvoisins.com/api/v1/auth/signin/keycloak? redirect;
              # rewrite ^/$ https://link.gv.coop/api/v1/auth/signin/keycloak? redirect;
              # rewrite ^/login$ https://link.gv.coop/api/v1/auth/signin/keycloak? redirect;
              proxy_set_header   X-Real-IP $remote_addr;
              proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header   Host $host;
              proxy_pass         http://localhost:3003/;
              proxy_read_timeout 600s;
              # proxy_http_version 1.1;
              # proxy_set_header   Upgrade $http_upgrade;
              # proxy_set_header   Connection "upgrade";
              # proxy_set_header X-Forwarded-Proto $scheme;
              # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              # proxy_redirect off;
            '';
          };
        };
        # "ldap.gv.coop" = {
        "ldap.lesgrandsvoisins.com" = {
          extraConfig = "# proxy_protocol off;";
          # serverAliases = ["lgvldap.lesgrandsvoisins.com"];
          forceSSL = true;
          enableACME = true;
          locations."/.well-known" = {proxyPass = null;};
          # locations."/pwm/private/changepassword".return = "302 https://auth.gv.coop/reset-password/step1";
          # locations."/pwm/public/forgottenpassword".return = "302 https://auth.gv.coop/reset-password/step1";
          # locations."/pwm/public/logout".return = "302 /pwm/";
          locations."/" = {
            extraConfig = ''
              rewrite ^/$ https://key.lesgrandsvoisins.com/ redirect;
              # rewrite ^/$ https://key.gv.coop/ redirect;
              # rewrite ^/$ https://ldap.gv.coop/pwm/ redirect;
              # rewrite ^/pwm/public/logout?processAction=showLogout&stickyRedirectTest=key https://ldap.gv.coop/pwm/ redirect;
              proxy_set_header   X-Real-IP $remote_addr;
              proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header   Host $host;
              proxy_pass         http://localhost:18080/;
              proxy_read_timeout 600s;
              # proxy_http_version 1.1;
              # proxy_set_header   Upgrade $http_upgrade;
              # proxy_set_header   Connection "upgrade";
              # proxy_set_header X-Forwarded-Proto $scheme;
              # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              # proxy_redirect off;
            '';
          };
          # locations."/" = {
          #   return = "302 https://ldap.gv.coop/pwm$request_uri";
          # };
          root = "/var/www/lesgrandsvoisins.com/ldap";
          # root = "/var/www/gv.coop/ldap";
        };
        "syncthing.resdigita.com" = {
          extraConfig = "# proxy_protocol off;";
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            extraConfig = ''
              proxy_set_header   X-Real-IP $remote_addr;
              proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header   Host $host;
              proxy_pass         http://localhost:8384/;
              proxy_read_timeout 600s;
              proxy_send_timeout 600s;
              # proxy_http_version 1.1;
              # proxy_set_header   Upgrade $http_upgrade;
              # proxy_set_header   Connection "upgrade";
              # proxy_set_header X-Forwarded-Proto $scheme;
              # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              # proxy_redirect off;
            '';
          };
        };
        "pocketbase.resdigita.com" = {
          extraConfig = "# proxy_protocol off;";
          serverAliases = ["pocket.resdigita.com"];
          forceSSL = true;
          enableACME = true;
          locations."/" = {proxyPass = "http://localhost:8090";};
        };
        "wordpress.resdigita.com" = {
          extraConfig = "# proxy_protocol off;";
          forceSSL = true;
          enableACME = true;
          serverAliases = ["ghh.resdigita.com"];
          globalRedirect = "ghh.resdigita.com:11443";
        };
        "mail.resdigita.com" = {
          extraConfig = "# proxy_protocol off;";
          serverAliases = [
            # "mail.hopgv.org"
            # "mail.hopgv.com"
            "mail.gvois.org"
            "mail.resdigita.org"
            "mail.lesgrandsvoisins.fr"
          ];
          enableACME = true;
          forceSSL = true;
          locations."/".return = "302 https://mail.lesgrandsvoisins.com";
        };
        "publii.resdigita.com" = {
          extraConfig = "# proxy_protocol off;";
          enableACME = true;
          forceSSL = true;
          root = "/var/www/publii";
          locations."/".extraConfig = ''
            add_header Last-Modified $date_gmt;
            add_header Cache-Control 'no-store, no-cache';
            if_modified_since off;
            expires off;
            etag off;
          '';
        };
        "roundcube.resdigita.com" = {
          extraConfig = "# proxy_protocol off;";
          enableACME = true;
          forceSSL = true;
          root = "/var/www/roundcube";
        };
        "vw.gdvoisins.com" = {
          extraConfig = "# proxy_protocol off;";
          serverAliases = [
            # "vw.l14s.com"
            "vaultwarden.resdigita.com"
            # "vaultwarden.gv.coop"
            # "bitwarden.gv.coop"
            # "vaultwarden.lesgv.org"
            "bit.lesgrandsvoisins.com"
            "vault.lesgrandsvoisins.com"
            "vaultwarden.lesgrandsvoisins.com"
            # "pass.lesgrandsvoisins.com"
          ];
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:8222";
            proxyWebsockets = true;
          };
        };
        "vw.lgv.info" = {
          extraConfig = "# proxy_protocol off;";
          serverAliases = [
            "vaultwarden.lgv.info"
          ];
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:8222";
            proxyWebsockets = true;
          };
        };
        "uptime-kuma.resdigita.com" = {
          extraConfig = "# proxy_protocol off;";
          serverAliases = [
            "uptime-kuma.lesgv.org"
            "uk.lesgv.org"
            "up.lesgrandsvoisins.com"
          ];
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            extraConfig = ''
              proxy_set_header   X-Real-IP $remote_addr;
              proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header   Host $host;
              proxy_pass         http://localhost:3001/;
              proxy_http_version 1.1;
              proxy_set_header   Upgrade $http_upgrade;
              proxy_set_header   Connection "upgrade";
              # proxy_set_header X-Forwarded-Proto $scheme;
              # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              # proxy_redirect off;
            '';
          };
        };
        "xandikos.resdigita.com" = {
          extraConfig = "# proxy_protocol off;";
          serverAliases = ["xandikos.lesgv.org"];
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            # proxyPass = "https://xandikos.resdigita.com:5280";
            proxyPass = "http://localhost:5280";
            # locations."/".proxyPass = "http://localhost:8334";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_redirect off;
            '';
          };
        };
        "ethercalc.resdigita.com" = {
          extraConfig = "# proxy_protocol off;";
          serverAliases = ["ethercalc.lesgv.org" "table.lesgrandsvoisins.com"];
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:8123";
            # locations."/".proxyPass = "http://localhost:8334";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_redirect off;
            '';
          };
        };
        "radicale.resdigita.com" = {
          extraConfig = "# proxy_protocol off;";
          serverAliases = [
            "radicale.lesgv.org"
            "radicale.lesgrandsvoisins.com"
          ];
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "https://radicale.resdigita.com:8443";
            # locations."/".proxyPass = "http://localhost:8334";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_redirect off;
            '';
          };
        };
        "keeweb.lesgrandsvoisins.com" = {
          extraConfig = "# proxy_protocol off;";
          enableACME = true;
          forceSSL = true;
          globalRedirect = "keepass.resdigita.com";
        };
        "filebrowser.resdigita.com" = {
          extraConfig = "# proxy_protocol off;";
          serverAliases = [
            "filebrowser.gv.coop"
            "filebrowser.lesgv.org"
            "filebrowser.lesgrandsvoisins.com"
          ];
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "https://filebrowser.resdigita.com:8443";
            # locations."/".proxyPass = "http://localhost:8334";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
          };
        };
        "chris.resdigita.com" = {
          extraConfig = "# proxy_protocol off;";
          serverAliases = ["chris.lesgv.org"];
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "https://chris.resdigita.com:8443";
            # locations."/".proxyPass = "http://localhost:8334";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
          };
        };
        "axel.resdigita.com" = {
          extraConfig = "# proxy_protocol off;";
          serverAliases = ["axel.lesgv.org"];
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "https://axel.resdigita.com:8443";
            # locations."/".proxyPass = "http://localhost:8334";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
          };
        };
        "maruftuyel.resdigita.com" = {
          extraConfig = "# proxy_protocol off;";
          serverAliases = ["maruftuyel.lesgv.org"];
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "https://maruftuyel.resdigita.com:8443";
            # locations."/".proxyPass = "http://localhost:8334";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
          };
        };
        "homepage-dashboard.resdigita.com" = {
          extraConfig = "# proxy_protocol off;";
          serverAliases = [
            "homepage-dashboard.gv.coop"
            "homepage-dashboard.lesgv.org"
            "hd.lesgv.org"
            "dash.lesgrandsvoisins.com"
          ];
          enableACME = true;
          forceSSL = true;
          locations."/".proxyPass = "http://localhost:8882/";
        };
        "silverbullet.village.ngo" = {
          serverAliases = ["silverbullet.resdigita.com"];
          enableACME = true;
          forceSSL = true;
          #locations."/".proxyPass = "http://10.245.101.35:3000/";
          locations."/".proxyPass = "http://192.168.102.2:3000/";
          # locations."/".proxyPass = "https://192.168.102.2:3443/";
          extraConfig = ''
            # proxy_protocol off;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_redirect off;
          '';
        };
        "ete.village.ngo" = {
          extraConfig = "# proxy_protocol off;";
          enableACME = true;
          forceSSL = true;
          serverAliases = ["ete.lesgrandsvoisins.com"];
          locations."/".proxyPass = "http://unix:/var/lib/etebase-server/etebase-server.sock";
        };
        "drive.lesgrandsvoisins.com" = {
          extraConfig = "# proxy_protocol off;";
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            extraConfig = ''
              if ($host != "sftpgo.lesgrandsvoisins.com") {
                return 302 $scheme://sftpgo.lesgrandsvoisins.com$request_uri;
              }
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host $host:$server_port;
              # proxy_set_header X-Forwarded-Host $server_name;
              proxy_http_version 1.1;
              proxy_set_header  Upgrade $http_upgrade;
              proxy_set_header  Connection "upgrade";
              # proxy_bind $remote_addr transparent;
              # proxy_set_header Connection $connection_upgrade;
              proxy_pass https://sftpgo.lesgrandsvoisins.com:10443;
              client_max_body_size 2500M;
              # proxy_redirect https://sftpgo.lesgrandsvoisins.com:10443 https://sftpgo.lesgrandsvoisins.com;
              # proxy_ssl_verify  off;
              proxy_ssl_trusted_certificate /var/lib/acme/sftp.lesgrandsvoisins.com/fullchain.pem;
            '';
          };
        };
        "minio.lesgrandsvoisins.com" = {
          extraConfig = "# proxy_protocol off;";
          enableACME = true;
          forceSSL = true;
          locations."/".proxyPass = "http://127.0.0.1:9000";
        };
        "www.configmagic.com" = {
          extraConfig = "# proxy_protocol off;";
          serverAliases = ["ipv6.configmagic.com"];
          enableACME = true;
          forceSSL = true;
          locations = {
            "/.well-known" = {proxyPass = null;};
            "/" = {
              # proxyPass = "https://[::1]:3443";
              proxyPass = "https://[2a01:4f8:241:4faa::]:3443";
              # proxyPass = "https://[2a01:4f8:241:4faa::]:3443";
              # proxyPass = "https://[fc00::12:2]:3443";
              # proxyPass = "http://192.168.112.11:3000";

              extraConfig = ''
                # # proxy_protocol off
                proxy_set_header Host $host;
                # proxy_set_header X-Real-IP $proxy_protocol_addr;
                proxy_set_header X-Real-IP $remote_addr;
                # proxy_set_header X-Forwarded-For $proxy_protocol_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Host $host;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_redirect off;

                  # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  # proxy_redirect off;
                  # proxy_set_header Host $host;
                  # proxy_set_header X-Real-IP $remote_addr;
                  # # proxy_set_header X-Forwarded-Host $host:$server_port;
                  # proxy_set_header X-Forwarded-Host $server_name;
                  proxy_http_version 1.1;
                  proxy_set_header  Upgrade $http_upgrade;
                  proxy_set_header  Connection "upgrade";
                  # proxy_bind $remote_addr transparent;

                  # client_max_body_size 2500M;

                  # proxy_ssl_trusted_certificate /var/lib/acme/www.configmagic.com/fullchain.pem;
              '';
              recommendedProxySettings = true;
            };
          };
        };
        "writefreely.lesgrandsvoisins.com" = {
          extraConfig = "# proxy_protocol off;";
          root = "/var/www/writefreely/static";
          enableACME = true;
          forceSSL = true;
          locations = {
            "/favicon.ico" = {proxyPass = null;};
            "/js/" = {proxyPass = null;};
            "/fonts/" = {proxyPass = null;};
            "/img/" = {proxyPass = null;};
            "/css/" = {proxyPass = null;};
            "/.well-known" = {proxyPass = null;};
            "/" = {
              proxyPass = "http://127.0.0.1:9090";
              extraConfig = ''
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_redirect off;
              '';
              recommendedProxySettings = true;
            };
          };
        };
        "task.lesgrandsvoisins.com" = {
          extraConfig = "# proxy_protocol off;";
          serverAliases = [
            # "vk.l14s.com"
            # "vikunja.gv.coop"
            # "vikunja.lesgv.org"
            # "task.lesgrandsvoisins.com"
            "vikunja.lesgrandsvoisins.com"
            # "task.resdigita.com"
            # "vikunja.village.ngo"
          ];
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:3456/";
            extraConfig = ''
              if ($host != "task.lesgrandsvoisins.com") {
                return 302 $scheme://task.lesgrandsvoisins.com$request_uri;
              }
              # if ($host != "task.resdigita.com") {
              #   return 302 $scheme://task.lesgrandsvoisins.com$request_uri;
              # }
              proxy_http_version 1.1;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_redirect off;
              client_max_body_size 200M;
              # proxy_set_header Host $host;
            '';
          };
        };
        "vikunja.resdigita.com" = {
          extraConfig = "# proxy_protocol off;";
          serverAliases = [];
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://[fc00::9:2]:3456/";
            extraConfig = ''
              proxy_http_version 1.1;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_redirect off;
              client_max_body_size 400M;
              # proxy_set_header Host $host;
            '';
          };
        };
        "discourse.village.ngo" = {
          extraConfig = "# proxy_protocol off;";
          serverAliases = [
            "disc.lesgrandsvoisins.com"
            "discourse.lesgrandsvoisins.com"
            "forum.lesgrandsvoisins.com"
          ];
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            extraConfig = ''
              proxy_http_version 1.1;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_redirect off;
              proxy_set_header   Host $host;
              proxy_pass         https://192.168.104.11;
              proxy_ssl_trusted_certificate /var/lib/acme/discourse.village.ngo/full.pem;
              proxy_ssl_verify     off;
              proxy_set_header   Upgrade $http_upgrade;
              proxy_set_header   Connection "upgrade";
            '';
          };
        };
        "discourse.paris14.cc" = {
          extraConfig = "# proxy_protocol off;";
          enableACME = true;
          forceSSL = true;
          # root = "/var/www/discoursecc";
          # locations."/images" = { proxyPass = null; };
          locations."/" = {
            basicAuth = {cc14 = "cc14";};
            extraConfig = ''
              proxy_http_version 1.1;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_redirect off;
              proxy_set_header   Host $host;
              proxy_pass         https://192.168.111.11;
              proxy_ssl_trusted_certificate /var/lib/acme/discourse.paris14.cc/full.pem;
              proxy_ssl_verify   off;
              proxy_set_header   Upgrade $http_upgrade;
              proxy_set_header   Connection "upgrade";
            '';
          };
        };
        "mm.lgv.info" = {
          extraConfig = "# proxy_protocol off;";
          enableACME = true;
          forceSSL = true;
          # root = "/var/www/mmcc";
          # locations."/images" = { proxyPass = null; };
          locations."/" = {
            # basicAuth = { cc14 = "cc14"; };
            # proxyWebsockets = true;
            extraConfig = ''
              proxy_http_version 1.1;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_redirect off;
              proxy_set_header   Host $host;
              proxy_pass         http://192.168.119.11:8065;
              proxy_ssl_trusted_certificate /var/lib/acme/mm.lgv.info/full.pem;
              proxy_ssl_verify   off;
              proxy_set_header   Upgrade $http_upgrade;
              proxy_set_header   Connection "upgrade";
            '';
          };
        };
      };
    };
  };
}
