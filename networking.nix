{ config, pkgs, lib, ... }:
let 
  allowedTCPPorts = [ 22 80 81 82 443 444 445 636 53 111 2049 8088 41443 8334 30746];
  allowedUDPPorts = [ 53 67 68 123 111 2049 4000 4001 4002 20048 ];
in {
  networking = {
    nftables = {
      enable = true;
    };
    # bridges = {
    #   br0 = {
    #     interfaces = ["tuncontain"];
    #   };
    # };
    firewall = {
      enable = true;
      # trustedInterfaces = ["lo" "eno1" "eno2" "enp3s0f0" "ve-filestash"];
      trustedInterfaces = ["lo" "eno1" "eno2" "enp3s0f0" ];
      interfaces."eno1" = {
        allowedTCPPorts = allowedTCPPorts;
      };
    };
    hostName = "roses.gdvoisins.com"; 
    enableIPv6 = true;
    nat = {
      enable = true;
      # Use "ve-*" when using nftables instead of iptables
      internalInterfaces = ["ve-*"];
      externalInterface = "eno1";
      # Lazy IPv6 connectivity for the container
      enableIPv6 = true;
    };
    # interfaces."tuncontain" = {
    #   useDHCP = false;
    #   virtual = true;
    #   name = "tuncontain";
    #   ipv4.addresses = [{
    #     address = "192.168.101.1";
    #     prefixLength = 24;
    #   }];
    #   ipv6.addresses = [{
    #     address = "fa80::1";
    #     prefixLength = 96;
    #   }];
    # };
  };
}
