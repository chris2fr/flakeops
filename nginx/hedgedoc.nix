{
  config,
  pkgs,
  lib,
  ...
}:
let
in
{
  services.nginx.virtualHosts = {
    # "hdoc.desgrandsvoisins.org" = {
    #   enableACME = true;
    #   forceSSL = true;
    #   serverAliases = [
    #     "hdoc.desgrandsvoisins.com"
    #     "hdoc.desgv.com"
    #     "hdoc.lesgrandsvoisins.com"
    #     "hdoc.lesgv.com"
    #     "hdoc.resdigita.com"
    #     "hedgedoc.desgrandsvoisins.com"
    #     "hedgedoc.desgv.com"
    #     "hedgedoc.lesgrandsvoisins.com"
    #     "hedgedoc.lesgv.com"
    #     "hedgedoc.lesgv.org"
    #   ];
    #   globalRedirect = "hedgedoc.resdigita.com";
    # };
    "mark.lesgrandsvoisins.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = [
        "hedgedoc.lesgrandsvoisins.com"
        "hedgedoc.lesgv.org"
        "hedgedoc.resdigita.com"
        # "hedgedoc.village.ngo"
        # "hedgedoc.gv.coop"
        "mark.lesgrandsvoisins.com"
        "mark.resdigita.com"
        # "hd.l14s.com"
        # "hd.gdvoisins.com"
      ];
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:3333/";
      locations."/".extraConfig = ''
        if ($host != "mark.lesgrandsvoisins.com") {
          return 302 $scheme://mark.lesgrandsvoisins.com$request_uri;
        }
      '';
    };
    #  "hedgedoc.gv.coop" = {
    #   enableACME = true;
    #   forceSSL = true;
    #   locations."/".proxyPass = "http://localhost:3333/";
    # };
  };
}
