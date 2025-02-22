{ config, pkgs, lib, ... }:
let
in
{
  security.acme = {
    acceptTerms = true;
    defaults.email = "contact@lesgrandsvoisins.com";
    defaults.webroot = "/var/www/html";
    certs."0.ipv6.lesgrandsvoisins.com" = { };
    certs."1.ipv6.lesgrandsvoisins.com" = { };
    certs."2.ipv6.lesgrandsvoisins.com" = { };
    # certs."3.ipv6.lesgrandsvoisins.com" = {};  
    certs."4.ipv6.lesgrandsvoisins.com" = { };
    # certs."5.ipv6.lesgrandsvoisins.com" = {};  
    # certs."6.ipv6.lesgrandsvoisins.com" = {};  
    certs."7.ipv6.lesgrandsvoisins.com" = { };
    # certs."8.ipv6.lesgrandsvoisins.com" = {};  
    certs."9.ipv6.lesgrandsvoisins.com" = { };
    certs."10.ipv6.lesgrandsvoisins.com" = { };
    # certs."sftpgo.lesgrandsvoisins.com" = {};  
    certs."linkding.lesgrandsvoisins.com" = { };
  };
}
