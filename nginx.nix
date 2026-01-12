{
  config,
  pkgs,
  lib,
  ...
}: let
  oidcRosesSecret = import ./secrets/oidc-roses-secret.nix;
  jwtVouchSecret = import ./secrets/jwt-vouch-secret.nix;
in {
  services.nginx = {
    enable = false;
    clientMaxBodySize = "10G";
    appendConfig = ''
      # lua_shared_dict jwt_verification 10m;
      # set_real_ip_from IP_HAPROXY;
      # real_ip_header proxy_protocol;
    '';

    virtualHosts = {
      "fs.roses.gdvoisins.com" = {
        forceSSL = true;
        enableACME = true;
        listen = [
          # {port = 444; ssl = true; proxyProtocol = true;}
          {
            addr = "0.0.0.0";
            port = 444;
            ssl = true;
            proxyProtocol = true;
          }
          {
            addr = "[::]";
            port = 444;
            ssl = true;
            proxyProtocol = true;
          }
          {
            addr = "0.0.0.0";
            port = 81;
          }
          {
            addr = "[::]";
            port = 81;
          }
        ];
        # useACMEHost = "fs.roses.gdvoisins.com";
        sslCertificateKey = "/var/lib/acme/fs.roses.gdvoisins.com/key.pem";
        sslCertificate = "/var/lib/acme/fs.roses.gdvoisins.com/fullchain.pem";
        extraConfig = ''
          ssl_certificate_key /var/lib/acme/fs.roses.gdvoisins.com/key.pem;
          ssl_certificate /var/lib/acme/fs.roses.gdvoisins.com/fullchain.pem;
        '';
        sslTrustedCertificate = "/var/lib/acme/fs.roses.gdvoisins.com/fullchain.pem";
        root = "/var/www/default";
        locations."/" = {
          proxyPass = "http://127.0.0.1:8334";
          # recommendedProxySettings = true;
          extraConfig = ''
            proxy_buffering off;
            proxy_cache off;
            proxy_read_timeout   86400;
            proxy_set_header     Host $host:$server_port;
            proxy_set_header     X-Real-IP $remote_addr;
            proxy_set_header     X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto https;

          '';
          # proxy_set_header     X-Forwarded-Proto $scheme;
        };
      };
      "static.roses.gdvoisins.com" = {
        forceSSL = true;
        enableACME = true;
        listen = [
          {
            addr = "0.0.0.0";
            port = 444;
            ssl = true;
            proxyProtocol = true;
          }
          {
            addr = "[::]";
            port = 444;
            ssl = true;
            proxyProtocol = true;
          }
          {
            addr = "0.0.0.0";
            port = 81;
          }
          {
            addr = "[::]";
            port = 81;
          }
        ];
        sslCertificateKey = "/var/lib/acme/static.roses.gdvoisins.com/key.pem";
        sslCertificate = "/var/lib/acme/static.roses.gdvoisins.com/fullchain.pem";
        extraConfig = ''
          ssl_certificate_key /var/lib/acme/static.roses.gdvoisins.com/key.pem;
          ssl_certificate /var/lib/acme/static.roses.gdvoisins.com/fullchain.pem;
        '';
        sslTrustedCertificate = "/var/lib/acme/static.roses.gdvoisins.com/fullchain.pem";
        root = "/var/www/default";
      "cp.roses.gdvoisins.com" = {
        forceSSL = true;
        enableACME = true;
        listen = [
          {
            addr = "0.0.0.0";
            port = 444;
            ssl = true;
            proxyProtocol = true;
          }
          {
            addr = "[::]";
            port = 444;
            ssl = true;
            proxyProtocol = true;
          }
          {
            addr = "0.0.0.0";
            port = 81;
          }
          {
            addr = "[::]";
            port = 81;
          }
        ];
        sslCertificateKey = "/var/lib/acme/cp.roses.gdvoisins.com/key.pem";
        sslCertificate = "/var/lib/acme/cp.roses.gdvoisins.com/fullchain.pem";
        extraConfig = ''
          ssl_certificate_key /var/lib/acme/cp.roses.gdvoisins.com/key.pem;
          ssl_certificate /var/lib/acme/cp.roses.gdvoisins.com/fullchain.pem;
        '';
        sslTrustedCertificate = "/var/lib/acme/cp.roses.gdvoisins.com/fullchain.pem";
        root = "/var/www/default";
        locations."/" = {
          proxyPass = "https://192.168.1.100:3923";
          extraConfig = ''
            proxy_set_header X-Forwarded-Proto https;


            proxy_redirect off;
            # disable buffering (next 4 lines)
            proxy_http_version 1.1;
            client_max_body_size 0;
            proxy_buffering off;
            proxy_request_buffering off;
            # improve download speed from 600 to 1500 MiB/s
            proxy_buffers 32 8k;
            proxy_buffer_size 16k;
            proxy_busy_buffers_size 24k;

            proxy_set_header   Connection        "Keep-Alive";
            proxy_set_header   Host              $host;
            proxy_set_header   X-Real-IP         $remote_addr;
            # proxy_set_header   X-Forwarded-Proto $scheme;
            proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
            # NOTE: with cloudflare you want this X-Forwarded-For instead:
            #proxy_set_header   X-Forwarded-For   $http_cf_connecting_ip;
          '';
        };
      };
    };
  };
}
