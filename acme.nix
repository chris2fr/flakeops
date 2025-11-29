{ config, pkgs, lib, filestash, ... }:
let 
in
{
  security.acme = {
    acceptTerms = true;
    useRoot = false;
    defaults = {
      email = "chris@lesgrandsvoisins.com";
      webroot = null;
    };
    certs = {
      "roses.gdvoisins.com" = {
        # webroot = "/var/lib/acme/acme-challenge/";
        webroot = "/var/lib/acme/acme-challenge/";
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
      "cp.roses.gdvoisins.com"  = {webroot = "/var/lib/acme/acme-challenge/";};
      "co.roses.gdvoisins.com"   = {webroot = "/var/lib/acme/acme-challenge/";};
      "cw.roses.gdvoisins.com"   = {webroot = "/var/lib/acme/acme-challenge/";};
      "fs.roses.gdvoisins.com"   = {webroot = "/var/lib/acme/acme-challenge/";};
      "public.cp.roses.gdvoisins.com"  = {webroot = "/var/lib/acme/acme-challenge/";}; 
      "static.roses.gdvoisins.com" = {webroot = "/var/lib/acme/acme-challenge/";};
      "fontenay.gdvoisins.com"   = {webroot = "/var/lib/acme/acme-challenge/";};
    };
  };
}
