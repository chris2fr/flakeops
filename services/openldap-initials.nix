{
  config,
  pkgs,
  ...
}: let
  updateOpenldap = import ./openldap-initials/flake.nix {inherit pkgs;};
  vars = import ../vars.nix;
in {
  environment.systemPackages = [updateOpenldap];

  systemd.tmpfiles.rules = [
    "d /etc/gv.je 0775 services services"
    "d /etc/gv.je/ldap 0600 services services"
  ];
  users.users.services = {
    uid = vars.uid.services;
    group = "services";
    isSystemUser = true;
  };
  users.groups.services.gid = vars.gid.services;

  # Ensure the environment file exists
  # environment.etc."ldap-initials.env".text = ''
  #   LDAP_URI="ldapi:///"
  #   BIND_DN="cn=admin,dc=example,dc=com"
  #   BIND_PW="secret"
  #   BASE_DN="dc=example,dc=com"
  # '';
  environment.etc."ldap-initials.env".mode = "0600"; # secure

  systemd.services.update-initials = {
    description = "Populate LDAP initials if missing";
    serviceConfig.Type = "oneshot";
    serviceConfig.EnvironmentFile = "/etc/ldap-initials.env";
    serviceConfig.ExecStart = "${updateOpenldap}/bin/update-initials.sh";
    serviceConfig = {
      # WorkingDirectory = "/home/guichet/guichet";
      User = "services";
      Group = "services";
    };
  };

  systemd.timers.update-initials = {
    description = "Run LDAP initials update hourly";
    timerConfig.OnCalendar = "hourly";
    timerConfig.Persistent = true;
    wantedBy = ["timers.target"];
  };
}
