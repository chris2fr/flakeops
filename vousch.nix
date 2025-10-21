{ config, pkgs, lib, ... }: {

  systemd.services.vouch-proxy =
    let
      vouchConfig = {
        vouch = {
          # testing = true;
          listen = "[::1]";
          port = 30746;

          # TODO this allows everybody that can authenticate to kanidm, so no
          # further scoping possible atm.
          allowAllUsers = true;
          cookie.domain = "erictapen.name";

          jwt.secret = "redacted, don't know where I got this from";
        };
        oauth =
          let
            kanidmOrigin = config.services.kanidm.serverSettings.origin;
          in
          rec {
            provider = "oidc";
            client_id = "gollum";
            # oauth2_rs_basic_secret from `kanidm system oauth2 get gollum`
            client_secret = "redacted";
            auth_url = "${kanidmOrigin}/ui/oauth2";
            token_url = "${kanidmOrigin}/oauth2/token";
            user_info_url = "${kanidmOrigin}/oauth2/openid/${client_id}/userinfo";
            scopes = [ "login" ];
            callback_url = "https://login.erictapen.name/auth";
            code_challenge_method = "S256";
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

  # services.nginx = {
  #   enable = true;
  #   virtualHosts."login.erictapen.name" = {
  #     enableACME = true;
  #     forceSSL = true;
  #     locations."/" = {
  #       proxyPass = "http://[::1]:${toString 30746}/";
  #       extraConfig = ''
  #         proxy_set_header Host $host;
  #         add_header Access-Control-Allow-Origin https://auth.erictapen.name;
  #       '';
  #     };
  #   };
  # };

}
