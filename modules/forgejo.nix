{
  config,
  pkgs,
  lib,
  # vars,
  ...
}: let
  vars = import ../vars.nix;
in {
  users.users.forgejo = {
    uid = vars.uid.forgejo;
    group = "services";
  };
  networking.hosts = {
    # "::1" = [ "radicale.local" ];
    "${builtins.elemAt vars.ip6s.hosts 1}" = ["forgejo.lan"];
  };
  # systemd.services.forgeo-init = {
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = ''
  #       forgejo cert --host forgejo.lan;
  #       chown forgejo:services *
  #     '';
  #     RemainAfterExit = "yes";
  #     WorkingDirectory = "/etc/forgejo/certs";
  #     # User = "forgejo";
  #     # Group = "services";
  #   };
  #   path = [pkgs.forgejo];
  #   # enableDefaultPath = true;
  #   wantedBy = ["multi-user.target"];
  #   description = "Initiate the Forgejo service mainly with statistics";
  #   enable = true;
  # };
  environment.systemPackages = with pkgs; [
    forgejo
  ];
  services.caddy.virtualHosts."forgejo.roses.gv.je" = {
    extraConfig = ''
      redir /user/login /user/oauth2/key.gv.je
      reverse_proxy https://forgejo.lan:${builtins.toString vars.ports.forgejo-https} {

        transport http {
          tls
          tls_server_name forgejo.lan
          tls_trust_pool file {
            pem_file /etc/forgejo/certs/cert.pem
          }
          tls_insecure_skip_verify # Modifier ceci !
        }
      }
    '';
  };
  services.postgresql = {
    ensureUsers = [
      {
        name = "forgejo";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = ["forgejo"];
  };
  systemd.tmpfiles.rules = [
    "d /etc/forgejo 0755 forgejo services"
    "d /etc/forgejo/certs 0755 forgejo services"
    "f /etc/forgejo/oauth2_jwt_secret 0640 forgejo services"
    # "L /var/run/postgresql/.s.PGSQL.5434                  -    -    -     -           /var/run/postgresql/.s.PGSQL.5432"
    # "L+  ${pkgs.forgejo}/bin/forgejo - - - - /etc/forgejo/forgejo"
  ];
  services.forgejo = {
    enable = true;
    group = "services";
    secrets.mailer.PASSWD = "/etc/forgejo/.listlesgrandsvoisinscom";
    database = {
      type = "postgres";
      # socket = "/var/run/postgresql";
      host = "/var/run/postgresql";
      # port = 5434;
    };
    lfs.enable = true;
    settings = {
      DEFAULT = {
        APP_NAME = "Forge des GV";
        APP_SLOGAN = "forgejo.roses.gv.je sur la technologie Forgejo";
      };
      cors = {
        ENABLED = true;
        ALLOW_DOMAIN = "https://public.gv.je";
        ALLOW_CREDENTIALS = true;
      };
      oauth2 = {
        ENABLED = true;
        # JWT_SECRET_URI = "file:/etc/forgejo/oauth2_jwt_secret";
      };
      # openid = {
      #   ENABLE_OPENID_SIGNIN = true;
      #   ENABLE_OPENID_SIGNUP = true;
      # };
      session = {
        COOKIE_SECURE = true;
      };
      service = {
        # ENABLE_REVERSE_PROXY_AUTHENTICATION = true;
        # REVERSE_PROXY_AUTHENTICATION_USER = "X_REMOTE_USER"; # Otherwise X-WEBAUTH-USER
        # ENABLE_REVERSE_PROXY_AUTO_REGISTRATION = true;
        DISABLE_REGISTRATION = false;
        SHOW_REGISTRATION_BUTTON = false;
        REQUIRE_SIGNIN_VIEW = true;
        ENABLE_BASIC_AUTHENTICATION = false;
        ENABLE_PASSWORD_SIGNIN_FORM = false;
      };
      oauth2_client = {
        # REGISTER_EMAIL_CONFIRM = "disable";
        REGISTER_EMAIL_CONFIRM = false;
        ENABLE_AUTO_REGISTRATION = true;
        USERNAME = "email";
        UPDATE_AVATAR = true;
        ACCOUNT_LINKING = "auto";
      };
      server = {
        DOMAIN = "forgejo.roses.gv.je";
        PROTOCOL = "https";
        ROOT_URL = "https://forgejo.roses.gv.je";
        # LOCAL_ROOT_URL
        DISABLE_REGISTRATION = true;
        HTTP_ADDR = "${builtins.elemAt vars.ip6s.hosts 1}";
        HTTP_PORT = vars.ports.forgejo-https;
        SSH_PORT = vars.ports.forgejo-ssh;
        SSH_LISTEN_HOST = builtins.toString vars.ip4s.lan;
        CERT_FILE = "/etc/forgejo/certs/cert.pem";
        KEY_FILE = "/etc/forgejo/certs/key.pem";
        # CERT_FILE = "/etc/forgejo/certs/cert.pem";
        # KEY_FILE = "/etc/forgejo/certs/key.pem";
        START_SSH_SERVER = true;
        LFS_START_SERVER = true;
      };
      "cron.sync_external_users" = {
        RUN_AT_START = true;
        SCHEDULE = "@every 24h";
        UPDATE_EXISTING = true;
      };
      mailer = {
        ENABLED = true;
        PROTOCOL = "smtps";
        SMTP_ADDR = "mail.lesgrandsvoisins.com";
        SMTP_PORT = "465";
        FROM = "Gitea Service <list@lesgrandsvoisins.com>";
        USER = "list@lesgrandsvoisins.com";
      };
      other = {
        SHOW_FOOTER_VERSION = false;
      };
    };
  };
}
