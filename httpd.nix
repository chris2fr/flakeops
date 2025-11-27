{ config, pkgs, lib, ... }:
let 
  # mod_auth_openidc = pkgs.callPackage ./derivations/mod_auth_openidc-binary.nix {};
  # oidcseafilesecret = import secrets/oidcseafile.nix;
  listen = [
            # {ip= "192.168.1.100"; port = 445 ; ssl = true ; }
            # {ip= "192.168.1.100"; port = 82 ; }
            # {ip= "[2a01:e0a:f4e:5880::9316:9fe2]"; port = 445 ; ssl = true ; }
            # {ip= "[2a01:e0a:f4e:5880::9316:9fe2]"; port = 82 ; }
            {ip= "192.168.1.100"; port = 445 ; ssl = true ; }
            {ip= "192.168.1.100"; port = 82 ; }
            {ip= "[2a01:e0a:f4e:5880:0000:0000:9316:9fe2]"; port = 445 ; ssl = true ; }
            {ip= "[2a01:e0a:f4e:5880:0000:0000:9316:9fe2]"; port = 82 ; }
          ];
in
{ 
  environment.systemPackages = with pkgs; [ curl cjose apr aprutil ];
  systemd.tmpfiles.rules = [
    "d /var/lib/mellon/ 1770 wwwrun users"
    "d /var/lib/mellon/cache 1770 wwwrun users"
    "d /etc/mellon 0770 root wwwrun"
    "d /var/lib/copyparty/ssl 0770 wwwrun users"
  ];
  services = {
    httpd = {
      extraModules = [ 
        "remoteip"
        "proxy" 
        "proxy_http" 
        # "dav" 
        # "ldap" 
        # "authnz_ldap" 
        "alias" 
        "ssl" 
        "rewrite" 
        # "proxy_fcgi" 
        "http2" 
        # "proxy_uwsgi"
      ];
      enable = true;
      enableMellon = true;
      extraConfig = ''
        MellonCacheSize 100
        MellonPostDirectory "/var/lib/mellon/cache"
        MellonCacheEntrySize 196608
        # MellonDiagnosticsFile logs/mellon_diagnostics
        # MellonDiagnosticsEnable Off
        

        ProxyAddHeaders On
        # RequestHeader set X-Forwarded-Host $host
        RequestHeader set X-Real-IP $remote_addr
        RequestHeader set X-Forwarded-For $proxy_add_x_forwarded_for
        ProxyPreserveHost On

      '';
      virtualHosts = {
        "roses.gdvoisins.com" = {
          # useACMEHost = "roses.gdvoisins.com";
          forceSSL = false;
          enableACME = false;
          sslServerKey = "/var/lib/acme/roses.gdvoisins.com/key.pem";
          sslServerChain = "/var/lib/acme/roses.gdvoisins.com/fullchain.pem";
          sslServerCert = "/var/lib/acme/roses.gdvoisins.com/fullchain.pem";
          documentRoot = "/var/www/default";
          extraConfig = ''
            RemoteIPProxyProtocol On
          '';
          # listenAddresses = [ "[::]" "192.168.1.100"];
          listen = listen;
        };
        "fs.roses.gdvoisins.com" = {
          # useACMEHost = "fs.roses.gdvoisins.com";
          forceSSL = false;
          listen = listen;
          enableACME = false;
          extraConfig = ''
            RemoteIPProxyProtocol On
          '';
          sslServerKey = "/var/lib/acme/fs.roses.gdvoisins.com/key.pem";
          sslServerChain = "/var/lib/acme/fs.roses.gdvoisins.com/fullchain.pem";
          sslServerCert = "/var/lib/acme/fs.roses.gdvoisins.com/fullchain.pem";
          documentRoot = "/var/www/default";
          locations."/" = {
            # proxyPass = "http://127.0.0.1:8334/";
            proxyPass = "http://127.0.0.1:4180/";
          };
        };
        "public.cp.roses.gdvoisins.com" = {
          # useACMEHost = "public.cp.roses.gdvoisins.com";
          forceSSL = false;
          listen = listen;
          enableACME = false;
          sslServerKey = "/var/lib/acme/public.cp.roses.gdvoisins.com/key.pem";
          sslServerChain = "/var/lib/acme/public.cp.roses.gdvoisins.com/fullchain.pem";
          sslServerCert = "/var/lib/acme/public.cp.roses.gdvoisins.com/fullchain.pem";
          documentRoot = "/var/www/default";
          extraConfig = ''
              RemoteIPProxyProtocol On
              SSLProxyCACertificatePath /var/lib/copyparty/ssl-public/
              SSLProxyMachineCertificatePath /var/lib/copyparty/ssl-public/
              SSLProxyEngine on
              # Not happy about below chris2fr
              SSLProxyVerify none 
              SSLProxyCheckPeerCN off
              SSLProxyCheckPeerName off
              SSLProxyCheckPeerExpire off
              # Client Certificate
              SSLCertificateFile /var/lib/acme/public.cp.roses.gdvoisins.com/fullchain.pem
              SSLCertificateKeyFile /var/lib/acme/public.cp.roses.gdvoisins.com/key.pem
              SSLCertificateChainFile /var/lib/acme/public.cp.roses.gdvoisins.com/fullchain.pem

          '';
          locations."/" = {
            proxyPass = "https://[::1]:3924/";
          };
        };
        "cp.roses.gdvoisins.com" = {
          # useACMEHost = "cp.roses.gdvoisins.com";
          forceSSL = false;
          listen = listen;
          enableACME = false;
          sslServerKey = "/var/lib/acme/cp.roses.gdvoisins.com/key.pem";
          sslServerChain = "/var/lib/acme/cp.roses.gdvoisins.com/fullchain.pem";
          sslServerCert = "/var/lib/acme/cp.roses.gdvoisins.com/fullchain.pem";
          documentRoot = "/var/www/default";
          extraConfig = ''
              RemoteIPProxyProtocol On
              
              SSLProxyCACertificatePath /var/lib/copyparty/ssl/
              SSLProxyMachineCertificatePath /var/lib/copyparty/ssl/
              SSLProxyEngine on
              # Not happy about below chris2fr
              SSLProxyVerify none 
              SSLProxyCheckPeerCN off
              SSLProxyCheckPeerName off
              SSLProxyCheckPeerExpire off
              # Client Certificate
              SSLCertificateFile /var/lib/acme/cp.roses.gdvoisins.com/fullchain.pem
              SSLCertificateKeyFile /var/lib/acme/cp.roses.gdvoisins.com/key.pem
              SSLCertificateChainFile /var/lib/acme/cp.roses.gdvoisins.com/fullchain.pem
          '';
          # locations."/public/" = {
          #     extraConfig = ''
          #       Satisfy Any
          #       Allow from all
          #     '';
          # };
          locations."/" = {
            proxyPass = "https://[::1]:3923/";
            extraConfig = ''
              # Require valid-user
              AuthType "Mellon"
              MellonEnable "auth"
              MellonSecureCookie On
              MellonCookieSameSite none
              MellonEndpointPath "/mellon/"
              MellonSPPrivateKeyFile "/etc/mellon/https_cp.roses.gdvoisins.com_mellon_metadata.key"
              MellonSPCertFile "/etc/mellon/https_cp.roses.gdvoisins.com_mellon_metadata.cert"
              MellonSPMetadataFile "/etc/mellon/https_cp.roses.gdvoisins.com_mellon_metadata.xml"
              MellonIdPMetadataFile "/etc/mellon/keylesgrandsvoisinscom.xml"
              # MellonUser "username"

              # RequestHeader set "X-Forwarded-Proto" expr=%{REQUEST_SCHEME}
              # RequestHeader set X-REMOTE-USER %{REMOTE_USER}s

              # RequestHeader set "X-Forwarded-Proto" expr=%{REQUEST_SCHEME}
              # RequestHeader set X-REMOTE-USER %{REMOTE_USER}s
              # RequestHeader set X-REMOTE-USER expr=%{REMOTE_USER}s

              # RequestHeader set REMOTE_USER "chris"
              # RequestHeader set X-REMOTE-USER "pauline"


              # RewriteEngine on
              # RewriteCond %{REMOTE_USER} (.*)
              # RewriteRule .* - [E=X_REMOTE_USER:%1]
              # RequestHeader set X-REMOTE-USER %{X_REMOTE_USER}e


              # RewriteEngine On
              # RewriteCond %{LA-U:REMOTE_USER} (.+)
              # RewriteRule . - [E=RU:%1]
              # RequestHeader set X-Remote-User "%{RU}e" env=RU
            '';
          };
        };
        "fontenay.gdvoisins.com" = {
          # useACMEHost = "fontenay.gdvoisins.com";
          forceSSL = false;
          listen = listen;
          enableACME = false;
          sslServerKey = "/var/lib/acme/fontenay.gdvoisins.com/key.pem";
          sslServerChain = "/var/lib/acme/fontenay.gdvoisins.com/fullchain.pem";
          sslServerCert = "/var/lib/acme/fontenay.gdvoisins.com/fullchain.pem";
          documentRoot = "/var/www/default";
            extraConfig = ''
              RemoteIPProxyProtocol On
            '';
        };
        "static.roses.gdvoisins.com" = {
          # useACMEHost = "static.roses.gdvoisins.com";
          forceSSL = false;
          listen = listen;
          enableACME = false;
          sslServerKey = "/var/lib/acme/static.roses.gdvoisins.com/key.pem";
          sslServerChain = "/var/lib/acme/static.roses.gdvoisins.com/fullchain.pem";
          sslServerCert = "/var/lib/acme/static.roses.gdvoisins.com/fullchain.pem";
          documentRoot = "/var/www/default";
            extraConfig = ''
              RemoteIPProxyProtocol On
            '';

          # locations = {
          #   "/" = {
          #     proxyPass = "http://127.0.0.1:8088/";
          #     extraConfig = ''
          #       Require valid-user
          #       AuthType "Mellon"
          #       MellonEnable "auth"

          #       # MellonVariable "cookie"
          #       MellonSecureCookie On
          #       # MellonCookiePath /
          #       MellonCookieSameSite none

          #       # MellonUser "NAME_ID"
          #       # MellonSetEnv "e-mail" "mail"
          #       # MellonSetEnvNoPrefix "DISPLAY_NAME" "displayName"
          #       # MellonEnvPrefix "NOLLEM_"
          #       # MellonEnvVarsSetCount On
          #       # MellonSessionDump Off
          #       # MellonSamlResponseDump Off
          #       MellonEndpointPath "/mellon/"
          #       # MellonSessionLength 86400
          #       MellonSPPrivateKeyFile "/etc/mellon/https_static.roses.gdvoisins.com_mellon_metadata.key"
          #       MellonSPCertFile "/etc/mellon/https_static.roses.gdvoisins.com_mellon_metadata.cert"
          #       MellonSPMetadataFile "/etc/mellon/https_static.roses.gdvoisins.com_mellon_metadata.xml"
          #       MellonIdPMetadataFile "/etc/mellon/keylesgrandsvoisinscom.xml"
          #       # MellonRedirectDomains [self]

          #       RequestHeader set "X-Forwarded-Proto" expr=%{REQUEST_SCHEME}
          #       RequestHeader set X-THE-USER %{REMOTE_USER}s
          #     '';
          #   };
          # };
        };
      };
    };
  };
}



    # httpd = {
    #   enable = true;
    #   package = pkgs.apacheHttpd;
    #   enablePHP = false;
    #   extraConfig = ''
    #     KeepAlive On
    #     MaxKeepAliveRequests 100
    #     KeepAliveTimeout 3
    #     Protocols h2 http/1.1
    #   '';
    #   adminAddr = "chris@lesgrandsvoisins.com";
      # extraModules = [ 
    #   #   "proxy" 
    #   #   "proxy_http" 
    #   #   "dav" 
    #   #   "ldap" 
    #   #   "authnz_ldap" 
    #   #   "alias" 
    #   #   "ssl" 
    #   #   "rewrite" 
    #   #   "proxy_fcgi" 
    #   #   "http2" 
    #   #   "proxy_uwsgi"
    #     # { name = "auth_openidc"; path = "${mod_auth_openidc}/modules/mod_auth_openidc.so"; }
    #   ];
      # virtualHosts = {
      #   "roses.lgv.info" = {
      #     forceSSL = true;
      #     enableACME = true;
      #     # listen = [{port = 443; ssl=true;}];
      #     # sslServerCert = "/var/lib/acme/roses.lgv.info/fullchain.pem";
      #     # sslServerChain = "/var/lib/acme/roses.lgv.info/fullchain.pem";
      #     # sslServerKey = "/var/lib/acme/roses.lgv.info/key.pem";
      #     documentRoot = "/var/www/default";
      #     extraConfig = ''
      #       OIDCProviderMetadataURL https://key.lesgrandsvoisins.com/realms/master/.well-known/openid-configuration
      #       OIDCClientID seafile
      #       Include /etc/.secrets/.apache2.oidcclientsecret.seafile
      #       OIDCRedirectURI https://roses.lgv.info/redirect_uri_from_oauth2
      #       OIDCScope "openid email profile"
      #       OIDCPKCEMethod S256
      #       OIDCOAuthVerifyJwksUri https://key.lesgrandsvoisins.com/auth/realms/master/protocol/openid-connect/certs

            
      #       <Location /protected>
      #         AuthType openid-connect
      #         Require valid-user
      #         # Additional Keycloak role requirements if needed:
      #         # Require claim realm_access.roles:your-role
      #       </Location>
      #     '';


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
  #       };
  #     };
  #   };
  # };

  # users.users.wwwrun.extraGroups = [ 
  #   "acme" 
  #   # "wagtail" 
  #   "users" 
  #   #"ghost" 
  #   #"ghostio" 
  #   #"guichet" 
  # ];
# }