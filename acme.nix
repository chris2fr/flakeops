{ config, pkgs, lib, filestash, ... }:
let 
in
{
  security.acme.certs = {
    "example.com" = {
      webroot = "/var/lib/acme/acme-challenge/";
      email = "foo@example.com";
      extraDomainNames = [ "www.example.com" "foo.example.com" ];
    };
    "bar.example.com" = {
      webroot = "/var/lib/acme/acme-challenge/";
      email = "bar@example.com";
    };
  };
}
