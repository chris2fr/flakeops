{ config, pkgs, lib, ... }:
let 
  mod_auth_openidc = pkgs.callPackage ./derivations/mod_auth_openidc.nix {};
  # oidcseafilesecret = import secrets/oidcseafile.nix;
in
{ 
  age.secrets = {
    # "filebrowser" = { file = ./secrets/filebrowser.age; owner="wwwrun";};
    "openidc.seafile" = { file = ./secrets/openidc.seafile.age; owner="wwwrun";};
    # "httpd.filebrowser.conf" = { file = ./secrets/httpd.filebrowser.conf.age; owner="wwwrun";};
    # "httpd.newuser.conf" = { file = ./secrets/httpd.newuser.conf.age; owner="wwwrun";};
  };
  environment.systemPackages = with pkgs; [ curl cjose ];
  services = {
    httpd = {
      enable = true;
      package = pkgs.apacheHttpd;
      enablePHP = false;
      extraConfig = ''
        KeepAlive On
        MaxKeepAliveRequests 100
        KeepAliveTimeout 3
        Protocols h2 http/1.1
      '';
      adminAddr = "chris@lesgrandsvoisins.com";
      extraModules = [ 
      #   "proxy" 
      #   "proxy_http" 
      #   "dav" 
      #   "ldap" 
      #   "authnz_ldap" 
      #   "alias" 
      #   "ssl" 
      #   "rewrite" 
      #   "proxy_fcgi" 
      #   "http2" 
      #   "proxy_uwsgi"
        { 
          name = "auth_openidc"; 
          path = "${mod_auth_openidc}/modules/mod_auth_openidc.so"; 
        }
      ];
      virtualHosts = {
        "roses.lgv.info" = {
          forceSSL = true;
          enableACME = true;
          # listen = [{port = 443; ssl=true;}];
          # sslServerCert = "/var/lib/acme/roses.lgv.info/fullchain.pem";
          # sslServerChain = "/var/lib/acme/roses.lgv.info/fullchain.pem";
          # sslServerKey = "/var/lib/acme/roses.lgv.info/key.pem";
          documentRoot = "/var/www/default";
          extraConfig = ''
            OIDCProviderMetadataURL https://key.lesgrandsvoisins.com/realms/master/.well-known/openid-configuration
            OIDCClientID seafile
            Include /etc/.secrets/.apache2.oidcclientsecret.seafile
            OIDCRedirectURI https://roses.lgv.info/redirect_uri_from_oauth2
            
            <Location /protected>
              AuthType openid-connect
              Require valid-user
            </Location>
          '';


          # extraConfig = ''
          #   ProxyPreserveHost On
          #   # ProxyVia On
          #   ProxyAddHeaders On
          #   OIDCProviderMetadataURL https://key.lesgrandsvoisins.com/realms/master/.well-known/openid-configuration
          #   OIDCClientID seafile
          #   OIDCClientSecret open("/etc/.secrets/.seafile_client_secret").read().strip()
          #   OIDCRedirectURI https://roses.lgv.info/redirect_uri_from_oauth2
          #   OIDCCryptoPassphrase UMU0I51HADokJraIaBSjpI89zhnGjuhv
          #   <Location "/">
          #     AuthType openid-connect
          #     Require valid-user
          #     # # ProxyPass unix:/opt/filebrowser/dbs/filebrowser/maruftuyel/filebrowser.sock|http://127.0.0.1/
          #     # # ProxyPass unix:/opt/filebrowser/dbs/filebrowser/%{env:MATCH_USERNAME}/filebrowser.sock|http://filebrowser.resdigita.com/
          #     # RequestHeader set FileBrowserUser %{env:OIDC_CLAIM_username}s  
          #     # RequestHeader set X-Forwarded-Proto "https"
          #     # RequestHeader set X-Forwarded-Port "443"
          #     # RequestHeader set X-Forwarded-For "$proxy_add_x_forwarded_for"
          #     # RequestHeader set Host $host
          #   </Location>
          # '';
        };
      };
    };
  };

  # users.users.wwwrun.extraGroups = [ 
  #   "acme" 
  #   # "wagtail" 
  #   "users" 
  #   #"ghost" 
  #   #"ghostio" 
  #   #"guichet" 
  # ];
}