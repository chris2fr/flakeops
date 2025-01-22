{ config, pkgs, lib, ... }:
let 
  allowedTCPPorts = [ 22 80 443 636 53 111 2049 ];
  allowedUDPPorts = [ 53 67 68 123 111 2049 4000 4001 4002 20048 ];
in {
  networking = {
    nftables = {
      enable = false;
      flushRuleset = true;
      ruleset = ''
        # Check out https://wiki.nftables.org/ for better documentation.
        # Table for both IPv4 and IPv6.
        table inet filter {
          # Block all incoming connections traffic except SSH and "ping".
          chain input {
            # accept any localhost traffic
            iifname "lo" accept
            # accept any lan traffic
            iifname "enp3s0f0" accept
            # accept any management traffic
            iifname "eno2" accept
            # accept traffic originated from us
            ct state {established, related} accept
            # allow "ping"
            ip6 nexthdr icmpv6 icmpv6 type echo-request accept
            ip protocol icmp icmp type echo-request accept
            # accept SSH connections (required for a server)
            tcp dport 22 accept
            tcp dport 80 accept
            tcp dport 443 accept
            tcp dport 636 accept
            tcp dport 53 accept
            tcp dport 111 accept
            tcp dport 2049 accept
            tcp dport 4000-4002 accept
            udp dport 53 accept
            udp dport 111 accept
            udp dport 2049 accept
            udp dport 4000-4002 accept
            # count and drop any other traffic
            counter drop
          }
          # Allow all outgoing connections.
          chain output {
            type filter hook output priority 0;
            accept
          }
          chain forward {
            type filter hook forward priority 0;
            accept
          }
        }
      '';
    };
    firewall = {
      enable = false;
      # allowedTCPPorts = [ 22 80 443 636 53 111 2049 ];
      # allowedUDPPorts = [ 53 67 68 123 111 2049 4000 4001 4002 ];
      # trustedInterfaces = ["eno2" "enp3s0f0"];
      # interfaces."eno2" = {
      #   allowedTCPPorts = allowedTCPPorts;
      #   allowedUDPPorts = allowedUDPPorts;
      # };
      # interfaces."enp3s0f0" = {
      #   allowedTCPPorts = allowedTCPPorts;
      #   allowedUDPPorts = allowedUDPPorts;
      # };
    };
    hostName = "rosest330"; 
    enableIPv6 = true;
  };
}
