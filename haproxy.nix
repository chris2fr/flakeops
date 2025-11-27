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
          default_backend server

      frontend https-in
          bind *:445 ssl
          ssl-f-use crt /var/lib/acme/roses.lgv.info/fullchain.pem key /var/lib/acme/roses.lgv.info/key.pem
          http-request return status 200 content-type text/plain lf-string "%[path,field(-1,/)].%[path,field(-1,/),map(virt@acme)]\n" if { path_beg '/.well-known/acme-challenge/' }
          default_backend server

      backend server
          server server1 static.roses.gdvoisins.com:80 maxconn 32

    '';
  };
}