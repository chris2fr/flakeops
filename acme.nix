{ config, pkgs, lib, filestash, ... }:
let 
in
{
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "chris@lesgrandsvoisins.com";
    };
    certs = {
      "roses.gdvoisins.com" = {
        # webroot = "/var/lib/acme/acme-challenge/";
        # extraDomainNames = [ 
        #   "www.roses.gdvoisins.com"
        #   "cp.roses.gdvoisins.com" 
        #   "co.roses.gdvoisins.com" 
        #   "cw.roses.gdvoisins.com" 
        #   "fs.roses.gdvoisins.com" 
        #   "public.cp.roses.gdvoisins.com" 
        #   "static.roses.gdvoisins.com" 
        #   "fontenay.gdvoisins.com" 
        # ];
      };
      "cp.roses.gdvoisins.com"  = {listenHTTP = "80";};
      "co.roses.gdvoisins.com"   = {listenHTTP = "80";};
      "cw.roses.gdvoisins.com"   = {listenHTTP = "80";};
      "fs.roses.gdvoisins.com"   = {listenHTTP = "80";};
      "public.cp.roses.gdvoisins.com"  = {listenHTTP = "80";}; 
      "static.roses.gdvoisins.com"   = {listenHTTP = "80";};
      "fontenay.gdvoisins.com"   = {listenHTTP = "80";};
    };
  };
}
