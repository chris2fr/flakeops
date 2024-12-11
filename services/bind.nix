{ config, pkgs, lib, ... }:
let 
  dnsslaves = [
          # ns{1,2,3,4,5}.linode.com
          "96.126.114.97"
          "96.126.114.98"
          "2600:3c00::5e"
          "2600:3c00::5f"
          # ns2.afraid.org
          "69.65.50.192"  
          "2001:1850:1:5:800::6b"
          # ns1.he.net / ns{1,2,3,4,5}.he.net
          "216.218.133.2"
          "2001:470:600::2"
        ];
in{
  services.bind = {
    enable = true;
    listenOn = [
      "116.202.236.241"
    ];
    listenOnIpv6 = [
      "2a01:4f8:241:4faa::0"
    ];
    cacheNetworks = [
      "116.202.236.241"
      "2a01:4f8:241:4faa::/96"
    ];
    zones = {
      "lesgrandsvoisins.com" = {
        file = ../etc/bind/zone_lesgrandsvoisins_com.txt;
        # master = true;
        allowQuery = ["any"];
        # slaves = dnsslaves;
      };
      "resdigita.com" = {
        file = ../etc/bind/zone_resdigita_com.txt;
        # master = true;
        allowQuery = ["any"];
        # slaves = dnsslaves;
      };
      # "241.236.202.in-addr.arpa"= {
      #   master = true;
      #   allowQuery = ["any"];
      #   file = /var/zone_reverse_lesgrandsvoisins_com.txt;
      # };
    };
  };
}