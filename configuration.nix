{ config, pkgs, lib, ... }:
let 
in
{
  nix.settings.experimental-features = "nix-command flakes";
  system.stateVersion = "25.05";
  imports = [
    ./hardware-configuration.nix
    ./common.nix # Des configurations communes pratiques
    ./networking.nix
    ./users.nix
    ./nfs.nix
  ];
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

  services = {
    oauth2-proxy = {
      enable = true;
      
      provider = "keycloak-oidc";  # or "google", "github", etc.
      # provider = "oidc";  # or "google", "github", etc.
      httpAddress = "https://roses.lgv.info:41443";
      tls = {
        key = "/var/lib/acme/roses.lgv.info/key.pem";
        certificate = "/var/lib/acme/roses.lgv.info/fullchain.pem";
        httpsAddress = ":41443";
        enable = true;
      };
      upstream = "file:///var/www/default";
      oidcIssuerUrl = "https://key.lesgrandsvoisins.com/realms/master";
      clientID = "seafile";
      # clientSecret = "YOUR_CLIENT_SECRET";
      keyFile = "/etc/.secrets/.seafile_oauthproxy_keyfile";
      redirectURL = "https://roses.lgv.info:41443/oauth2/callback";
      cookie.secret = "afet530fdxaf24506hgnsdfr";  # must be 16, 24, or 32 chars
      # cookie.httpOnly = false;
      setXauthrequest = true;
      passAccessToken = true;
      email.domains = ["*"];
      scope = "profile openid email";
      reverseProxy = true;
      cookie.secure = false; # Revisit
      # ... add other options as needed ...
      # passHostHeader = false;lesgrandsvoisins.com
      nginx.domain = "roses.lgv.info";
      # nginx.proxy = "192.168.1.100";

      extraConfig = {
        code-challenge-method="S256";
        whitelist-domain="roses.lgv.info";
        insecure-oidc-allow-unverified-email="true";
      };
    };
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
    nginx = {
      enable = true;
      clientMaxBodySize = "6G";
      virtualHosts = {
        localhost = {
          locations."/" = {
            return = "200 '<html><body>It works</body></html>'";
            extraConfig = ''
              default_type text/html;
            '';
          };
        };
        "roses.lgv.info" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/default";
          locations = {
            "/" = {
              extraConfig = ''
                auth_request http://127.0.0.1:4180/oauth2;
                auth_request_set $user  $upstream_http_x_auth_request_user;
                proxy_set_header X-User $user;
              '';
              # extraConfig = ''
              #   auth_request /oauth2/auth;
              #   error_page 401 =403 /oauth2/sign_in;

              #   auth_request_set $user   $upstream_http_x_auth_request_user;
              #   auth_request_set $email  $upstream_http_x_auth_request_email;
              #   proxy_set_header X-User  $user;
              #   proxy_set_header X-Email $email;

              #   # if you enabled --pass-access-token, this will pass the token to the backend
              #   auth_request_set $token  $upstream_http_x_auth_request_access_token;
              #   proxy_set_header X-Access-Token $token;

              #   # if you enabled --cookie-refresh, this is needed for it to work with auth_request
              #   auth_request_set $auth_cookie $upstream_http_set_cookie;
              #   add_header Set-Cookie $auth_cookie;

              #   # When using the --set-authorization-header flag, some provider's cookies can exceed the 4kb
              #   # limit and so the OAuth2 Proxy splits these into multiple parts.
              #   # Nginx normally only copies the first `Set-Cookie` header from the auth_request to the response,
              #   # so if your cookies are larger than 4kb, you will need to extract additional cookies manually.
              #   auth_request_set $auth_cookie_name_upstream_1 $upstream_cookie_auth_cookie_name_1;

              #   # Extract the Cookie attributes from the first Set-Cookie header and append them
              #   # to the second part ($upstream_cookie_* variables only contain the raw cookie content)
              #   if ($auth_cookie ~* "(; .*)") {
              #       set $auth_cookie_name_0 $auth_cookie;
              #       set $auth_cookie_name_1 "auth_cookie_name_1=$auth_cookie_name_upstream_1$1";
              #   }

              #   # Send both Set-Cookie headers now if there was a second part
              #   if ($auth_cookie_name_upstream_1) {
              #       add_header Set-Cookie $auth_cookie_name_0;
              #       add_header Set-Cookie $auth_cookie_name_1;
              #   }
              #   '';
            };
            # "/oauth2" = {
            #   extraConfig = ''
            #     proxy_pass http://127.0.0.1:4180/;
            #     proxy_set_header Host $host;
            #     proxy_set_header X-Real-IP $remote_addr;
            #     proxy_set_header X-Scheme $scheme;
            #     proxy_set_header X-Auth-Request-Redirect $scheme://$host$request_uri;
            #     # proxy_set_header X-Auth-Request-Redirect $request_uri;
            #   '';
            # };
            # "/oauth2/auth" = {
            #   extraConfig = ''
            #     proxy_pass       http://127.0.0.1:4180;
            #     proxy_set_header Host             $host;
            #     proxy_set_header X-Real-IP        $remote_addr;
            #     proxy_set_header X-Forwarded-Uri  $request_uri;
            #     # nginx auth_request includes headers but not body
            #     proxy_set_header Content-Length   "";
            #     proxy_pass_request_body           off;
            #   '';
            # };
          };
        };
        "roses.lesgrandsvoisins.com" = {
          # sslCertificate = "/path/to/cert.pem";
          # sslCertificateKey = "/path/to/key.key";
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              proxyPass = "http://unix:/run/seahub/gunicorn.sock";
              extraConfig = ''
                # auth_request http://127.0.0.1:4180/oauth2/auth;
                # auth_request_set $user  $upstream_http_x_auth_request_user;
                # proxy_set_header X-User $user;
                proxy_set_header   Host $host;
                proxy_set_header   X-Real-IP $remote_addr;
                proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header   X-Forwarded-Host $server_name;
                proxy_read_timeout  1200s;
                client_max_body_size 0;
              '';
            };
            # "/oauth2/" = {
            #   extraConfig = ''
            #     proxy_pass http://127.0.0.1:4180/;
            #     proxy_set_header Host $host;
            #     proxy_set_header X-Real-IP $remote_addr;
            #     proxy_set_header X-Scheme $scheme;
            #     proxy_set_header X-Auth-Request-Redirect $request_uri;
            #   '';
            # };
            "/seafhttp" = {
              proxyPass = "http://unix:/run/seafile/server.sock";
              extraConfig = ''
                rewrite ^/seafhttp(.*)$ $1 break;
                # 
                # auth_request_set $user  $upstream_http_x_auth_request_user;
                # proxy_set_header X-User $user;
                # 
                client_max_body_size 0;
                proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_connect_timeout  36000s;
                proxy_read_timeout  36000s;
                proxy_send_timeout  36000s;
                send_timeout  36000s;
              '';
            };
          };
        };
      };
    };
  };
}
