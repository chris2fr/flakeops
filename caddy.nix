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
    virtualHosts = {
      "fontenay.gdvoisins.com" = {
        extraConfig = ''
          reverse_proxy https://fontenay.gdvoisins.com:446
        '';
      };
      "roses.gdvoisins.com" = {};
      "cp.roses.gdvoisins.com" = {
        extraConfig = ''
          reverse_proxy https://[::1]:3923
        '';
      };
      "public.cp.roses.gdvoisins.com" = {
        extraConfig = ''
          reverse_proxy https://[::1]:3924
        '';
      };
      "fs.roses.gdvoisins.com" = {};
      "cw.roses.gdvoisins.com" = {};
      "co.roses.gdvoisins.com" = {};
    };
  };
}