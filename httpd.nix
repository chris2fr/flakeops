{ config, pkgs, lib, ... }:
let 
  # mod_auth_openidc = pkgs.callPackage ./derivations/mod_auth_openidc-binary.nix {};
  # oidcseafilesecret = import secrets/oidcseafile.nix;
in
{ 

  environment.systemPackages = with pkgs; [ curl cjose apr aprutil ];
  systemd.tmpfiles.rules = [
    "d /var/lib/mellon/cache 1777 root root"
    "d /etc/mellon 0750 root root"
  ];
  services = {
    httpd = {
      enable = true;
      enableMellon = true;
      extraConfig = ''
        MellonCacheSize 100
        MellonPostDirectory "/var/lib/mellon/cache"
        MellonCacheEntrySize 196608
        # MellonDiagnosticsFile logs/mellon_diagnostics
        # MellonDiagnosticsEnable Off

        ProxyAddHeaders On
        RequestHeader set X-Forwarded-Host proxy-pathfactory-development.com
        RequestHeader set X-Real-IP $remote_addr
        RequestHeader set X-Forwarded-For $proxy_add_x_forwarded_for
        ProxyPreserveHost On
      '';
      virtualHosts = {
        "roses.gdvoisins.com" = {
          forceSSL = true;
          enableACME = true;
          documentRoot = "/var/www/default";
        };
        "fs.roses.gdvoisins.com" = {
          forceSSL = true;
          enableACME = true;
          documentRoot = "/var/www/default";
          proxyPass = "http://127.0.0.1:8334";
          extraConfig = ''
          '';
        };
        "cp.roses.gdvoisins.com" = {
          forceSSL = true;
          enableACME = true;
          documentRoot = "/var/www/default";
          proxyPass = "http://127.0.0.1:8334";
          locations."/".extraConfig = ''
            Require valid-user
            AuthType "Mellon"
            MellonEnable "auth"
            MellonSecureCookie On
            MellonCookieSameSite none
            MellonEndpointPath "/mellon/"
            MellonSPPrivateKeyFile "/etc/mellon/https_cp.roses.gdvoisins.com_mellon_metadata.key"
            MellonSPCertFile "/etc/mellon/https_cp.roses.gdvoisins.com_mellon_metadata.cert"
            MellonSPMetadataFile "/etc/mellon/https_cp.roses.gdvoisins.com_mellon_metadata.xml"
            MellonIdPMetadataFile "/etc/mellon/keylesgrandsvoisinscom.xml"
          '';
        };
        "static.roses.gdvoisins.com" = {
          forceSSL = true;
          enableACME = true;
          documentRoot = "/var/www/default";
          locations = {
            "/" = {
              extraConfig = ''
                Require valid-user
                AuthType "Mellon"
                MellonEnable "auth"

                # MellonVariable "cookie"
                MellonSecureCookie On
                # MellonCookiePath /
                MellonCookieSameSite none

                # MellonUser "NAME_ID"
                # MellonSetEnv "e-mail" "mail"
                # MellonSetEnvNoPrefix "DISPLAY_NAME" "displayName"
                # MellonEnvPrefix "NOLLEM_"
                # MellonEnvVarsSetCount On
                # MellonSessionDump Off
                # MellonSamlResponseDump Off
                MellonEndpointPath "/mellon/"
                # MellonSessionLength 86400
                MellonSPPrivateKeyFile "/etc/mellon/https_static.roses.gdvoisins.com_mellon_metadata.key"
                MellonSPCertFile "/etc/mellon/https_static.roses.gdvoisins.com_mellon_metadata.cert"
                MellonSPMetadataFile "/etc/mellon/https_static.roses.gdvoisins.com_mellon_metadata.xml"
                MellonIdPMetadataFile "/etc/mellon/keylesgrandsvoisinscom.xml"
                # MellonRedirectDomains [self]
              '';
            };
          };
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