{ config, pkgs, lib, ... }:
let 
in
{ 
  #   # lower,map(/etc/haproxy_domain_back.map)]

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

frontend http-front-4
  mode http
  bind 0.0.0.0:81
  default_backend http-back-4

frontend http-front-6
  mode http
  bind [::]:81
  default_backend http-back-6

frontend https-in
  mode tcp
  bind *:443
  bind [::]:443
  acl tls req.ssl_hello_type 1
  tcp-request inspect-delay 5s
  tcp-request content accept if tls
  use_backend %[req.ssl_sni]
  default_backend https

backend http-back-4 
  mode http
  server nginx-4 0.0.0.0:80 maxconn 32

backend http-back-6 
  mode http
  server nginx-4 [::]:80 maxconn 32

backend https
  mode tcp
  server server1 fontenay.gdvoisins.com:443 maxconn 32

backend fs.roses.gdvoisins.com
  server fs fs.roses.gdvoisins.com:445

backend cp.roses.gdvoisins.com
  server cp cp.roses.gdvoisins.com:445

backend public.cp.roses.gdvoisins.com
  server public.cp public.cp.roses.gdvoisins.com:445

backend co.roses.gdvoisins.com
  server co co.roses.gdvoisins.com:445

backend static.roses.gdvoisins.com
  server static static.roses.gdvoisins.com:445

backend roses.gdvoisins.com
  server roses roses.gdvoisins.com:445

backend fontenay.gdvoisins.com
  server fontenay fontenay.gdvoisins.com:445
    '';
  };
}