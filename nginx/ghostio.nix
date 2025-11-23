{ config, pkgs, lib, ... }:
let
in
{
  services.nginx.virtualHosts = {
    # "blog.desgrandsvoisins.org" = {
    #   root = "/var/www/ghostio/";
    #   enableACME = true;
    #   forceSSL = true;
    #   serverAliases = ["blog.resdigita.com" "blog.desgrandsvoisins.com"];
    #   globalRedirect = "blog.lesgrandsvoisins.com";
    # };
    "blog.lesgrandsvoisins.fr" = {
      serverAliases = [ "ghost.lesgv.org" ];
      root = "/var/www/ghostio/";
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:2368/";
      };
    };
    "blog.lesgrandsvoisins.com" = {
        extraConfig = "# proxy_protocol off;";
      root = "/var/www/ghostlesgrandsvoisinscom/";
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:2369/";
      };
    };
    "ghost.resdigita.com" = {
        extraConfig = "# proxy_protocol off;";
      serverAliases = [ "blog.resdigita.com" ];
      root = "/var/www/ghostresdigitacom/";
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:2370/";
      };
    };
  };
}
