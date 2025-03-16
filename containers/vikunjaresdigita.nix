{ config, pkgs, lib, ... }:
let
in {
  # systemd.tmpfiles.rules = [ "d /var/local/vikunjaresdigitacom 0755 vikunjaresdigitacom users" ];
  users.users.vikunjaresdigitacom = {
    isNormalUser = true;
    uid = 11113;
  };
  containers.vikunjaresdigitacom = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.109.1";
    localAddress = "192.168.109.2";
    hostAddress6 = "fc00::9:1";
    localAddress6 = "fc00::9:2";
    # bindMounts = {
    #   "///" = {
    #     hostPath = "///";
    #     isReadOnly = false;
    #   };
    # };
    config = { config, pkgs, ... }: {
      nix.settings.experimental-features = "nix-command flakes";
      time.timeZone = "Europe/Paris";
      system.stateVersion = "24.11";
      environment.systemPackages = with pkgs;
        [
          ((vim_configurable.override { }).customize {
            name = "vim";
            vimrcConfig.customRC = ''
              " your custom vimrc
              set mouse=a
              set nocompatible
              colo torte
              syntax on
              set tabstop     =2
              set softtabstop =2
              set shiftwidth  =2
              set expandtab
              set autoindent
              set smartindent
              " ...
            '';
          })
        ];
      systemd.services.vikunja.serviceConfig.User = lib.mkForce "vikunja";
      systemd.services.vikunja.serviceConfig.DynamicUser = lib.mkForce false;
      services.vikunja = {
        enable = true;
        frontendScheme = "https";
        frontendHostname = "vikunja.resdigita.com";
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
            username = "list@resdigita.com";
            # password.file = config.age.secrets."email.list".path;
          };
          defaultsettings = {
            week_start = 1;
            language = "fr-FR";
            timezone = "Europe/Paris";
            discoverable_by_email = true;
            discoverable_by_name = true;
          };
          service = { timezone = "Europe/Paris"; };
          auth = {
            local.enabled = false;
            openid.enabled = true;
            # openid.redirecturl = "https://vikunja.village.ngo/auth/openid/";
            # openid.redirecturl = "https://vikunja.gv.coop/auth/openid/";
            openid.redirecturl =
              "https://vikunja.resdigita.com/auth/openid/";
            openid.providers = [
              {
                name = "keyResdigitaCom";
                authurl = "https://key.resdigita.com/realms/master";
                logouturl =
                  "https://key.resdigita.com/realms/master/protocol/openid-connect/logout";
                clientid = "vikunja";
                clientsecret =
                  import ../secrets/keyresdigita.vikunja.nix;
                # clientsecret = config.age.secrets."keyresdigita.vikunja".path;
              }
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
              #   logouturl =
              #     "https://keycloak.village.ngo/realms/master/protocol/openid-connect/logout";
              #   clientid = "vikunja";
              #   clientsecret =
              #     import ../secrets/keyresdigita.vikunja.nix;
              #   # clientsecret.file = config.age.secrets."keycloak.vikunja".path;
              #   # clientsecret = keycloakVikunja;
              # }
            ];
          };
        };
      };
    };
  };
}
