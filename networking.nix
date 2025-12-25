{ config, pkgs, lib, ... }:
let
in
{
  # Networking
  networking = {
    hostName = "hetzner005"; # Define your hostname
    useDHCP = true;
    enableIPv6 = true;
    # bridges = {
    #   brkey = {
    #     interfaces = [
    #       "eno1"
    #     ];
    #   };
    # };
    # interfaces.brkey = {
    #   useDHCP = false;
    #   ipv6.addresses = {
    #     address = "2a01:4f8:241:4faa::443";
    #     prefixLength = 120;
    #   };
    # };
    interfaces.eno1.ipv6 = {
      addresses = [
        { address = "2a01:4f8:241:4faa::0"; prefixLength = 126; }
        { address = "2a01:4f8:241:4faa::4"; prefixLength = 126; }
        { address = "2a01:4f8:241:4faa::10"; prefixLength = 125; }
        { address = "2a01:4f8:241:4faa::443"; prefixLength = 120; }
      ];
      # routes = [
      #   {
      #     address = "2a01:4f8:241:4faa::11";
      #     prefixLength = 125;
      #     via = "2a01:4f8:241:4faa::10";
      #     type = "unicast";
      #   }
      # ];
      # routes = [
      #   {
      #     address = "2a01:4f8:241:4faa::11";
      #     prefixLength = 125;
      #     via = "fc00::12:2";
      #     type = "unicast";
      #   }
      # ];
    };
    
    nat = {
      forwardPorts = [
        {
          destination = "192.168.103.2:443";
          proto = "tcp";
          sourcePort = 11443;
        }
        {
          destination = "192.168.105.11:14443";
          proto = "tcp";
          sourcePort = 14443;
        }
      ];
    };
    # firewall.enable = false;
    nftables.enable = true;
    firewall = {
      extraForwardRules = ''
        ip6 saddr 2a01:4f8:241:4faa::10 tcp dnat to fa01::2
      '';
      enable = true;
      package = pkgs.nftables;
      trustedInterfaces = [ "docker0" "lxdbr1" "lxdbr0" "ve-silverbullet" "ve-openldap" "ve-key" "lo"];
      interfaces."ve-key-postgres".allowedTCPPorts = [5432];

      # source: https://docs.syncthing.net/users/firewall.html
      # interfaces."eno1".allowedTCPPorts = [

      #   22
      #   25
      #   53
      #   80
      #   143
      #   443
      #   587
      #   # 636
      #   993
      #   995
      #   1360
      #   8384
      #   8443
      #   9080
      #   9443
      #   10080
      #   10389
      #   10443
      #   10636
      #   11211
      #   11443
      #   11447
      #   12080
      #   12443
      #   14389
      #   14443
      #   14636
      #   20000
      #   21027
      #   22000
      # ];
      allowedTCPPorts = [
        22
        25
        53
        80
        143
        443
        444
        587
        # 636
        993
        995
        1360
        4443
        4444
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
        11447
        12080
        12443
        14389
        14443
        14636
        20000
        21027
        22000
        41443
      ];
      allowedUDPPorts = [
        53
      ];
    };
  };
}
