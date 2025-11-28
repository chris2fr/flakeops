{ config, pkgs, lib, ... }:
let 
in
{ 
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = ["github.com/authcrunch/authcrunch@v1.0.14"];
      hash = "";
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