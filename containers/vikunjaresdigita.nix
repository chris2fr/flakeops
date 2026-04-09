{
  config,
  pkgs,
  lib,
  ...
}: let
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
    bindMounts = {
      "/var/run/listatlesgrandsvoisinscom" = {
        hostPath = config.age.secrets."email.list".path;
        isReadOnly = true;
      };
      # "/run/discourse/sockets/unicorn.sock"
    };
    # bindMounts = {
    #   "///" = {
    #     hostPath = "///";
    #     isReadOnly = false;
    #   };
    # };
    config = {
      config,
      pkgs,
      ...
    }: {
      imports = [
        ../common.nix
      ];
      nix.settings.experimental-features = "nix-command flakes";
      time.timeZone = "Europe/Paris";
      system.stateVersion = "25.11";
      networking = {
        interfaces."eth0".useDHCP = true;
        hostName = "vikunjaresdigitacom";
        firewall.enable = false;
        # firewall = {
        #   enable = true;
        #   allowedTCPPorts = [ 80 443 ];
        # };
        # Use systemd-resolved inside the container
        useHostResolvConf = lib.mkForce false;
      };
      security.acme.acceptTerms = true;
      environment.systemPackages = with pkgs; [
        ((vim-full.override {}).customize {
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
      users.users.vikunja = {
        isSystemUser = true;
        group = "vikunja";
      };
      users.groups."vikunja" = {};
      services.resolved.enable = true;
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
            authtype = "plain";
            # authtype = "login";
            username = "list@lesgrandsvoisins.com";
            password.file = "/var/run/listatlesgrandsvoisinscom";
            # username = "list@resdigita.com";
            # password.file = config.age.secrets."email.list".path;
          };
          defaultsettings = {
            week_start = 1;
            language = "fr-FR";
            timezone = "Europe/Paris";
            discoverable_by_email = true;
            discoverable_by_name = true;
          };
          service = {timezone = "Europe/Paris";};
          auth = {
            local.enabled = false;
            openid.enabled = true;
            # openid.redirecturl = "https://vikunja.village.ngo/auth/openid/";
            # openid.redirecturl = "https://vikunja.gv.coop/auth/openid/";
            openid.redirecturl = "https://vikunja.resdigita.com/auth/openid/";
            openid.providers = [
              {
                name = "keyResdigitaCom";
                authurl = "https://key.resdigita.com/realms/master";
                logouturl = "https://key.resdigita.com/realms/master/protocol/openid-connect/logout";
                clientid = "vikunja-resdigita-com";
                clientsecret = import ../secrets/keyresdigita.vikunja.nix;
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
