{ config, pkgs, lib, ... }:
let 
in {
  # Networking
  networking.firewall.allowedTCPPorts = [ 22 80 443 636 ];
  # networking.networkmanager = {
  #   enable = true;
  #   dhcp = "dhcpcd";
  # };
  networking.hostName = "t330roses"; # Define your hostname.
  networking.enableIPv6 = true;
  # networking.firewall.package
  networking.nftables.enable = true;
}