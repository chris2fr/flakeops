{
  config,
  pkgs,
  lib,
  # vars,
  ...
}: let
  allowedTCPPorts = [22 80 81 82 83 84 85 86 87 88 443 444 445 446 447 448 449 450 451 452 453 454 455 636 53 111 2049 8088 41443 8334 30746 41443];
  allowedUDPPorts = [53 67 68 123 111 2049 4000 4001 4002 20048];
in {
  # services.bind = {
  #   enable = false;
  #   zones = {
  #     "roses.gdvoisins.com" = {
  #       master = true;
  #       file = "/etc/haproxy_dns_gdvoisins";
  #     };
  #   };
  # };
  networking = {
    useNetworkd = true;
    domain = "roses.gdvoisins.com";
    # hostName = "rosest330";
    # defaultGateway6 = {
    #   address = "fe80::6aa3:78ff:fe11:d1ae";
    #   interface = "eno1";
    # };
    interfaces.eno1 = {
      useDHCP = true;
      ipv6 = {
        addresses = [
          {
            address = "2a01:e0a:f4e:5880::1000";
            prefixLength = 64;
          }
          {
            address = "2a01:e0a:f4e:5880::1001";
            prefixLength = 64;
          }
          {
            address = "2a01:e0a:f4e:5880::1002";
            prefixLength = 64;
          }
          {
            address = "2a01:e0a:f4e:5880::1003";
            prefixLength = 64;
          }
          {
            address = "2a01:e0a:f4e:5880::1004";
            prefixLength = 64;
          }
          {
            address = "2a01:e0a:f4e:5880::1005";
            prefixLength = 64;
          }
          {
            address = "2a01:e0a:f4e:5880::1006";
            prefixLength = 64;
          }
          {
            address = "2a01:e0a:f4e:5880::1007";
            prefixLength = 64;
          }
          {
            address = "2a01:e0a:f4e:5880::1008";
            prefixLength = 64;
          }
          {
            address = "2a01:e0a:f4e:5880::1009";
            prefixLength = 64;
          }
        ];
      };
    };
    hosts = {
      "127.0.0.1" = ["localhost"];
      "::1" = ["localhost"];
      "127.0.0.2" = ["rosest330"];
      "192.168.1.100" = ["op.roses.gdvoisins.com"];
      "2a01:e0a:f4e:5880::9316:9fe2" = ["op.roses.gdvoisins.com"];
    };
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
      # trustedInterfaces = ["lo" "eno1" "eno2" "enp3s0f0"];
      trustedInterfaces = ["lo" "eno1" "eno2" "enp3s0f0"];
      interfaces."eno1" = {
        allowedTCPPorts = allowedTCPPorts;
      };
    };
    hostName = "rosest330";
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
