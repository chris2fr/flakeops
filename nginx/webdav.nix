{ config, pkgs, lib, ... }:
let
  extraProxyHeaders = ''
    # proxy_redirect off;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    # proxy_set_header Host $host:$server_port;
  '';
in
{
  services.nginx.virtualHosts = {
    "dav.lesgrandsvoisins.com" = {
        extraConfig = "# proxy_protocol off;";
      serverAliases = [ "webdav.lesgv.org" ];
      enableACME = true;
      forceSSL = true;
      globalRedirect = "dav.resdigita.com";
    };
    "dav.resdigita.com" = {
      serverAliases = [ "webdav.lesgv.org" ];
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://dav.resdigita.com:8443/";
        extraConfig = extraProxyHeaders;
      };
      extraConfig = ''
        # proxy_protocol off;
        location = / {
            return 302 /redirect;
        }
      '';
    };
    "secret.lesgrandsvoisins.com" = {
        extraConfig = "# proxy_protocol off;";
      enableACME = true;
      forceSSL = true;
      serverAliases = [ "secret.resdigita.com" "keepass.lesgv.org" ];
      globalRedirect = "keepass.resdigita.com";
    };
    "keepass.resdigita.com" = {
        extraConfig = "# proxy_protocol off;";
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://keepass.resdigita.com:8443/";
        extraConfig = extraProxyHeaders;
      };
      # extraConfig = ''
      # location = / {
      #     return 302 /redirect;
      # }
      # '';
    };

    "keeweb.resdigita.com" = {
        extraConfig = "# proxy_protocol off;";
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://keeweb.resdigita.com:8443/";
        extraConfig = extraProxyHeaders;
      };
      # extraConfig = ''
      # location = / {
      #     return 302 /redirect;
      # }
      # '';
    };
  };
}
