#!/usr/bin/env bash
set -euo pipefail

# LDAP_URI="ldapi:///"
# BIND_DN="cn=admin,dc=example,dc=com"
# BIND_PW="secret"
# BASE_DN="dc=example,dc=com"

ldapsearch -Z -H "$LDAP_URI" -D "$BIND_DN" -w "$BIND_PW" \
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
    print dn
    print "changetype: modify"
    print "add: initials"
    print "initials: " initials
    print ""
  }
}' > /tmp/ldap-initials.ldif

if [ -s /tmp/ldap-initials.ldif ]; then
  ldapmodify -x -H "$LDAP_URI" -D "$BIND_DN" -w "$BIND_PW" -f /tmp/ldap-initials.ldif
fi

ldapsearch -Z -H "$LDAP_URI" -D "$BIND_DN" -w "$BIND_PW" \
  -b "$BASE_DN" "(&(cn=*)(!(mail=*@gv.je)((initials=*)))" dn initials |
awk '
BEGIN { RS=""; FS="\n" }
{
  dn=""; initials=""
  for(i=1;i<=NF;i++){
    if($i ~ /^dn:/) dn=$i
    if($i ~ /^initials:/) initials=$i
  }
  if(dn && initials){
    print dn
    print "changetype: modify"
    print "add: mail"
    print "mail: " initials "@gv.je"
    print ""
  }
}' > /tmp/ldap-mail.ldif

if [ -s /tmp/ldap-mail.ldif ]; then
  ldapmodify -x -H "$LDAP_URI" -D "$BIND_DN" -w "$BIND_PW" -f /tmp/ldap-mail.ldif
fi