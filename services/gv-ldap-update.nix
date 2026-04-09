{
  config,
  pkgs,
  ...
}: let
  gv-ldap-update = import ./gv-ldap-update/default.nix {inherit pkgs;};
  vars = import ../vars.nix;
in {
  environment.systemPackages = [
    gv-ldap-update
    pkgs.gawk
    pkgs.openldap
    pkgs.bash
  ];

  systemd.tmpfiles.rules = [
    "d /etc/gv.je 0775 services services"
    "f /etc/gv.je/ldap.env 0600 services services"
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
  # environment.etc."ldap-initials.env".mode = "0600"; # secure

  systemd.services.gv-ldap-update = {
    description = "Populate LDAP initials if missing";
    serviceConfig.Type = "oneshot";
    serviceConfig.EnvironmentFile = "/etc/gv.je/ldap.env";
    serviceConfig.ExecStart = "${gv-ldap-update}/bin/gv-ldap-update.sh";
    serviceConfig = {
      # WorkingDirectory = "/home/guichet/guichet";
      User = "services";
      Group = "services";
    };
    path = with pkgs; [
      gawk
      bash
      openldap
    ];
  };

  systemd.timers.gv-ldap-update = {
    description = "Run LDAP initials update hourly";
    timerConfig.OnCalendar = "*:0/20"; # every 20 minutes
    timerConfig.Persistent = true;
    wantedBy = ["timers.target"];
  };
}
