{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
}:
pkgs.stdenv.mkDerivation rec {
  pname = "update-initials";
  version = "1.0";

  src = null;

  phases = ["installPhase"];

  installPhase = ''
        mkdir -p $out/bin
        cat > $out/bin/update-initials.sh <<'EOF'
    #!/usr/bin/env bash
    set -euo pipefail

    # Load environment file
    if [ -f /etc/ldap-initials.env ]; then
      source /etc/ldap-initials.env
    else
      echo "Environment file /etc/ldap-initials.env not found" >&2
      exit 1
    fi

    # Search LDAP for entries missing 'initials'
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
    EOF

        chmod +x $out/bin/update-initials.sh
  '';
}
