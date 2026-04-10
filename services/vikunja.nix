{
  config,
  pkgs,
  lib,
  ...
}: let
  vars = import ../vars.nix;
in {
  systemd.tmpfiles.rules = [
    "d /etc/vikunja 0755 vikunja services"
    "f /etc/vikunja/.env 0600 vikunja services"
  ];
  users.users.vikunja = {
    isSystemUser = true;
    group = "services";
    uid = vars.uid.vikunja;
  };
  systemd.services.vikunja.serviceConfig.User = lib.mkForce "vikunja";
  systemd.services.vikunja.serviceConfig.DynamicUser = lib.mkForce false;
  services.vikunja = {
    enable = true;
    frontendScheme = "https";
    frontendHostname = "task.lesgrandsvoisins.com";
    # environmentFiles = [ config.age.secrets."vikunja.env".path ];
    # frontendHostname = "vikunja.lesgrandsvoisins.com";
    # frontendHostname = "vikunja.gv.coop";
    # frontendHostname = "vikunja.village.ngo";
    # database.type = "postgres";
    # environmentFiles = ["/etc/vikunja/.env"];
    settings = {
      mailer = {
        enabled = true;
        host = "mail.lesgrandsvoisins.com";
        authtype = "login";
        username = "list@lesgrandsvoisins.com";
        # password.file = config.age.secrets."email.list".path;
        password.file = "/etc/vikunja/.secret.email.list";
      };
      defaultsettings = {
        week_start = 1;
        language = "fr-FR";
        timezone = "Europe/Paris";
        discoverable_by_email = true;
        discoverable_by_name = true;
      };
      service = {
        timezone = "Europe/Paris";
      };
      environmentFiles = [
        "/etc/vikunja/.env"
      ];
      auth = {
        local.enabled = false;
        openid.enabled = true;
        # openid.redirecturl = "https://vikunja.village.ngo/auth/openid/";
        # openid.redirecturl = "https://vikunja.gv.coop/auth/openid/";
        openid.redirecturl = "https://task.lesgrandsvoisins.com/auth/openid/";
        openid.providers = {
          "keygvnje" = {
            # key = "keygvnje";
            name = "key@gv.je";
            authurl = "https://key.gv.je/realms/master";
            lougouturl = "https://key.gv.je/realms/master/protocol/openid-connect/logout";
            clientid = "vikunja";
            # clientsecret = "KEYGVJE_VIKUNJA_CLIENT_SECRET";
            # clientsecret = "$KEYGVJE_VIKUNJA_CLIENT_SECRET";
            clientsecret.file = "/etc/vikunja/oidc_client_secret_keygvje";
            scope = "openid profile email";
          };
          "keycloakGDVoisins" = {
            # key = "keycloakGDVoisins";
            name = "keycloakGDVoisins";
            authurl = "https://keycloak.gdvoisins.com/realms/master";
            lougouturl = "https://keycloak.gdvoisins.com/realms/master/protocol/openid-connect/logout";
            clientid = "vikunja";
            # clientsecret = "$KEYCLOAK_VIKUNJA_CLIENT_SECRET";
            scope = "openid profile email";
            clientsecret.file = "/etc/vikunja/oidc_client_secret";
          };
          # {
          #   name = "keyLesGrandsVoisinsCom";
          #   authurl = "https://key.lesgrandsvoisins.com/realms/master";
          #   logouturl = "https://key.lesgrandsvoisins.com/realms/master/protocol/openid-connect/logout";
          #   clientid = "vikunja";
          #   clientsecret.file = "/etc/vikunja/oidc_client_secret"
          #   # clientsecret = import ../secrets/keylesgrandsvoisins.vikunja.nix;
          #   # clientsecret = config.age.secrets."keylesgrandsvoisins.vikunja".path;
          # }
          # {
          #   name = "keyGVcoop";
          #   authurl = "https://key.gv.coop/realms/master";
          #   logouturl = "https://key.gv.coop/realms/master/protocol/openid-connect/logout";
          #   clientid = "vikunja";
          #   clientsecret = keyGVcoopVikunja;
          # }
          # {
          #   name = "VillageNgo";
          #   authurl = "https://keycloak.village.ngo/realms/master";
          #   logouturl = "https://keycloak.village.ngo/realms/master/protocol/openid-connect/logout";
          #   clientid = "vikunja";
          #   clientsecret = import ../secrets/keylesgrandsvoisins.vikunja.nix;
          #   # clientsecret.file = config.age.secrets."keycloak.vikunja".path;
          #   # clientsecret = keycloakVikunja;
          # }
        };
      };
    };
  };
}
