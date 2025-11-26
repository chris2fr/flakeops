    { config, pkgs, lib, filestash, ... }:
let 
  # oidcSeafileSecret = import ./secrets/oidc-seafile-secret.nix;
    oidcRosesSecret = import ./secrets/oidc-roses-secret.nix;
    jwtVouchSecret = import ./secrets/jwt-vouch-secret.nix;
in
{
  services.nginx = {
      enable = true;
      additionalModules = [ pkgs.nginxModules.luajit-resty-openidc ];
      # package = pkgs.angie;
      clientMaxBodySize = "10G";
      extraConfig = ''
        lua_shared_dict jwt_verification 10m;
      '';
            # appendConfig = ''
            #   location /validate {
            #     # forward the /validate request to Vouch Proxy
            #     proxy_pass http://vouch-proxy/validate;
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
        # };à
        "*" {
          root = "/var/www/default";
          listen = [
            { addr = "0.0.0.0" ; port = 80 }
            { addr = "[2a01:e0a:f4e:5880::9316:9fe2]" ; port = 80 }
            ];
          locations."/" = {
            proxyPass = "http://0.0.0.0:4060";
            # recommendedProxySettings = true;
            extraConfig = ''
              proxy_pass http://0.0.0.0:4060;
              proxy_set_header    Host $host;
              proxy_set_header    X-Real-IP $remote_addr;
              proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header    X-Forwarded-Host $host;
              proxy_set_header    X-Forwarded-Proto $scheme
              # rewrite ^/$  https://$host$request_uri;
            '';

        };
        "op.roses.gdvoisins.com" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/default";
          extraConfig = ''
            add_header Strict-Transport-Security max-age=2592000;
          '';
          locations."/" = {
            proxyPass = "http://127.0.0.1:4180";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_connect_timeout 1;
              proxy_send_timeout 30;
              proxy_read_timeout 30;
              proxy_set_header     X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto https;
            '';
          };
        };
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
              proxy_set_header X-Forwarded-Proto https;

            '';
              # proxy_set_header     X-Forwarded-Proto $scheme;

          };
        };
        # "fontenay.gdvoisins.com" = {
        #   forceSSL = true;
        #   enableACME = true;
        #   root = "/var/www/default";
        # };
        "static.roses.gdvoisins.com" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/default";
          # extraConfig = ''
          #       auth_request /validate;
          #       '';
          # locations = {
          #   "@error401" = {
          #     extraConfig = ''
          #       return 302 https://vp.roses.gdvoisins.com/oauth2/login?url=$scheme://$http_host$request_uri&vouch-failcount=$auth_resp_failcount&X-Vouch-Token=$auth_resp_jwt&error=$auth_resp_err;
          #     '';
          #       # return 302 https://op.roses.gdvoisins.com/oauth2/start?rd=$scheme://$host$request_uri;
          #   };
          #   "/oauth2/auth" = {
          #     extraConfig = ''
          #       internal;
          #       proxy_pass http://127.0.0.1:4180/oauth2/auth;
          #       proxy_set_header X-Original-URI $request_uri;
          #       proxy_set_header X-Real-IP $remote_addr;
          #       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          #       proxy_set_header X-Forwarded-Host $host;
          #       proxy_set_header X-Forwarded-Proto https;
                
          #     '';
          #   };
            "/" = {
              # proxyPass = "http://127.0.0.1:9090";
              # extraConfig = ''
              #   auth_request /oauth2/auth;
              #   error_page 401 = @error401;
              # '';
              # extraConfig = ''
              #   # you may need to set these variables in this block as per https://github.com/vouch/vouch-proxy/issues/26#issuecomment-425215810
              #      auth_request_set $auth_resp_x_vouch_user $upstream_http_x_vouch_user;
              #      auth_request_set $auth_resp_x_vouch_idp_claims_groups $upstream_http_x_vouch_idp_claims_groups;
              #      auth_request_set $auth_resp_x_vouch_idp_claims_given_name $upstream_http_x_vouch_idp_claims_given_name;

              #   # set user header (usually an email)
              #   proxy_set_header X-Vouch-User $auth_resp_x_vouch_user;
              #   # optionally pass any custom claims you are tracking
              #       # proxy_set_header X-Vouch-IdP-Claims-Groups $auth_resp_x_vouch_idp_claims_groups;
              #       # proxy_set_header X-Vouch-IdP-Claims-Given_Name $auth_resp_x_vouch_idp_claims_given_name;
              #   # optionally pass the accesstoken or idtoken
              #       # proxy_set_header X-Vouch-IdP-AccessToken $auth_resp_x_vouch_idp_accesstoken;
              #       # proxy_set_header X-Vouch-IdP-IdToken $auth_resp_x_vouch_idp_idtoken;
              # '';
            };
            # "/validate" = {
            #   # proxyPass = "http://unix://run/vouch-proxy/socket";
            #   # proxyPass = "http://vouch-proxy/validate";
            #   # proxyPass = "https://vouch.roses.gdvoisins.com/validate";
            #   extraConfig = ''
            #     # forward the /validate request to Vouch Proxy
            #     # proxy_pass http://127.0.0.1:30746/validate;
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
            #     proxy_pass https://vouch.roses.gdvoisins.com/validate;
            #     # proxy_set_header Host $host;
            #   '';
            # };
          };
        };
        "cw.roses.gdvoisins.com"  = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://0.0.0.0:4050";
        }
        "cp.roses.gdvoisins.com"  = {
          forceSSL = true;
          enableACME = true;
          # recommendedProxySettings = true;
          root = "/var/www/default";
          locations."/" = {

            proxyPass = "https://192.168.1.100:3923";
            extraConfig = ''
            proxy_set_header X-Forwarded-Proto https;


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
            # proxy_set_header   X-Forwarded-Proto $scheme;
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
          #       return 302 http://vouch.yourdomain.com/login?url=$scheme://$host$request_uri&vouch-failcount=$auth_resp_failcount&X-Vouch-Token=$auth_resp_jwt&error=$auth_resp_err;
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
  }