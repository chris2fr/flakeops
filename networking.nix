{ config, pkgs, lib, ... }:
let 
in {
  # Networking
  networking.firewall.allowedTCPPorts = [ 22 80 443 636 ];
  # networking.networkmanager = {
  #   enable = true;
  #   dhcp = "dhcpcd";
  # };
  networking.hostName = "rosest330"; # Define your hostname.
  networking.enableIPv6 = true;
  # networking.firewall.package
  networking.nftables.enable = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  # networking.nftables.enable = true;

  services.openssh.openFirewall = false;
  networking.firewall = {
    enable = false;
    # package = pkgs.nftables;
    trustedInterfaces = [ "eno2" ];
    # interfaces."eno2".allowedTCPPorts = [ 22 ];
    # allowedTCPPorts = [ 22222 ];
    allowPing = true;
    # checkReversePath = "loose";
    # interfaces."eno3".allowedTCPPorts = [ 22222 ];
    # extraInputRules = ''
    # tcp dport {22222} counter packets 0 bytes 0 accept comment "Accept SSH Port from everywhere with no rate limit"
    # tcp dport {22222} ct state new limit rate 15/minute accept comment "Accept custom SSH Port and avoid brute force on SSH"
    # '';
    # # Open ports in the firewall.
    # # allowedTCPPorts = [ ... ];
    # # allowedUDPPorts = [111 2049 4000 4001 4002 20048 ];
    # # allowedUDPPorts = [ ... ];
    # # allowedTCPPorts = [ 2049 ];
    # # Or disable the firewall altogether.
    # # enable = false;
     interfaces = {
        eno3 = {
          allowedTCPPorts = [
            53
            22222
          ];
          allowedUDPPorts = [
            53
            67
            68
            123
          ];
        };
     };
  };
}