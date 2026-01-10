{
  config,
  pkgs,
  lib,
  ...
}: let
in {
  # Networking
  # services.resolved = {
  #   domains = ["www.lesgrandsvoisins.com" "lesgrandsvoisins.com"];
  #   fallbackDns = ["9.9.9.9" "149.112.112.112"];
  # };

  systemd.network = {
    enable = true;
    # netdevs = {
    #   "20-br0" = {
    #     netdevConfig = {
    #       Kind = "bridge";
    #       Name = "br0";
    #     };
    #   };
    # };
    # networks = {
    #   "10-uplink" = {
    #     matchConfig.Name = lib.mkDefault "enp1s0";
    #     networkConfig = {
    #       DHCP = "ipv4";
    #       # IPv6AcceptRA = true;
    #       Bridge = "br0";
    #     };
    #     dhcpV4Config = {UseDNS = false;};
    #     linkConfig.RequiredForOnline = "routable";
    #   };
    #   "20-br0" = {
    #     matchConfig.Name = "br0";
    #     networkConfig = {DHCPServer = true;};
    #     dhcpServerConfig = {ServerAddress = "192.168.105.10/18";};
    #     linkConfig = {RequiredForOnline = "routable";};
    #   };
    #   "40-vb" = {
    #     matchConfig.Name = "vb-*";
    #     networkConfig = {DHCP = "ipv4";};
    #   };
    # };
  };
  networking = {
    useNetworkd = true;
    enableIPv6 = true;
    domain = "lesgrandsvoisins.com";
    hostName = "hetzner005";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eno1";
    };
    interfaces.eno1 = {
      useDHCP = true;
      ipv6 = {
        addresses = [
          {
            address = "2a01:4f8:241:4faa::";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::1";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::2";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::3";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::4";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::5";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::6";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::7";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::8";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::9";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::10";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::11";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::12";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::13";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::14";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::15";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::16";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::17";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::18";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::19";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::20";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::21";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::22";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::23";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::24";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::25";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::26";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::27";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::28";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::29";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::30";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::31";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::32";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::33";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::34";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::35";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::36";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::37";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::38";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::39";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::1:1:1";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::2:2:2";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::3:3:3";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:241:4faa::4:4:4";
            prefixLength = 64;
          }
        ];
      };
    };
    # appendNameservers = ["2a01:4ff:ff00::add:1" "2a01:4ff:ff00::add:2" "8.8.8.8" "1.1.1.1"];
    nat = {
      enable = true;
      internalInterfaces = ["ve-*"];
      externalInterface = "eno1";
      enableIPv6 = true;
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
      trustedInterfaces = ["docker0" "lxdbr1" "lxdbr0" "ve-silverbullet" "ve-openldap" "ve-key" "lo"];
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
