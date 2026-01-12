{ config, pkgs, lib, ... }:
let 
in
{ 
  #   # lower,map(/etc/haproxy_domain_back.map)]

  services.haproxy = {
    enable = false;
    config = ''
  daemon
  maxconn 256

defaults
  mode tcp
  timeout connect 5000ms
  timeout client 50000ms
  timeout server 50000ms

resolvers mynameservers
  nameserver ns1 192.168.1.100:111



frontend http-front-4
  mode http
  bind 0.0.0.0:82
  default_backend http-back-4

frontend http-front-6
  mode http
  bind [::]:82
  default_backend http-back-6

frontend https-front-4
  mode tcp
  bind *:445
  acl tls req.ssl_hello_type 1
  tcp-request inspect-delay 5s
  tcp-request content accept if tls
  use_backend %[req.ssl_sni,lower,map(/etc/haproxy_domain_back.map)]
  default_backend https-back-4

frontend https-front-6
  mode tcp
  bind [::]:445
  acl tls req.ssl_hello_type 1
  tcp-request inspect-delay 5s
  tcp-request content accept if tls
  use_backend %[req.ssl_sni,lower,map(/etc/haproxy_domain_back.map)]
  default_backend https-back-6

backend http-back-4 
  mode http
  server nginx-4 127.0.0.1:82 maxconn 32

backend http-back-6 
  mode http
  server nginx-4 [::1]:82 maxconn 32

backend https
  mode tcp
  server server1 fontenay.gdvoisins.com:443 maxconn 32

backend https-back-4
  mode tcp
  server server4 public.cp.roses.gdvoisins.com:443 maxconn 32
  # server server4 cp.roses.gdvoisins.com:443 maxconn 32 check resolvers mynameservers
  # server server4 127.0.0.1:443 maxconn 32

backend https-back-6
  mode tcp
  server server6 public.cp.roses.gdvoisins.com:443 maxconn 32 
  # server server6 cp.roses.gdvoisins.com:443 maxconn 32 check resolvers mynameservers
  # server server6 [::1]:443 maxconn 32

backend fs
  server fs fs.roses.gdvoisins.com:443

backend cp
  server cp cp.roses.gdvoisins.com:443

backend public-cp
  server public.cp public.cp.roses.gdvoisins.com:443

backend co
  server co co.roses.gdvoisins.com:443

backend static
  server static static.roses.gdvoisins.com:443

backend roses
  server roses roses.gdvoisins.com:443

backend fontenay
  server fontenay fontenay.gdvoisins.com:443
  
    '';
  };
}