{ config, pkgs, lib, ... }:
let 
  allowedTCPPorts = [ 22 80 443 636 53 111 2049 ];
  allowedUDPPorts = [ 53 67 68 123 111 2049 4000 4001 4002 20048 ];
in {
  networking = {
    nftables = {
      enable = true;
    };
    firewall = {
      enable = true;
      trustedInterfaces = ["lo" "eno2" "enp3s0f0"];
      interfaces."eno1" = {
        allowedTCPPorts = [22 80 443];
      };
    };
    hostName = "rosest330"; 
    enableIPv6 = true;
  };
}
