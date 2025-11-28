{ config, pkgs, lib, ... }:
let 
in
{ 
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = ["github.com/greenpau/caddy-security@v1.1.31"];
      # plugins = ["github.com/greenpau/caddy-security@v1.1.31" "github.com/mholt/caddy-l4@v0.0.0-20251124224044-66170bec9f4d"];
      hash = "sha256-b+hW1MN84eW7OkBIwKHp4VrvHOVi8gsTnTrWAoxmbE0=";
    };
    user = "wwwrun";
    group = "wwwrun";
    email = "hostmaster@lesgrandsvoisins.com";
    globalConfig = ''
      http_port 84
      https_port 447
    '';
    virtualHosts = {
      "fontenay.gdvoisins.com" = {
        extraConfig = ''
          reverse_proxy https://fontenay.gdvoisins.com:446
        '';
      };
      "roses.gdvoisins.com" = {};
      "cp.roses.gdvoisins.com" = {
        # [mannchri@rosest330:~]$ ls /var/lib/copyparty/ssl-public/
        # ca.key  ca.pem  cfssl.json  srv.key  srv.pem
        extraConfig = ''
          reverse_proxy https://[::1]:3923 {
          }
        '';
            # transport http {
            #   tls_client_auth /var/lib/copyparty/ssl/srv.pem /var/lib/copyparty/ssl/srv.key
            # }
      };
      "public.cp.roses.gdvoisins.com" = {
        extraConfig = ''
          reverse_proxy https://[::1]:3924 
        '';
        # {
        #     transport http {
        #       tls_client_auth /var/lib/copyparty/ssl-public/srv.pem /var/lib/copyparty/ssl-public/srv.key
        #     }
        #   }
      };
      "fs.roses.gdvoisins.com" = {};
      "cw.roses.gdvoisins.com" = {};
      "co.roses.gdvoisins.com" = {};
    };
  };
}