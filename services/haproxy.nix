{ config, pkgs, lib, ... }:
let
in {
  services.haproxy = {
    enable = true;
    config = ''
      global
        daemon
        maxconn 1000

      defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        option  forwardfor
        timeout connect 10s
        timeout client  60s
        timeout server  60s
        errorfile 400 /var/log/haproxy/errors/400.http
        errorfile 403 /var/log/haproxy/errors/403.http
        errorfile 408 /var/log/haproxy/errors/408.http
        errorfile 500 /var/log/haproxy/errors/500.http
        errorfile 502 /var/log/haproxy/errors/502.http
        errorfile 503 /var/log/haproxy/errors/503.http
        errorfile 504 /var/log/haproxy/errors/504.http

      listen http-in
        bind :9080
        default_backend homepage-dashboard.resdigita.com:9443

      listen https-in
        mode http
        bind :9443 ssl crt-list /var/lib/acme/crt-list.txt
        option forwardfor
        # redirect scheme https 
        http-request set-header X-Forwarded-Proto https if { ssl_fc }
        http-request set-header X-Forwarded-Proto http if !{ ssl_fc }
        http-request redirect scheme https unless { ssl_fc }
        acl ACL_resdigita.com hdr(host) -i resdigita.com:9443
        http-request redirect location https://quartz.resdigita.com:9443 if ACL_resdigita.com
        use_backend %[req.hdr(Host),lower]
        default_backend homepage-dashboard.resdigita.com:9443
        # default_backend mail.lesgrandsvoisins.com
          
        # # acl nothttps scheme_str http
        # # redirect location https://homepage-dashboard.resdigita.com unless secure
        # # redirect location https://%[env(HOSTNAME)]:9443 if scheme str "http"
        # # acl sslv req.ssl_ver gt 2
        # # redirect scheme https if !sslv 
        # # redirect scheme https if !{ req.ssl_hello_type gt 0 }
        # # use_backend homepage-dashboard if server_ssl
        # option             forwardfor
        # acl ACL_nginx hdr(host) -i www.lesgrandsvoisins.com lesgrandsvoisins.com quartz.resdigita.com hedgedoc.resdigita.com crabfit.resdigita.com
        # acl ACL_httpd hdr(host) -i dav.resdigita.com keepass.resdigita.com keeweb.resdigita.com

        # use_backend nginx if ACL_nginx
        # use_backend httpd if ACL_httpd

        # # use_backend wagtail if ACL_www.lesgrandsvoisins.com
        # # acl ACL_quartz.resdigita.com hdr(host) -i quartz.resdigita.com
        # # use_backend quartz.resdigita.com if ACL_quartz.resdigita.com
        # # acl ACL_hedgedoc.resdigita.com hdr(host) -i hedgedoc.resdigita.com
        # # use_backend hedgedoc.resdigita.com if ACL_hedgedoc.resdigita.com
        # # acl ACL_crabfit.resdigita.com hdr(host) -i crabfit.resdigita.com
        # # use_backend crabfit.resdigita.com if ACL_crabfit.resdigita.com

        # default_backend https-homepage-dashboard

      # frontend wagtail
      #   bind www.lesgrandsvoisins.com:9443 ssl crt /var/lib/acme/www.lesgrandsvoisins.com/full.pem
      #   bind lesgrandsvoisins.com:9443 ssl crt /var/lib/acme/www.lesgrandsvoisins.com/full.pem
      #   http-request redirect scheme https unless { ssl_fc }
      #   default_backend wagtail

      backend hedgedoc.resdigita.com:9443
        server server1 127.0.0.1:3333 maxconn 64

      backend crabfit.resdigita.com:9443
        server server1 127.0.0.1:3080 maxconn 64

      backend authentik.resdigita.com:9443
        option forwardfor
        server server1 10.245.101.35:9000 maxconn 64

      # Still in debug mode. Put in cache mode please.
      backend homepage-dashboard.resdigita.com:9443
        server server1 127.0.0.1:8882 maxconn 64

      backend https-homepage-dashboard:9443
        server server1 homepage-dashboard.resdigita.com:443 maxconn 64

      backend nginx
        server server1 127.0.0.1:443 maxconn 64

      backend httpd
        server server1 127.0.0.1:8443 maxconn 64

      backend mail.lesgrandsvoisins.com:9443
        option forwardfor
        server server1 /run/phpfpm/roundcube.sock
         
      backend blog.lesgrandsvoisins.com:9443
        option forwardfor
        server server1 127.0.0.1:2368

      backend keepass.resdigita.com:9443
        server server1 keepass.resdigita.com:8443

      backend odoo1.resdigita.com:9443
        server server1 10.245.101.158:8069
        
      backend odoo2.resdigita.com:9443
        server server1 10.245.101.82:8069

      backend odoo3.resdigita.com:9443
        server server1 10.245.101.128:8069

      backend odoo4.resdigita.com:9443
        server server1 10.245.101.173:8069
        
      backend quartz.resdigita.com:9443
        server server1 quartz.resdigita.com:443

      backend guichet.resdigita.com:9443
        server server1 [::1]:9991

      backend dav.resdigita.com:9443
        server server1 127.0.0.1:8443

      backend wagtail.resdigita.com:9443
        server server1 wagtail.resdigita.com:8443

      backend keeweb.resdigita.com:9443
        server server1 keeweb.resdigita.com:8443

      backend filebrowser.resdigita.com:9443
        server server1 filebrowser.resdigita.com:8443

      backend chris.resdigita.com:9443
        server server1 chris.resdigita.com:8443

      backend axel.resdigita.com:9443
        server server1 axel.resdigita.com:8443

      backend maruftuyel.resdigita.com:9443
        server server1 maruftuyel.resdigita.com:8443

      backend mail.resdigita.com:9443
        server server1 /run/phpfpm/roundcube.sock

      resolvers dnsresolve
        parse-resolv-conf
        # nameserver googledns1ipv6 [2001:4860:4860::8888]:53
        # nameserver googledns2ipv6 [2001:4860:4860::8844]:53
        # nameserver googledns1ipv4 8.8.8.8:53
        # nameserver googledns2ipv4 8.8.4.4:53

    '';
  };
}
