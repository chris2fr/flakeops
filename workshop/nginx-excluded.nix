{ config, pkgs, lib, ... }:
let
in
{
  # networking = {
  #   extraHosts = "192.168.103.2 ghh.resdigita.com";
  # };
  services = {
    nginx = {
      # defaultListenAddresses = [ "0.0.0.0" "116.202.236.241" "[::]" "[::1]"];
      #defaultListen = [{ addr = "0.0.0.0"; port=8888; } { addr = "[::]"; port=8443; } { addr="[2a01:4f8:241:4faa::100]" ; port=443;} ];
      # appendConfig = ''
      #       log_format seafileformat '$http_x_forwarded_for $remote_addr [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" $upstream_response_time';
      # '';
      # commonHttpConfig = ''
      # '';
      upstreams = {
        # "wagtail".extraConfig = ''
        #   # server unix:/var/lib/wagtail/wagtail-lesgv.sock;
        #   server localhost:8000;
        # '';
      };
      virtualHosts = {
        # "8.ipv6.lesgrandsvoisins.com" = {
        #   root =  "/var/www/html/";
        #   forceSSL = true;
        #   enableACME = true;
        #   locations."/" = {
        #   proxyPass = "https://[2a01:4f8:241:4faa::8]";
        #   recommendedProxySettings = true;
        #   proxyWebsockets = true;
        #     extraConfig = ''
        #     proxy_set_header Host $host;
        #     proxy_set_header X-Real-IP $remote_addr;
        #     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        #     proxy_set_header X-Forwarded-Host $host;
        #     proxy_set_header X-Forwarded-Proto $scheme;
        #     add_header Content-Security-Policy "frame-src *; frame-ancestors *; object-src *;";
        #     add_header Access-Control-Allow-Credentials true;
        #     proxy_ssl_verify  off;
        #     '';
        #   };
        # };
        # "sftpgo.lesgrandsvoisins.com" = {
        #   root =  "/var/www/html/";
        #   listen = [{
        #     addr = "[2a01:4f8:241:4faa::8]";
        #     port = 80;
        #   }];
        # };
        "0.ipv6.lesgrandsvoisins.com" = {
          listen = [{ addr = "[2a01:4f8:241:4faa::0]"; port = 80; }];
          root = "/var/www/html/";
        };
        # "1.ipv6.lesgrandsvoisins.com" = {
        #   listen = [{ addr = "[2a01:4f8:241:4faa::1]"; port = 80; }];
        #   root =  "/var/www/html/";
        # };
        # "2.ipv6.lesgrandsvoisins.com" = {
        #   listen = [{ addr = "[2a01:4f8:241:4faa::2]"; port = 80; }];
        #   root =  "/var/www/html/";
        # };
        # # "3.ipv6.lesgrandsvoisins.com" = {
        # #   listen = [{ addr = "[2a01:4f8:241:4faa::3]"; port = 80; }];
        # #   root =  "/var/www/html/";
        # # };
        # "4.ipv6.lesgrandsvoisins.com" = {
        #   listen = [{ addr = "[2a01:4f8:241:4faa::4]"; port = 80; }];
        #   root =  "/var/www/html/";
        # };
        # # "5.ipv6.lesgrandsvoisins.com" = {
        # #   listen = [{ addr = "[2a01:4f8:241:4faa::5]"; port = 80; }];
        # #   root =  "/var/www/html/";
        # # };
        # # "6.ipv6.lesgrandsvoisins.com" = {
        # #   listen = [{ addr = "[2a01:4f8:241:4faa::6]"; port = 80; }];
        # #   root =  "/var/www/html/";
        # # };
        # "7.ipv6.lesgrandsvoisins.com" = {
        #   listen = [{ addr = "[2a01:4f8:241:4faa::7]"; port = 80; }];
        #   root =  "/var/www/html/";
        # };
        # "9.ipv6.lesgrandsvoisins.com" = {
        #   listen = [{ addr = "[2a01:4f8:241:4faa::9]"; port = 80; }];
        #   root =  "/var/www/html/";
        # };
        # "10.ipv6.lesgrandsvoisins.com" = {
        #   # serverAliases = ["linkding"];
        #   root =  "/var/www/html/";
        #   listen = [{
        #     addr = "[2a01:4f8:241:4faa::10]";
        #     port = 80;
        #   }
        #   {
        #     addr = "[2a01:4f8:241:4faa::10]";
        #     port = 443;
        #     ssl = true;
        #   }];
        #   forceSSL = true;
        #   enableACME = true;
        #   locations."/" = {
        #     recommendedProxySettings = true;
        #     proxyPass = "http://localhost:8901";
        #     extraConfig = ''
        #     # if ($host != "linkding.lesgrandsvoisins.com") {
        #     #   return 302 $scheme://linkding.lesgrandsvoisins.com$request_uri;
        #     # }
        #     '';
        #   };
        # };
        "pocketbase.resdigita.com" = {
          serverAliases = [ "pocket.resdigita.com" ];
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://localhost:8090";
            # proxyWebsockets = true      locations."/.well-known" = { proxyPass = null; };
            # extraConfig = ''
            # proxy_set_header   X-Real-IP $remote_addr;
            # proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            # proxy_set_header   Host $host;

            # proxy_http_version 1.1;
            # proxy_set_header   Upgrade $http_upgrade;
            # proxy_set_header   Connection "upgrade";
            # # proxy_set_header X-Forwarded-Proto $scheme;
            # # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            # # proxy_redirect off;
            # '';
          };
        };
        "wordpress.resdigita.com" = {
          forceSSL = true;
          enableACME = true;
          serverAliases = [ "ghh.resdigita.com" ];
          globalRedirect = "ghh.resdigita.com:11443";
          # locations."/" = {
          #   proxyPass = "https://192.168.103.2";
          #   extraConfig = ''
          #     proxy_set_header X-Forwarded-Proto $scheme;
          #     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          #     proxy_set_header   X-Real-IP $remote_addr;
          #     proxy_set_header   Host $host;
          #   '';
          # };
        };
        # "seafile.resdigita.com" = {
        #   enableACME = true;
        #   forceSSL = true;
        #   locations."/".proxyPass = "http://localhost:8082";
        # };
        # "filestash.resdigita.com" = {
        #   enableACME = true;
        #   forceSSL = true;
        #   locations."/".proxyPass = "http://localhost:8334";
        # }; 

        # "etedav.village.ngo" = {
        #   enableACME = true;
        #   forceSSL = true;
        #   locations."/".proxyPass = "http://localhost:37358/";
        #   extraConfig = ''
        #     proxy_set_header X-Forwarded-Proto $scheme;
        #     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        #   '';
        # };
      };
    };
  };
}
