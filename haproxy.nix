{ config, pkgs, lib, ... }:
let 
in
{ 
  services.haproxy = {
    enable = true;
    config = ''
      global
        daemon
        maxconn 256

      defaults
        mode http
        timeout connect 5000ms
        timeout client 50000ms
        timeout server 50000ms

      frontend http-in
          bind *:81
          default_backend servers

      backend servers
          server server1 static.roses.gdvoisins.com:80 maxconn 32

    '';
  };
}