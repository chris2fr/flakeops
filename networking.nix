{ config, pkgs, lib, ... }:
let
in
{
  # Networking
  networking = {
    hostName = "hetzner005"; # Define your hostname
    useDHCP = true;
    enableIPv6 = true;
    interfaces.eno1.ipv6 = {
      addresses = [
        { address = "2a01:4f8:241:4faa::0"; prefixLength = 96; }
      ];
    };
    nat = {
      forwardPorts = [
        {
          destination = "192.168.103.2:443";
          proto = "tcp";
          sourcePort = 11443;
        }
      ];
    };
    # firewall.enable = false;
    nftables.enable = true;
    firewall = {
      enable = true;
      package = pkgs.nftables;
      trustedInterfaces = [ "docker0" "lxdbr1" "lxdbr0" "ve-silverbullet" "ve-openldap" "lo" ];
      # source: https://docs.syncthing.net/users/firewall.html
      allowedTCPPorts = [
        22
        25
        53
        80
        143
        443
        587
        636
        993
        995
        1360
        8384
        8443
        9080
        9443
        10080
        10389
        10443
        10636
        11211
        11443
        12080
        12443
        14389
        14443
        14636
        20000
        21027
        22000
      ];
      allowedUDPPorts = [
        53
      ];
    };
  };
}
