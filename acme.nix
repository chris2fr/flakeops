{ config, pkgs, lib, filestash, ... }:
let 
in
{
  security.acme = {
    acceptTerms = true;
    defaults = {
      listenHTTP = ":1360";
      email = "chris@lesgrandsvoisins.com";
    };
    certs = {
    "roses.gdvoisins.com" = {
      # webroot = "/var/lib/acme/acme-challenge/";
      extraDomainNames = [ 
        "www.roses.gdvoisins.com"
        "cp.roses.gdvoisins.com" 
        "co.roses.gdvoisins.com" 
        "cw.roses.gdvoisins.com" 
        "fs.roses.gdvoisins.com" 
        "public.cp.roses.gdvoisins.com" 
        "static.roses.gdvoisins.com" 
        "fontenay.gdvoisins.com" 
      ];
    };
  };
  };
}
