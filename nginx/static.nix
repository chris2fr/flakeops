{ config, pkgs, lib, ... }:
let
in
{
  services.nginx.virtualHosts = {
    "doc.lesgrandsvoisins.com" = {
      extraConfig = "# proxy_protocol off;";
      # serverAliases = ["resdigita.org" "www.resdigita.org" "doc.desgrandsvoisins.com"  "doc.lesgrandsvoisins.com" "doc.resdigita.com"];
      serverAliases = [ "doc.resdigita.com" ];
      globalRedirect = "quartz.resdigita.com";
      enableACME = true;
      forceSSL = true;
      root = "/var/www/resdigitacom";
    };
    "quartz.resdigita.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = [
        "quartz.gv.coop"
        "quartz.lesgv.org"
        "quartz.gdvoisins.com"
        # "quartz.l14s.com"
      ];
      enableACME = true;
      forceSSL = true;
      root = "/var/www/resdigitacom";
    };
    "static.grandzine.org" = {
      extraConfig = "# proxy_protocol off;";
      enableACME = true;
      forceSSL = true;
      root = "/var/www/grandzine.org_static";
    };
    # "www.grandzine.org" = {
    #   enableACME = true;
    #   forceSSL = true;
    #   root = "/var/www/grandzine/prototype";
    # };
    "www.grandzine.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = ["grandzine.com" "grandzine.org"];
      enableACME = true;
      forceSSL = true;
      root = "/var/www/grandzine/prototype";
      locations."/".extraConfig = ''
        return 301 $scheme://www.grandzine.org$request_uri;
      '';
    };
  };
}
