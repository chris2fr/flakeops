{ config, pkgs, lib, ... }:
let 
in
{ 
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = ["github.com/authcrunch/authcrunch@v1.0.14"];
      hash = "sha256-muPcuC9drM5kSkvUJny0d5nFH4Z6k9lDunpVpPDVU9M=";
    };
    user = "wwwrun";
    group = "wwwrun";
    email = "hostmaster@lesgrandsvoisins.com";
    virtualHosts = {
      "fontenay.gdvoisins.com" = {};
      "roses.gdvoisins.com" = {};
      "cp.roses.gdvoisins.com" = {};
      "public.cp.roses.gdvoisins.com" = {};
      "fs.roses.gdvoisins.com" = {};
      "cw.roses.gdvoisins.com" = {};
      "co.roses.gdvoisins.com" = {};
    };
  };
}