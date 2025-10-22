{ config, pkgs, lib, filestash, ... }:
let 
  # oidcSeafileSecret = import ./secrets/oidc-seafile-secret.nix;
    oidcRosesSecret = import ./secrets/oidc-roses-secret.nix;
    jwtVouchSecret = import ./secrets/jwt-vouch-secret.nix;
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
    ./vouch.nix
    # ./containers.nix
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
    # vouch-proxy
    nodenv
    filestash
    vips
    vouch-proxy
  ];
  systemd.services.filestash.environment."FILESTASH_PATH" = "/var/lib/filestash";
  systemd.services.copyparty = {
    enable = true;
    wantedBy = ["default.target"];
    script = "/home/mannchri/copyparty/.venv/bin/python -m copyparty --xff-hdr x-forwarded-for --rproxy 1 --xff-src=lan -c /home/mannchri/copyparty/copyparty.conf ";
    description = "CopyParty";
    serviceConfig = {
      WorkingDirectory = "/mnt/chrisdatalive/chris";
      User = "mannchri";
      Group = "users";
    };
  };
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
    syncthing = {
      enable=true;
      openDefaultPorts=true;
      
    };
    filestash = {
      enable = true;
      paths = {
        config = "/etc/filestash/config.json";
        # tmp = "/tmp/filestash";
        # log = "/var/log/filestash";
      };
      # # optionally customize configuration
      # settings = {
      #   public_url = "https://roses.lgv.info";
      #   data_dir = "/var/lib/filestash";
      #   port = 8334;
      # };
    };
    nginx = {
      enable = true;
      clientMaxBodySize = "10G";

            # extraConfig = ''
            #   location /validate {
            #     # forward the /validate request to Vouch Proxy
            #     proxy_pass https://vouch.roses.gdvoisins.com:30746/validate;
            #     # # be sure to pass the original host header
            #     proxy_set_header Host $host;

            #     # Vouch Proxy only acts on the request headers
            #     proxy_pass_request_body off;
            #     proxy_set_header Content-Length "";

            #     # optionally add X-Vouch-User as returned by Vouch Proxy along with the request
            #     auth_request_set $auth_resp_x_vouch_user $upstream_http_x_vouch_user;

            #     # optionally add X-Vouch-IdP-Claims-* custom claims you are tracking
            #     #    auth_request_set $auth_resp_x_vouch_idp_claims_groups $upstream_http_x_vouch_idp_claims_groups;
            #     #    auth_request_set $auth_resp_x_vouch_idp_claims_given_name $upstream_http_x_vouch_idp_claims_given_name;
            #     # optinally add X-Vouch-IdP-AccessToken or X-Vouch-IdP-IdToken
            #     #    auth_request_set $auth_resp_x_vouch_idp_accesstoken $upstream_http_x_vouch_idp_accesstoken;
            #     #    auth_request_set $auth_resp_x_vouch_idp_idtoken $upstream_http_x_vouch_idp_idtoken;

            #     # these return values are used by the @error401 call
            #     auth_request_set $auth_resp_jwt $upstream_http_x_vouch_jwt;
            #     auth_request_set $auth_resp_err $upstream_http_x_vouch_err;
            #     auth_request_set $auth_resp_failcount $upstream_http_x_vouch_failcount;

            #     # Vouch Proxy can run behind the same Nginx reverse proxy
            #     # may need to comply to "upstream" server naming
            #     # proxy_pass https://vouch.roses.gdvoisins.com/validate;
            #     # proxy_set_header Host $host;
            #   }
            #   '';
      # extraConfig = ''
      #   # send all requests to the `/validate` endpoint for authorization
      #   auth_request /validate;
      #    # if validate returns `401 not authorized` then forward the request to the error401block
      #   error_page 401 = @error401;
      # '';
      # sso = {
      #   enable = true;
      #   configuration = {
      #     listen = { addr = "127.0.0.1"; port = 8082; };
      #     providers.oidc = {
      #       client_id = "seafile";
      #       client_secret = "${oidcSeafileSecret}";
      #       # Optional, defaults to "OpenID Connect"
      #       issuer_name = "Key Lesgrandsvoisins Com";
      #       issuer_url = "https://key.lesgrandsvoisins.com/realms/master/.well-known/openid-configuration";
      #       redirect_url = "https://roses.lgv.info/login";
      #       # Optional, defaults to no limitations
      #       # require_domain = "lesgrandsvoisins.com";
      #       # Optional, defaults to "subject"
      #       # user_id_method = "full-email";
      #     };
      #     acl = {
      #       rule_sets = [
      #         {
      #           rules = [ { field = "x-application"; equals = "kibana"; } ];
      #           allow = [ "chris" ];
      #         }
      #       ];
      #     };
      #   };
      # };
      virtualHosts = {
        # "vouch.roses.gdvoisins.com" = {
        #   forceSSL = true;
        #   root = "/var/www/default";
        #   enableACME = true;
        # };
        "fs.roses.gdvoisins.com" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/default";
          locations."/" = {
            proxyPass = "http://127.0.0.1:8334";
            # recommendedProxySettings = true;
            extraConfig = ''
              proxy_buffering off;
              proxy_cache off;
              proxy_read_timeout   86400;
              proxy_set_header     Host $host:$server_port;
              proxy_set_header     X-Real-IP $remote_addr;
              proxy_set_header     X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header     X-Forwarded-Proto $scheme;
            '';
          };
        };
        "static.roses.gdvoisins.com" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/default";
          extraConfig = ''
                auth_request /validate;
                '';
          locations = {
            # "@error401" = {
            #   extraConfig = ''
            #     # redirect to Vouch Proxy for login
            #     return 302 https://vouch.roses.lesgrandsvoisins.com/login?url=$scheme://$http_host$request_uri&vouch-failcount=$auth_resp_failcount&X-Vouch-Token=$auth_resp_jwt&error=$auth_resp_err;
            #   '';
            # };
            "/" = {
              extraConfig = ''
                auth_request /validate;

                # set user header (usually an email)
                proxy_set_header X-Vouch-User $auth_resp_x_vouch_user;
                # optionally pass any custom claims you are tracking
                    # proxy_set_header X-Vouch-IdP-Claims-Groups $auth_resp_x_vouch_idp_claims_groups;
                    # proxy_set_header X-Vouch-IdP-Claims-Given_Name $auth_resp_x_vouch_idp_claims_given_name;
                # optionally pass the accesstoken or idtoken
                    # proxy_set_header X-Vouch-IdP-AccessToken $auth_resp_x_vouch_idp_accesstoken;
                    # proxy_set_header X-Vouch-IdP-IdToken $auth_resp_x_vouch_idp_idtoken;
              '';
            };
            "/validate" = {
              proxyPass = "http://unix://run/vouch-proxy/socket";
              # proxyPass = "https://vouch.roses.gdvoisins.com:30746/validate";
              extraConfig = ''
                # forward the /validate request to Vouch Proxy
                # proxy_pass http://127.0.0.1:30746/validate;
                # # be sure to pass the original host header
                proxy_set_header Host $host;

                # Vouch Proxy only acts on the request headers
                proxy_pass_request_body off;
                proxy_set_header Content-Length "";

                # optionally add X-Vouch-User as returned by Vouch Proxy along with the request
                auth_request_set $auth_resp_x_vouch_user $upstream_http_x_vouch_user;

                # optionally add X-Vouch-IdP-Claims-* custom claims you are tracking
                #    auth_request_set $auth_resp_x_vouch_idp_claims_groups $upstream_http_x_vouch_idp_claims_groups;
                #    auth_request_set $auth_resp_x_vouch_idp_claims_given_name $upstream_http_x_vouch_idp_claims_given_name;
                # optinally add X-Vouch-IdP-AccessToken or X-Vouch-IdP-IdToken
                #    auth_request_set $auth_resp_x_vouch_idp_accesstoken $upstream_http_x_vouch_idp_accesstoken;
                #    auth_request_set $auth_resp_x_vouch_idp_idtoken $upstream_http_x_vouch_idp_idtoken;

                # these return values are used by the @error401 call
                auth_request_set $auth_resp_jwt $upstream_http_x_vouch_jwt;
                auth_request_set $auth_resp_err $upstream_http_x_vouch_err;
                auth_request_set $auth_resp_failcount $upstream_http_x_vouch_failcount;

                # Vouch Proxy can run behind the same Nginx reverse proxy
                # may need to comply to "upstream" server naming
                # proxy_pass https://vouch.roses.gdvoisins.com/validate;
                # proxy_set_header Host $host;
              '';
            };
          };
        };
        "cp.roses.gdvoisins.com"  = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/default";
          locations."/" = {

            proxyPass = "https://192.168.1.100:3923";
            # recommendedProxySettings = true;
            extraConfig = ''
            

            proxy_redirect off;
            # disable buffering (next 4 lines)
            proxy_http_version 1.1;
            client_max_body_size 0;
            proxy_buffering off;
            proxy_request_buffering off;
            # improve download speed from 600 to 1500 MiB/s
            proxy_buffers 32 8k;
            proxy_buffer_size 16k;
            proxy_busy_buffers_size 24k;

            proxy_set_header   Connection        "Keep-Alive";
            proxy_set_header   Host              $host;
            proxy_set_header   X-Real-IP         $remote_addr;
            proxy_set_header   X-Forwarded-Proto $scheme;
            proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
            # NOTE: with cloudflare you want this X-Forwarded-For instead:
            #proxy_set_header   X-Forwarded-For   $http_cf_connecting_ip;
            '';
          };
        };
        # "vouch.roses.gdvoisins.com" = {
        #   forceSSL = true;
        #   enableACME = true;
        #   root = "/var/www/default";
        #   locations."/" = {
        #     proxyPass = "http://127.0.0.1:30746";
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
        # "roses.lgv.info" = {
        #   forceSSL = true;
        #   enableACME = true;
        #   root = "/var/www/default";
        #   # extraConfig = ''
        #   #   auth_request /sso-auth;
        #   # '';
        #   locations = {
        #     "/" = {
        #       extraConfig = ''
                          
        #         auth_request /oauth2/auth;
        #         error_page 401 =403 /oauth2/sign_in;

        #         # pass information via X-User and X-Email headers to backend,
        #         # requires running with --set-xauthrequest flag
        #         auth_request_set $user   $upstream_http_x_auth_request_user;
        #         auth_request_set $email  $upstream_http_x_auth_request_email;
        #         proxy_set_header X-User  $user;
        #         proxy_set_header X-Email $email;

        #         # if you enabled --pass-access-token, this will pass the token to the backend
        #         auth_request_set $token  $upstream_http_x_auth_request_access_token;
        #         proxy_set_header X-Access-Token $token;

        #         # if you enabled --cookie-refresh, this is needed for it to work with auth_request
        #         auth_request_set $auth_cookie $upstream_http_set_cookie;
        #         add_header Set-Cookie $auth_cookie;

        #         # When using the --set-authorization-header flag, some provider's cookies can exceed the 4kb
        #         # limit and so the OAuth2 Proxy splits these into multiple parts.
        #         # Nginx normally only copies the first `Set-Cookie` header from the auth_request to the response,
        #         # so if your cookies are larger than 4kb, you will need to extract additional cookies manually.
        #         auth_request_set $auth_cookie_name_upstream_1 $upstream_cookie_auth_cookie_name_1;

        #         # Extract the Cookie attributes from the first Set-Cookie header and append them
        #         # to the second part ($upstream_cookie_* variables only contain the raw cookie content)
        #         if ($auth_cookie ~* "(; .*)") {
        #             set $auth_cookie_name_0 $auth_cookie;
        #             set $auth_cookie_name_1 "auth_cookie_name_1=$auth_cookie_name_upstream_1$1";
        #         }

        #         # Send both Set-Cookie headers now if there was a second part
        #         if ($auth_cookie_name_upstream_1) {
        #             add_header Set-Cookie $auth_cookie_name_0;
        #             add_header Set-Cookie $auth_cookie_name_1;
        #         }

        #         # proxy_pass http://backend/;
        #         # or "root /path/to/site;" or "fastcgi_pass ..." etc
        #       '';
        #     };
        #     "/oauth2/" = {
        #       extraConfig = ''
        #         proxy_pass       http://127.0.0.1:4180;
        #         proxy_set_header Host                    $host;
        #         proxy_set_header X-Real-IP               $remote_addr;
        #         proxy_set_header X-Auth-Request-Redirect $request_uri;
        #         # or, if you are handling multiple domains:
        #         # proxy_set_header X-Auth-Request-Redirect $scheme://$host$request_uri;
        #       '';
        #     };
        #     "/oauth2/auth" = {
        #       extraConfig = ''
        #         proxy_pass       http://127.0.0.1:4180;
        #         proxy_set_header Host             $host;
        #         proxy_set_header X-Real-IP        $remote_addr;
        #         proxy_set_header X-Forwarded-Uri  $request_uri;
        #         # nginx auth_request includes headers but not body
        #         proxy_set_header Content-Length   "";
        #         proxy_pass_request_body           off;
        #       '';
        #     };
        #     # "/sso-auth" = {
        #     #   extraConfig = ''
        #     #     # # Do not allow requests from outside
        #     #     # internal;
        #     #     # Access /auth endpoint to query login state
        #     #     proxy_pass http://127.0.0.1:8082/auth;
        #     #     # Do not forward the request body (nginx-sso does not care about it)
        #     #     proxy_pass_request_body off;
        #     #     proxy_set_header Content-Length "";
        #     #     # Set custom information for ACL matching: Each one is available as
        #     #     # a field for matching: X-Host = x-host, ...
        #     #     proxy_set_header X-Origin-URI $request_uri;
        #     #     proxy_set_header X-Host $http_host;
        #     #     proxy_set_header X-Real-IP $remote_addr;
        #     #     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        #     #     proxy_set_header X-Forwarded-Proto $scheme;
        #     #     proxy_set_header X-Application "kibana";
        #     #   '';
        #     # };
          # };
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
          #     proxyPass = "https://vouch.roses.gdvoisins.com/validate";
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
        # };
      };
    };

    # oauth2-proxy = {
    #   enable = true;

    #   # # Common configuration
    #   # provider = "keycloak-oidc"; # or "github", "gitlab", "azure", etc.
    #   # email.domains = ["*"]; # restrict to specific email domains
      
    #   # # Client credentials (register your app with the OAuth provider)
    #   clientID = "seafile";
    #   keyFile = "/etc/.secrets/.seafile_oauthproxy_keyfile";
    #   # # clientSecret = "your-client-secret";
      
    #   # # Cookie settings
    #   # cookie.secret = "NgbKPVOqtJn5bipSRGuR22BwasVS1J5u"; # generate with: openssl rand -base64 32 | head -c 32 | base64
      
    #   # # Additional settingsenvironment.systemPackages = with pkgs; [
    #   # # upstream = "http://localhost:1234"; # your backend service
    #   # httpAddress = "0.0.0.0:4180"; # where oauth2-proxy listens
    #   # reverseProxy = false;
    #   # upstream = "file:///var/www/default";
    #   # tls = {
    #   #   enable = true;
    #   #   certificate = "/var/lib/acme/roses.lgv.info/fullchain.pem";
    #   #   key = "/var/lib/acme/roses.lgv.info/key.pem";
    #   #   httpsAddress = ":41443";
    #   # };
    #   # redirectURL = "https://roses.lgv.info:41443/oauth2/callback";
    #   # oidcIssuerUrl = "https://key.lesgrandsvoisins.com/realms/master";
    #   extraConfig = {
    #     approval-prompt="force";
    #     client-id="seafile";
    #     client-secret-file="/etc/.secrets/.seafile_oauthproxy_keyfile";
    #     code-challenge-method="S256";
    #     cookie-csrf-expire="5m";
    #     cookie-csrf-per-request="true";
    #     cookie-domain="roses.lgv.info";
    #     cookie-expire="168h0m0s";
    #     cookie-httponly="false";
    #     cookie-name="_oauth2_proxy_roses";
    #     cookie-refresh="5m";
    #     cookie-samesite="none";
    #     cookie-secret="NgbKPVOqtJn5bipSRGuR22BwasVS1J5u";
    #     cookie-secure="false";
    #     email-domain="*" ;
    #     http-address=":4180";
    #     https-address=":41443";
    #     insecure-oidc-allow-unverified-email="true" ;
    #     oidc-issuer-url="https://key.lesgrandsvoisins.com/realms/master";
    #     pass-access-token="true";
    #     pass-authorization-header="true";
    #     pass-host-header="true" ;
    #     provider="keycloak-oidc";
    #     proxy-prefix="/oauth2" ;
    #     redirect-url="https://roses.lgv.info/oauth2/callback";
    #     request-logging="true";
    #     reverse-proxy="true";
    #     session-store-type="cookie";
    #     set-authorization-header="true";
    #     set-xauthrequest="true";
    #     skip-provider-button="false";
    #     tls-cert-file="/var/lib/acme/roses.lgv.info/fullchain.pem";
    #     tls-key-file="/var/lib/acme/roses.lgv.info/key.pem";
    #     upstream="file:///var/www/default";
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
      listenAddresses = [
        {
          addr = "0.0.0.0";
          port = 22;
        } 
        {
          addr = "[::]";
          port = 22;
        } 
      ];
      settings.PermitRootLogin = "no";
    };
    rsyncd.enable = true;
  };
}
