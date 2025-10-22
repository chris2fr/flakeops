{ config, pkgs, lib, ... }: {
  systemd.services.vouch-proxy =
    let
      vouchConfig = {
        vouch = {
          # testing = true;
          listen = "127.0.0.1";
          port = 30746;
          testing = true;

          # TODO this allows everybody that can authenticate to kanidm, so no
          # further scoping possible atm.
          allowAllUsers = true;
          cookie.domain = "gdvoisins.com";
          # cookie.secure = false;
          # domains = ["gdvoisins.com" "roses.gdvoisins.com" "vouch.roses.gdvoisins.com" "static.roses.gdvoisins.com"];

          jwt.secret = import ./secrets/jwt-vouch-secret.nix;
        };
        oauth =
          let
            keycloaskOrigin = "https://key.lesgrandsvoisins.com/";
            keycloakRealm = "master";
          in
          rec {
            provider = "oidc";
            client_id = "rosest330";
            # oauth2_rs_basic_secret from `kanidm system oauth2 get gollum`
            client_secret = import ./secrets/oidc-roses-secret.nix;
            auth_url = "${keycloaskOrigin}/realms/${keycloakRealm}/protocol/openid-connect/auth";
            token_url = "${keycloaskOrigin}/realms/${keycloakRealm}/protocol/openid-connect/token";
            user_info_url = "${keycloaskOrigin}/realms/${keycloakRealm}/protocol/openid-connect/userinfo";
            scopes = [ "openid" "email" "profile" ];
            callback_url = "https://vouch.roses.gdvoisins.com/auth";
            code_challenge_method = "S256";
            tls.cert = "/var/lib/acme/vouch.roses.gdvoisins.com/full.pem";
            tls.key = "/var/lib/acme/vouch.roses.gdvoisins.com/key.pem";
          };
      };
    in
    {
      description = "Vouch-proxy";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart =
          ''
            ${pkgs.vouch-proxy}/bin/vouch-proxy \
              -config ${(pkgs.formats.yaml {}).generate "config.yml" vouchConfig}
          '';
        Restart = "on-failure";
        RestartSec = 5;
        WorkingDirectory = "/var/lib/vouch-proxy";
        StateDirectory = "vouch-proxy";
        RuntimeDirectory = "vouch-proxy";
        User = "vouch-proxy";
        Group = "vouch-proxy";
        StartLimitBurst = 3;
      };
    };

  users.users.vouch-proxy = {
    isSystemUser = true;
    group = "vouch-proxy";
  };
  users.groups.vouch-proxy = { };


  services.nginx.virtualHosts."vouch.roses.gdvoisins.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString 30746}/";
      extraConfig = ''
        proxy_set_header Host $host;
        add_header Access-Control-Allow-Origin https://key.lesgrandsvoisins.com;
        proxy_ssl_verify off;
        # proxy_set_header Host $host;
        # Maybe
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";
      '';
    };
  };

  # services.nginx = {
  #   enable = true;
  #   virtualHosts."login.erictapen.name" = {
  #     enableACME = true;
  #     forceSSL = true;
  #     locations."/" = {
  #       proxyPass = "http://127.0.0.1:${toString 30746}/";
  #       extraConfig = ''
  #         proxy_set_header Host $host;
  #         add_header Access-Control-Allow-Origin https://auth.erictapen.name;
  #       '';
  #     };
  #   };
  # };

}
