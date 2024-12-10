{ config, pkgs, lib, ... }:
let 
in{
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
    settings = {
      mailer = {
        enabled = true;
        host = "mail.lesgrandsvoisins.com";
        authtype = "login";
        username = "list@lesgrandsvoisins.com";
        # password.file = config.age.secrets."email.list".path;
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
      auth = {
        local.enabled = false;
        openid.enabled = true;
        # openid.redirecturl = "https://vikunja.village.ngo/auth/openid/";
        # openid.redirecturl = "https://vikunja.gv.coop/auth/openid/";
        openid.redirecturl = "https://task.lesgrandsvoisins.com/auth/openid/";
        openid.providers = [
        {
          name = "keyLesGrandsVoisinsCom";
          authurl = "https://key.lesgrandsvoisins.com/realms/master";
          logouturl = "https://key.lesgrandsvoisins.com/realms/master/protocol/openid-connect/logout";
          clientid = "vikunja";
          clientsecret = import ../secrets/keylesgrandsvoisins.vikunja.nix;
          # clientsecret = config.age.secrets."keylesgrandsvoisins.vikunja".path;
        }
        # {
        #   name = "keyGVcoop";
        #   authurl = "https://key.gv.coop/realms/master";
        #   logouturl = "https://key.gv.coop/realms/master/protocol/openid-connect/logout";
        #   clientid = "vikunja";
        #   clientsecret = keyGVcoopVikunja;
        # }
        {
          name = "VillageNgo";
          authurl = "https://keycloak.village.ngo/realms/master";
          logouturl = "https://keycloak.village.ngo/realms/master/protocol/openid-connect/logout";
          clientid = "vikunja";
          clientsecret = import ../secrets/keylesgrandsvoisins.vikunja.nix;
          # clientsecret.file = config.age.secrets."keycloak.vikunja".path;
          # clientsecret = keycloakVikunja;
        }
        ];
      };
    };
  };
}