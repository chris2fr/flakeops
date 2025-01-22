{ config, pkgs, lib, ... }:
let 
  allowedTCPPorts = [ 22 80 443 636 53 111 2049 ];
  allowedUDPPorts = [ 53 67 68 123 111 2049 4000 4001 4002 20048 ];
in {
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 636 53 111 2049 ];
      allowedUDPPorts = [ 53 67 68 123 111 2049 4000 4001 4002 ];
      trustedInterfaces = ["eno2" "enp3s0f0"];
      interfaces."eno2" = {
        allowedTCPPorts = allowedTCPPorts;
        allowedUDPPorts = allowedUDPPorts;
      };
      interfaces."enp3s0f0" = {
        allowedTCPPorts = allowedTCPPorts;
        allowedUDPPorts = allowedUDPPorts;
      };
    };
    hostName = "rosest330"; 
    enableIPv6 = true;
  };
}
