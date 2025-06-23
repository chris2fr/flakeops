{ config, pkgs, lib, ... }:
let 
  oidcSeafileSecret = import ../vars/oidc-seafile-secret.nix;
in
{
  nix.settings.experimental-features = "nix-command flakes";
  system.stateVersion = "25.05";
  imports = [
    ./hardware-configuration.nix
    ./common.nix # Des configurations communes pratiques
    ./networking.nix
    ./users.nix
    # ./httpd.nix
    ./nfs.nix
  ];
  environment.systemPackages = with pkgs; [ 
    # agenix-cli 
    # gcc
    # apacheHttpd
    # pkg-config
    # apr
    # aprutil
    # curlFull
    # lzlib
    # libgnurl
    # jansson
    vouch-proxy
    nodenv
  ];
  # nix-shell -p gcc    apacheHttpd    pkg-config    apr    aprutil    curlFull    lzlib libgnurl
  # export APR_CFLAGS="`apr-1-config --cflags`"
  # export APR_LIBS="`apr-1-config --libs`"
  # export LIBCURL_CFLAGS="`gnurl-config --cflags`"

  age.identityPaths = [ "/etc/.secrets/.age.key" ];
  # age.secrets = {
  #   # "filebrowser" = { file = ./secrets/filebrowser.age; owner="wwwrun";};
  #   "openidc.seafile" = { file = ./secrets/openidc.seafile.age; 
  #   owner = "oauth2-proxy";
  #   group = "oauth2-proxy";};
  #   # "httpd.filebrowser.conf" = { file = ./secrets/httpd.filebrowser.conf.age; owner="wwwrun";};
  #   # "httpd.newuser.conf" = { file = ./secrets/httpd.newuser.conf.age; owner="wwwrun";};
  # };
  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  time.timeZone = "Europe/Paris";

  environment.sessionVariables = {
    EDITOR="vim";
  };
  # nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
  #   "sftpgo"
  # ];
  security.acme = {
    acceptTerms = true;
    defaults.email = "chris@lesgrandsvoisins.com";
  };

  # console.keyMap = "fr";
  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8"; 
  console = { 
     font = "Lat2-Terminus16";
     # keyMap = "fr";
     useXkbConfig = true; # use xkb.options in tty.
   };

  # systemd.services.vouch-proxy = {
  #   description = "Vouch-Proxy OpenIDC server for Nginx";
  #   after = [ "network.target" ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     WorkingDirectory = "/home/mannchri/vouch-proxy/";
  #     ExecStart = "/run/current-system/sw/bin/vouch-proxy -config /home/mannchri/vouch-proxy/config.yml";
  #     Restart = "always";
  #     RestartSec = "10s";
  #     User = "mannchri";
  #     Group = "users";
  #   };
  #   unitConfig = {
  #     StartLimitInterval = "1min";
  #   };
  # };

  services = {

    nginx = {
      enable = true;
      clientMaxBodySize = "10G";
      sso = {
        enable = true;
        configuration = {
          listen = { addr = "127.0.0.1"; port = 8082; };
          providers.oidc = {
            client_id = "seafile";
            client_secret = "${oidcSeafileSecret}";
            # Optional, defaults to "OpenID Connect"
            issuer_name = "Key Lesgrandsvoisins Com";
            issuer_url = "https://key.lesgrandsvoisins.com/realms/master/.well-known/openid-configuration";
            redirect_url = "https://roses.lgv.info/login";
            # Optional, defaults to no limitations
            # require_domain = "lesgrandsvoisins.com";
            # Optional, defaults to "subject"
            # user_id_method = "full-email";
          };
          acl = {
            rule_sets = [
              {
                rules = [ { field = "x-application"; equals = "kibana"; } ];
                allow = [ "chris" ];
              }
            ];
          };
        };
      };
      virtualHosts = {
        # "vouch.lgv.info" = {
        #   forceSSL = true;
        #   enableACME = true;
        #   root = "/var/www/default";
        #   locations."/" = {
        #     proxyPass = "https://192.168.1.100:41443";
        #     # be sure to pass the original host header
        #     # proxy_set_header Host $host;
        #     # }
        #     # recommendedProxySettings = true;
        #     extraConfig = ''
        #         proxy_ssl_verify off;
        #         proxy_set_header Host $host;
        #         # Maybe
        #         proxy_pass_request_body off;
        #         proxy_set_header Content-Length "";
        #     '';
        #   };
        # };
        "roses.lgv.info" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/default";
          locations = {
            "/protected" = {
              extraConfig = ''
                
                # Protect this location using the auth_request
                auth_request /sso-auth;

                # ## Optionally set a header to pass through the username
                # #auth_request_set $username $upstream_http_x_username;
                # #proxy_set_header X-User $username;

                # # Automatically renew SSO cookie on request
                # auth_request_set $cookie $upstream_http_set_cookie;
                # add_header Set-Cookie $cookie;

                # proxy_pass http://127.0.0.1:1720/;
              '';
            };
            "/sso-auth" = {
              extraConfig = ''
                # # Do not allow requests from outside
                # internal;
                # Access /auth endpoint to query login state
                proxy_pass http://127.0.0.1:8082/auth;
                # Do not forward the request body (nginx-sso does not care about it)
                proxy_pass_request_body off;
                proxy_set_header Content-Length "";
                # Set custom information for ACL matching: Each one is available as
                # a field for matching: X-Host = x-host, ...
                proxy_set_header X-Origin-URI $request_uri;
                proxy_set_header X-Host $http_host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_set_header X-Application "kibana";
              '';
            };
          };
          # extraConfig = ''
          #   auth_request /validate;
          #   error_page 401 = @error401;
          #   location @error401 {
          #       # redirect to Vouch Proxy for login
          #       return 302 https://vouch.yourdomain.com/login?url=$scheme://$host$request_uri&vouch-failcount=$auth_resp_failcount&X-Vouch-Token=$auth_resp_jwt&error=$auth_resp_err;
          #       # you usually *want* to redirect to Vouch running behind the same Nginx config proteced by https
          #       # but to get started you can just forward the end user to the port that vouch is running on
          #       # return 302 http://vouch.yourdomain.com:9090/login?url=$scheme://$host$request_uri&vouch-failcount=$auth_resp_failcount&X-Vouch-Token=$auth_resp_jwt&error=$auth_resp_err;
          #   }
          # '';
          # extraConfig = ''
          #   auth_request /validate;
          # '';
          # locations = {
          #   "/validate" = {
          #     proxyPass = "https://vouch.lgv.info/validate";
          #     # recommendedProxySettings = true;
          #     extraConfig = ''
          #       # proxy_ssl_verify off;
          #       proxy_set_header Host $host;
          #       proxy_pass_request_body off;
          #       proxy_set_header Content-Length "";
          #       # auth_request_set $auth_resp_x_vouch_user $upstream_http_x_vouch_user;
          #       # these return values are used by the @error401 call
          #       # auth_request_set $auth_resp_jwt $upstream_http_x_vouch_jwt;
          #       # auth_request_set $auth_resp_err $upstream_http_x_vouch_err;
          #       # auth_request_set $auth_resp_failcount $upstream_http_x_vouch_failcount;
          #     '';
          #       # forward the /validate request to Vouch Proxy
          #       # extraConfig = ''
          #       #   # forward the /validate request to Vouch Proxy
          #       #   proxy_pass http://127.0.0.1:9090/validate;
          #       #   # be sure to pass the original host header
          #       #   proxy_set_header Host $host;

          #       #   # Vouch Proxy only acts on the request headers
          #       #   proxy_pass_request_body off;
          #       #   proxy_set_header Content-Length "";

          #       #   # optionally add X-Vouch-User as returned by Vouch Proxy along with the request
          #       #   auth_request_set $auth_resp_x_vouch_user $upstream_http_x_vouch_user;

          #       #   # optionally add X-Vouch-IdP-Claims-* custom claims you are tracking
          #       #   #    auth_request_set $auth_resp_x_vouch_idp_claims_groups $upstream_http_x_vouch_idp_claims_groups;
          #       #   #    auth_request_set $auth_resp_x_vouch_idp_claims_given_name $upstream_http_x_vouch_idp_claims_given_name;
          #       #   # optinally add X-Vouch-IdP-AccessToken or X-Vouch-IdP-IdToken
          #       #   #    auth_request_set $auth_resp_x_vouch_idp_accesstoken $upstream_http_x_vouch_idp_accesstoken;
          #       #   #    auth_request_set $auth_resp_x_vouch_idp_idtoken $upstream_http_x_vouch_idp_idtoken;

          #       #   # these return values are used by the @error401 call
          #       #   auth_request_set $auth_resp_jwt $upstream_http_x_vouch_jwt;
          #       #   auth_request_set $auth_resp_err $upstream_http_x_vouch_err;
          #       #   auth_request_set $auth_resp_failcount $upstream_http_x_vouch_failcount;

          #       #   # Vouch Proxy can run behind the same Nginx reverse proxy
          #       #   # may need to comply to "upstream" server naming
          #       #   # proxy_pass http://vouch.yourdomain.com/validate;
          #       #   # proxy_set_header Host $host;
          #       # '';
          #   };
            # "/protected/" = {
            #   extraConfig = ''
            #     # auth_request https://roses.lgv.info:41443/oauth2;
            #     # auth_request_set $user  $upstream_http_x_auth_request_user;
            #     # proxy_set_header X-User $user;
            #   '';
            # };
          # };
        };
      };
    };

    # oauth2-proxy = {
    #   enable = true;

    #   # Common configuration
    #   provider = "keycloak-oidc"; # or "github", "gitlab", "azure", etc.
    #   email.domains = ["*"]; # restrict to specific email domains
      
    #   # Client credentials (register your app with the OAuth provider)
    #   clientID = "searfile";
    #   keyFile = "/etc/.secrets/.seafile_oauthproxy_keyfile";
    #   # clientSecret = "your-client-secret";
      
    #   # Cookie settings
    #   cookie.secret = "NgbKPVOqtJn5bipSRGuR22BwasVS1J5u"; # generate with: openssl rand -base64 32 | head -c 32 | base64
      
    #   # Additional settingsenvironment.systemPackages = with pkgs; [
    #   # upstream = "http://localhost:1234"; # your backend service
    #   httpAddress = "0.0.0.0:4180"; # where oauth2-proxy listens
    #   reverseProxy = true;
    #   upstream = "file:///var/www/default";
    #   tls = {
    #     enable = true;
    #     certificate = "/var/lib/acme/roses.lgv.info/fullchain.pem";
    #     key = "/var/lib/acme/roses.lgv.info/key.pem";
    #     httpsAddress = ":41443";
    #   };
    #   redirectURL = "https://roses.lgv.info/oauth2/callback";
    #   oidcIssuerUrl = "https://key.lesgrandsvoisins.com/realms/master";
    #   # oidcIssuerUrl = "https://key.lesgrandsvoisins.com/realms/master/.well-known/openid-configuration";
    #   extraConfig = {
    #     code-challenge-method="S256";
    #     whitelist-domain="roses.lgv.info";
    #     insecure-oidc-allow-unverified-email="true";
    #     # cookie-domains="roses.lgv.info";
    #   };
    # };

    xserver = {
      xkb.layout = "fr";
      enable = true;
      
      desktopManager = {
        xterm.enable = false;
        xfce.enable = true;
      };
    };
    displayManager.defaultSession = "xfce";
    locate = {
      enable = true;
      package = pkgs.mlocate;
      # localuser = null;
    };
    # nextcloud = {
    #   enable = true;
    #   hostName = "roses.lesgrandsvoisins.com";
    #   config = {
    #     adminpassFile = "/etc/.secrets/.nextcloud/.adminpass";
    #     dbtype = "sqlite";
    #   };
    #   # database = {
    #   #   createLocally = true;
    #   # };
    # };
    seafile = {
      enable = true;

      adminEmail = "chris@lesgrandsvoisins.com";
      initialAdminPassword = "change this later!";

      ccnetSettings.General.SERVICE_URL = "https://roses.lesgrandsvoisins.com";

      seafileSettings = {
        fileserver = {
          host = "unix:/run/seafile/server.sock";
        };
      }; 
      seahubExtraConf = ''
        FILE_PREVIEW_MAX_SIZE = 100 * 1024 * 1024
        THUMBNAIL_IMAGE_SIZE_LIMIT = 100 # MB

        # ENABLE_REMOTE_USER_AUTHENTICATION = True

        # # Optional, HTTP header, which is configured in your web server conf file,
        # # used for Seafile to get user's unique id, default value is 'HTTP_REMOTE_USER'.
        # REMOTE_USER_HEADER = 'HTTP_REMOTE_USER'

        # # Optional, when the value of HTTP_REMOTE_USER is not a valid email address，
        # # Seafile will build a email-like unique id from the value of 'REMOTE_USER_HEADER'
        # # and this domain, e.g. user1@example.com.
        # REMOTE_USER_DOMAIN = 'lesgrandsvoisins.com'

        # # Optional, whether to create new user in Seafile system, default value is True.
        # # If this setting is disabled, users doesn't preexist in the Seafile DB cannot login.
        # # The admin has to first import the users from external systems like LDAP.
        # REMOTE_USER_CREATE_UNKNOWN_USER = True

        # # Optional, whether to activate new user in Seafile system, default value is True.
        # # If this setting is disabled, user will be unable to login by default.
        # # the administrator needs to manually activate this user.
        # REMOTE_USER_ACTIVATE_USER_AFTER_CREATION = True

        # # Optional, map user attribute in HTTP header and Seafile's user attribute.
        # REMOTE_USER_ATTRIBUTE_MAP = {
        #     'HTTP_DISPLAYNAME': 'name',
        #     'HTTP_MAIL': 'contact_email',

        #     # for user info
        #     "HTTP_GIVENNAME": 'givenname',
        #     "HTTP_SN": 'surname',
        #     "HTTP_ORGANIZATION": 'institution',

        #     # for user role
        #     'HTTP_SHIBBOLETH_AFFILIATION': 'affiliation',
        # }

        # # Map affiliation to user role. Though the config name is SHIBBOLETH_AFFILIATION_ROLE_MAP,
        # # it is not restricted to Shibboleth
        # SHIBBOLETH_AFFILIATION_ROLE_MAP = {
        #     'employee@uni-mainz.de': 'staff',
        #     'member@uni-mainz.de': 'staff',
        #     'student@uni-mainz.de': 'student',
        #     'employee@hu-berlin.de': 'guest',
        #     'patterns': (
        #         ('*@hu-berlin.de', 'guest1'),
        #         ('*@*.de', 'guest2'),
        #         ('*', 'guest'),
        #     ),
        # }
      '';
      # seahubExtraConf = ''
      #   ENABLE_OAUTH = True

      #   # If create new user when he/she logs in Seafile for the first time, defalut `True`.
      #   OAUTH_CREATE_UNKNOWN_USER = True

      #   # If active new user when he/she logs in Seafile for the first time, defalut `True`.
      #   OAUTH_ACTIVATE_USER_AFTER_CREATION = True

      #   # Usually OAuth works through SSL layer. If your server is not parametrized to allow HTTPS, some method will raise an "oauthlib.oauth2.rfc6749.errors.InsecureTransportError". Set this to `True` to avoid this error.
      #   OAUTH_ENABLE_INSECURE_TRANSPORT = False

      #   # Client id/secret generated by authorization server when you register your client application.
      #   OAUTH_CLIENT_ID = "seafile"
      #   OAUTH_CLIENT_SECRET = open("/etc/.secrets/.seafile_client_secret").read().strip()

      #   # Callback url when user authentication succeeded. Note, the redirect url you input when you register your client application MUST be exactly the same as this value.
      #   OAUTH_REDIRECT_URL = 'https://roses.lesgrandsvoisins.com/oauth/callback/'

      #   # The following should NOT be changed if you are using Github as OAuth provider.
      #   OAUTH_PROVIDER_DOMAIN = 'key.lesgrandsvoisins.com' 
      #   OAUTH_PROVIDER = 'key.lesgrandsvoisins.com'

      #   OAUTH_AUTHORIZATION_URL = 'https://key.lesgrandsvoisins.com/realms/master/protocol/openid-connect/auth'
      #   OAUTH_TOKEN_URL = 'https://key.lesgrandsvoisins.com/realms/master/protocol/openid-connect/token'
      #   OAUTH_USER_INFO_URL = 'https://key.lesgrandsvoisins.com/realms/master/protocol/openid-connect/userinfo'
      #   OAUTH_SCOPE = ["profile", "openid", "email"]
      #   OAUTH_ATTRIBUTE_MAP = {
      #     "email": (True, "uid"),
      #     "name": (False, "name")
      #   }
      # '';
    };
  };
  

  systemd = {
    extraConfig = ''
      DefaultTimeoutStartSec=600s
    '';
    tmpfiles.rules = [
      "d /export 0755 nfsuser users"
      "d /export/data1 0755 nfsuser users"
      "d /export/data2 0755 nfsuser users"
      "d /export/data3 0755 nfsuser users"
      "d /export/data4 0755 nfsuser users"
      "d /export/data5 0755 nfsuser users"
      "d /export/data6 0755 nfsuser users"
      "d /export/data7 0755 nfsuser users"
      "d /export/data8 0755 nfsuser users"
      "d /export/data9 0755 nfsuser users"
      "d /srv 0755 nfsuser users"
      "d /srv/data1 0755 nfsuser users"
      "d /srv/data2 0755 nfsuser users"
      "d /srv/data3 0755 nfsuser users"
      "d /srv/data4 0755 nfsuser users"
      "d /srv/data5 0755 nfsuser users"
      "d /srv/data6 0755 nfsuser users"
      "d /srv/data7 0755 nfsuser users"
      "d /srv/data8 0755 nfsuser users"
      "d /srv/data9 0755 nfsuser users"
    ];
  };

  # security.acme = {
  #   acceptTerms = true;
  #   defaults.email = "chris@lesgrandsvoisins.com";
  # };

  services = {
    openssh = {
      enable = true;
      # listenAddresses = [
      #   {
      #     addr = "0.0.0.0";
      #     port = 22;
      #   } 
      # ];
      settings.PermitRootLogin = "no";
    };
    rsyncd.enable = true;
  };
}
