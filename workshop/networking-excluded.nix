{ config, pkgs, lib, ... }:
let
in 
{
  # Networking
  networking = {
    # hostName = "mail"; # Define your hostname.
    # networkmanager.enable = true;  # Easiest to use and most distros use this by default.
    interfaces.eno1.ipv6 = {
      addresses = [
        # { address = "2a01:4f8:241:4faa::1"; prefixLength = 96; }
        # { address = "2a01:4f8:241:4faa::2"; prefixLength = 96; }
        # { address = "2a01:4f8:241:4faa::3"; prefixLength = 96; }
        # { address = "2a01:4f8:241:4faa::4"; prefixLength = 96; }
        # { address = "2a01:4f8:241:4faa::5"; prefixLength = 96; }
        # { address = "2a01:4f8:241:4faa::6"; prefixLength = 96; }
        # { address = "2a01:4f8:241:4faa::7"; prefixLength = 96; }
        # { address = "2a01:4f8:241:4faa::8"; prefixLength = 96; }
        # { address = "2a01:4f8:241:4faa::9"; prefixLength = 96; }
        # { address = "2a01:4f8:241:4faa::10"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::11"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::12"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::13"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::14"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::15"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::16"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::17"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::18"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::19"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::20"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::21"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::22"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::23"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::24"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::25"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::26"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::27"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::28"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::29"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::30"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::31"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::32"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::33"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::34"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::35"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::36"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::37"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::38"; prefixLength = 96; }
        #     { address = "2a01:4f8:241:4faa::39"; prefixLength = 96; }
      ];
      # routes = [
      #   {
      #     address = "2a01:4f8:241:4faa::";
      #     prefixLength = 96;
      #     via = "fe80::329c:23ff:fed3:5162";
      #   }
      # ];
    };
    # defaultGateway6 = {
    #   # address = "fe80::1";
    #   address = "2a01:4f8:241:4faa::0";
    #   interface = "eno1";
    # };
    nat = {
      # {
      #   destination = "192.168.105.11:14443";
      #   proto = "tcp";
      #   sourcePort = 1443;
      # }
      # {
      #   destination = "192.168.105.11:12443";
      #   proto = "tcp";
      #   sourcePort = 12443;
      # }
      # {
      #   destination = "192.168.107.11:10389";
      #   proto = "tcp";
      #   sourcePort = 10389;
      #   # loopbackIPs = ["116.202.236.241" "2a01:4f8:241:4faa::"];
      # }
      # {
      #   destination = "192.168.107.11:10636";
      #   proto = "tcp";
      #   sourcePort = 10636;
      # }
      # {
      #   destination = "192.168.107.11:10389";
      #   proto = "tcp";
      #   sourcePort = 10389;
      # }
      # {
      #   destination = "192.168.107.11:10636";
      #   proto = "tcp";
      #   sourcePort = 10636;
      # }
      ];
    };
    # firewall.enable = false;
    firewall ={
      # Syncthing ports: 8384 for remote access to GUI
      # 22000 TCP and/or UDP for sync traffic
      # 21027/UDP for discovery
    };
  };
}