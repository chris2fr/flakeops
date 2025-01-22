{ config, pkgs, lib, ... }:
let 
in {
  # Networking
  networking.firewall.allowedTCPPorts = [ 22 80 443 636 ];
  networking.hostName = "rosest330"; # Define your hostname.
  networking.enableIPv6 = true;
  networking.nftables.enable = true;
}