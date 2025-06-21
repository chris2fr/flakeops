{ config, pkgs, lib, ... }:
let 
in
{
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
      upstream = ["file://var/www/default/" "file:///var/www/default/"];
      oidcIssuerUrl = "https://key.lesgrandsvoisins.com/realms/master";
      clientID = "seafile";
      # clientSecret = "YOUR_CLIENT_SECRET";
      keyFile = "/etc/.secrets/.seafile_oauthproxy_keyfile";
      redirectURL = "https://roses.lgv.info:41443/oauth2/callback";
      cookie.secret = "afet530fdxaf24506hgnsdfr";  # must be 16, 24, or 32 chars
      cookie.httpOnly = false;
      setXauthrequest = true;
      passAccessToken = true;
      email.domains = ["*"];
      scope = "profile openid email";
      reverseProxy = true;
      # cookie.secure = false; # Revisit
      cookie.domain = "roses.lgv.info";
      # ... add other options as needed ...
      # passHostHeader = false;lesgrandsvoisins.com
      # nginx.domain = "roses.lgv.info";
      # nginx.proxy = "192.168.1.100";

      extraConfig = {
        code-challenge-method="S256";
        whitelist-domain="roses.lgv.info";
        insecure-oidc-allow-unverified-email="true";
        # cookie-domains="roses.lgv.info";
      };
    };
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