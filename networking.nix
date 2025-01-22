{ config, pkgs, lib, ... }:
let 
in {
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 636 53 ];
      allowedUDPPorts = [ 53 67 68 123 ];
    };
    hostName = "rosest330"; 
    enableIPv6 = true;
  };
}
