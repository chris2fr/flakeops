{
  config,
  pkgs,
  lib,
  # vars,
  ...
}: let
  vars = import ../vars.nix;
in {
  users.users.gitea.uid = vars.uid.gitea;
  networking.hosts = {
    # "::1" = [ "radicale.local" ];
    "[::1]" = ["gitea.local"];
  };
  services.postgresql = {
    ensureUsers = [
      {
        name = "gitea";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = ["gitea"];
  };
  systemd.tmpfiles.rules = [
    "d /etc/gitea 0755 gitea services"
    "d /etc/gitea/certs 0755 gitea services"
    "f /etc/gitea/oauth2_jwt_secret 0640 gitea services"
    # "L /var/run/postgresql/.s.PGSQL.5434                  -    -    -     -           /var/run/postgresql/.s.PGSQL.5432"
    # "L+  ${pkgs.gitea}/bin/gitea - - - - /etc/gitea/gitea"
  ];
  services.gitea = {
    enable = true;
    group = "services";
    mailerPasswordFile = "/etc/gitea/.listlesgrandsvoisinscom";
    database = {
      type = "postgres";
      # socket = "/var/run/postgresql";
      host = "/var/run/postgresql";
      # port = 5434;
    };
    settings = {
      # oauth2 = {
      #   ENABLED = true;
      #   JWT_SECRET_URI = "file:/etc/gitea/oauth2_jwt_secret";
      # };
      openid = {
        ENABLE_OPENID_SIGNIN = true;
        ENABLE_OPENID_SIGNUP = true;
      };
      service = {
        # ENABLE_REVERSE_PROXY_AUTHENTICATION = true;
        # REVERSE_PROXY_AUTHENTICATION_USER = "X_REMOTE_USER"; # Otherwise X-WEBAUTH-USER
        # ENABLE_REVERSE_PROXY_AUTO_REGISTRATION = true;
        DISABLE_REGISTRATION = true;
      };
      server = {
        ROOT_URL = "https://gitea.roses.gv.je";
        # LOCAL_ROOT_URL
        DISABLE_REGISTRATION = true;
        PROTOCOL = "https";
        HTTP_PORT = vars.ports.gitea-https;
        SSH_PORT = vars.ports.gitea-ssh;
        CERT_FILE = "/etc/gitea/certs/gitea.local.pem";
        KEY_FILE = "/etc/gitea/certs/gitea.local-key.pem";
        # CERT_FILE = "/etc/gitea/certs/cert.pem";
        # KEY_FILE = "/etc/gitea/certs/key.pem";
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
