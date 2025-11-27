{ config, pkgs, lib, ... }:
let 
in
{ 
  services.haproxy = {
    enable = true;
    config = ''
  daemon
  maxconn 256

defaults
  mode tcp
  timeout connect 5000ms
  timeout client 50000ms
  timeout server 50000ms

frontend http-in
    bind *:82
    bind [::]:82
    default_backend http

frontend https-in
  mode tcp
  bind *:445
  bind [::]:445
  acl tls req.ssl_hello_type 1
  tcp-request inspect-delay 5s
  tcp-request content accept if tls
  use_backend %[req.ssl_sni,lower,map(/etc/haproxy_domain_back.map)]
  default_backend https

backend http 
  server server1 127.0.0.1:8083 maxconn 32

# backend https
#   mode tcp
#   use-server fs if req.ssl_sni -i fs.roses.gdvoisins.com
#   use-server cp if req.ssl_sni -i cp.roses.gdvoisins.com
#   use-server public.cp if req.ssl_sni -i public.cp.roses.gdvoisins.com
#   use-server co if req.ssl_sni -i co.roses.gdvoisins.com
#   use-server static if req.ssl_sni -i static.roses.gdvoisins.com
#   use-server roses if req.ssl_sni -i roses.gdvoisins.com
#   use-server fontenay if req.ssl_sni -i fontenay.gdvoisins.com

backend https
  mode tcp
  server server1 fontenay.gdvoisins.com:443 maxconn 32

backend fs
  server fs fs.roses.gdvoisins.com:444

backend cp
  server cp cp.roses.gdvoisins.com:444

backend public.cp
  server public.cp public.cp.roses.gdvoisins.com:444

backend co
  server co co.roses.gdvoisins.com:444

backend static
  server static static.roses.gdvoisins.com:444

backend roses
  server roses roses.gdvoisins.com:444

backend fontenay
  server fontenay fontenay.gdvoisins.com:444




    '';
  };
}