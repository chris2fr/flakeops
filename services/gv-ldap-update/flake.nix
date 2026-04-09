{
  description = "NixOS configuration with LDAP initials updater";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    vars = import ../../vars.nix;
  in {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = system;
      modules = [
        ({
          config,
          pkgs,
          ...
        }: {
          # Ensure OpenLDAP is enabled (adjust your DB/schema as needed)
          services.openldap.enable = true;

          # Add the LDAP initials update script
          environment.etc."gv-ldap-update.sh".text = ''
            #!/usr/bin/env bash
            set -euo pipefail

            # LDAP_URI="ldapi:///"
            # BIND_DN="cn=admin,dc=example,dc=com"
            # BIND_PW="secret"
            # BASE_DN="dc=example,dc=com"

            ldapsearch -x -LLL -H "$LDAP_URI" -D "$BIND_DN" -w "$BIND_PW" \
              -b "$BASE_DN" "(&(cn=*)(!(initials=*)))" dn cn |
            awk '
            BEGIN { RS=""; FS="\n" }
            {
              dn=""; cn=""
              for(i=1;i<=NF;i++){
                if($i ~ /^dn:/) dn=$i
                if($i ~ /^cn:/) cn=$i
              }
              if(dn && cn){
                split(cn,a,"@")
                initials=a[1]
                print "dn: " dn
                print "changetype: modify"
                print "add: initials"
                print "initials: " initials
                print ""
              }
            }' > /tmp/ldap-initials.ldif

            if [ -s /tmp/ldap-initials.ldif ]; then
              ldapmodify -x -H "$LDAP_URI" -D "$BIND_DN" -w "$BIND_PW" -f /tmp/ldap-initials.ldif
            fi
          '';

          # Make script executable
          environment.etc."gv-ldap-update.sh".mode = "0755";

          # Define systemd service
          systemd.services.gv-ldap-update = {
            description = "Populate LDAP initials if missing";
            serviceConfig.Type = "oneshot";
            serviceConfig.ExecStart = "/etc/gv-ldap-update.sh";
          };

          # Define systemd timer
          systemd.timers.gv-ldap-update = {
            description = "Run LDAP initials update hourly";
            timerConfig.OnCalendar = "hourly";
            timerConfig.Persistent = true;
            wantedBy = ["timers.target"];
          };
        })
      ];
    };
  };
}
