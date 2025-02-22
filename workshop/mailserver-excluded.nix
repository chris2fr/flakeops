{ config, pkgs, lib, ... }:
let
  # bindPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bind));
  # alicePassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.alice));
  # bobPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bob));
  # sogoPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.sogo));
  # oauthPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.oauthpassword));
  # mailServerDomainAliases = [ 
  #   #"mail.resdigita.com"
  #   # "francemali.org"
  #   #"desgrandsvoisins.com"
  #   #"mail.desgrandsvoisins.com"
  #   #"mail.resdigita.org"
  #   # "gv.coop"
  #   #"mail.gv.coop"
  #   # "hopgv.com"
  #   # "hopgv.org"
  #   # "gvois.com"
  #   # "gvois.org"
  #   # "resdigita.org"
  #   # "cfran.org"
  #   # "gvpublic.org"
  #   # "gvpublic.com"
  #   # "fastoche.org"
  #   # "villageparis.org"
  # ];
in
{

  imports = [
    # (builtins.fetchTarball {
    #   url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-24.11/nixos-mailserver-nixos-24.11.tar.gz";
    #   sha256 = "sha256:0clvw4622mqzk1aqw1qn6shl9pai097q62mq1ibzscnjayhp278b";
    #   # url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/ldap-support/nixos-mailserver-nixos-24.11.tar.gz";
    #   # sha256 = "sha256:15v6b5z8gjspps5hyq16bffbwmq0rwfwmdhyz23frfcni3qkgzpc";
    # })
  ];
  environment.systemPackages = with pkgs; [
    # postgresql_14
  ];

  users.users.nginx.extraGroups = [ "wwwrun" ];
  #  phpEnv."PATH" = lib.makeBinPath [ pkgs.php ];
};
services = {

memcached = {
enable = true;
# maxMemory = 256;
# enableUnixSocket = true;
# port = 11211;
# listen = "[::1]";
# user = "sogo";
};
};

# SOGoMemcachedHost = "/var/run/memcached.sock";
###################################################################################################################################
mailserver = {

# loginAccounts = {
#   "chris@lesgrandsvoisins.com" = {
#       aliases = [ "testalias@resdigita.com" ];
#   };
# };   

# loginAccounts."chris@lesgrandsvoisins.com".catchAll = [
#   "lesgrandsvoisins.com"
#   "lesgrandsvoisins.fr"
#   "resdigita.com"
# ];

uris = [
# "ldapi:///"
# "ldaps://ldap.gv.coop:10636/"
# "ldap://ldap.gv.coop:10389/"
];

# tlsCAFile = "/var/lib/acme/${domainName}/fullchain.pem";
# tlsCAFile = "/var/lib/acme/ldap.gv.coop/fullchain.pem";
# startTls = true;
# uidAttribute = "cn";
#  filter = "(cn=%s)";
};
# postfix.filter = "(&(objectClass=inetOrgPerson)(cn=%u))";
# postfix.filter = "";
# dovecot.userAttrs = ''
#   =mail=%{ldap:cn}
# '';
# dovecot.userAttrs = ''
#   =home=%{ldap:homeDirectory}, \
#        =uid=%{ldap:uidNumber}, \
#        =gid=%{ldap:gidNumber}
# '';
# dovecot = {
#   userFilter = "(mail=%u)";
#   passFilter = "(|(cn=%u)(uid=%u)(mail=%u))";
# };
};
# extraVirtualAliases = {
#   "axel.leroux@lesgrandsvoisins.com" = [
#     "axel.leroux@resdigita.com  "
#     "alex.leroux@resdigita.com "
#     "alex.quatorzien@resdigita.com"
#     "axel.quatorzien@resdigita.com"
#     "alex.desmoulins@resdigita.com"
#     "axel.desmoulins@resdigita.com"
#   ];
#   "chris@lesgrandsvoisins.com" = [
#     "testalias@resdigita.com"
#     "bienvenue@lesgrandsvoisins.com"
#     "chris@lesgrandsvoisins.fr"
#     "chris@fastoche.org"
#     "lesgdvoisins@lesgrandsvoisins.com"
#     "quiquoietc@lesgrandsvoisins.com"
#     "whowhatetc@lesgrandsvoisins.com"
#     "gdvoisins@lesgrandsvoisins.com"
#     "grandvoisinage@lesgrandsvoisins.com"
#     "lesgrandsvoisins@lesgrandsvoisins.com"
#     "@resdigita.com"
#     "@resdigita.org"
#     "@cfran.org"
#     "@hopgv.com"
#     "@hopgv.org"
#     "@gvois.com"
#   ];
# };
# forwards = {
#     "axel.leroux@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
#     "alex.leroux@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
#     "alex.quatorzien@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
#     "axel.quatorzien@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
#     "alex.desmoulins@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
#     "axel.desmoulins@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
#     "testalias@resdigita.com" = "chris@lesgrandsvoisins.com";
#     "bienvenue@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
#     "chris@lesgrandsvoisins.fr" = "chris@lesgrandsvoisins.com";
#     "chris@fastoche.org" = "chris@lesgrandsvoisins.com";
#     "lesgdvoisins@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
#     "quiquoietc@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
#     "whowhatetc@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
#     "gdvoisins@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
#     "grandvoisinage@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
#     "lesgrandsvoisins@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
#     "@gvois.org" = "chris@lesgrandsvoisins.com";
#     "@resdigita.com" = "chris@lesgrandsvoisins.com";
#     "@resdigita.org" = "chris@lesgrandsvoisins.com";
#     "@cfran.org" = "chris@lesgrandsvoisins.com";
#     "@hopgv.com" = "chris@lesgrandsvoisins.com";
#     "@hopgv.org" = "chris@lesgrandsvoisins.com";
#     "@gvois.com" = "chris@lesgrandsvoisins.com";
# };
# forwards = {
#   "postmaster@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
#   "dmarc@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
# };

# Use Let's Encrypt certificates. Note that this needs to set up a stripped
# down nginx and opens port 80.
# certificateScheme = "acme-nginx";
# certificateDomains = ("mail.resdigita.com" "gvoisin.com" );
# certificateFile = "/var/certs/cert-mail.resdigita.com.pem";
# certificateScheme = "acme";
# certificateDirectory = "/var/certs/";
# keyFile = "/var/certs/key-mail.resdigita.com.pem";
};
# services.postfix.config = {
#   "smtpd_relay_restrictions" = lib.mkForce "permit_sasl_authenticated, reject";
#   "smtpd_sasl_type" = lib.mkForce "dovecot";
#   "smtpd_sasl_path" = lib.mkForce "private/auth";
#   "smtpd_sasl_auth_enable" = lib.mkForce "yes";
# };

#services.postfix.networks = [
#  "localhost"
#  "127.0.0.1"
#  "[::1]"
#  "mail.resdigita.com"
#  "mail.lesgrandsvoisins.com"
#  "ooo.lesgrandsvoisins.com"
#  "51.159.223.7"
#  "2001:bc8:1201:900:46a8:42ff:fe22:e5b6"
#  ];
# services.nginx.virtualHosts."hetzner005.lesgrandsvoisins.com" = {
#   listen = [{ addr = "[::]"; port=8443; ssl=true; }  { addr = "0.0.0.0"; port=8443; ssl=true; } ];
#   sslCertificateKey = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/key.pem";
#   sslCertificate = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/fullchain.pem";
#   http2 = true;
#   addSSL = true;
#   locations."/".extraConfig = ''
#       grpc_pass grpc://localhost:8080;
#       grpc_set_header Host $host:$server_port;
#       grpc_set_header X-Forwarded-Proto "https";
#       grpc_set_header X-Forwarded-Port "443";
#   '';
# };
# services.nginx.virtualHosts."mail.lesgrandsvoisins.com" = {
#   # listen = [{ addr = "0.0.0.0"; port=8888; } { addr = "[::]"; port=8888; } { addr = "[::]"; port=8443; ssl=true; }  { addr = "0.0.0.0"; port=8443; ssl=true; } ];
#   forceSSL = true;
#   # addSSL = true;
#   enableACME = true;
#   # sslCertificateKey = "/var/lib/acme/mail.lesgrandsvoisins.com/key.pem";
#   # sslCertificate = "/var/lib/acme/mail.lesgrandsvoisins.com/fullchain.pem";
#   locations."/SOGo/" = {
#     proxyPass = "https://mail.lesgrandsvoisins.com:8443";
#   };
#   locations."/" = {
#     proxyPass = "https://mail.lesgrandsvoisins.com:8443";
#   };
#   # locations."/".extraConfig = ''
#   #     # proxy_pass http://authentik;
#   #     proxy_http_version 1.1;
#   #     proxy_set_header X-Forwarded-Proto $scheme;
#   #     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#   #     proxy_set_header Host $host;
#   #     proxy_set_header Upgrade $http_upgrade;
#   #     proxy_set_header Connection $connection_upgrade_keepalive;
#   #     proxy_redirect unix:/run/phpfpm/roundcube.sock https://hetzner005.lesgrandsvoisins.com;
#   #     chunked_transfer_encoding off;
#   #   '';
# };
# services.httpd.enablePHP = true;
# services.dovecot2 = {
#   sslServerCert = "/var/lib/acme/mail.lesgrandsvoisins.com/fullchain.pem";
#   sslServerKey = "/var/lib/acme/mail.lesgrandsvoisins.com/key.pem";
#   extraConfig = ''
#   auth_mechanisms = $auth_mechanisms oauthbearer xoauth2
#   auth_policy_server_timeout_msecs = 5000
#   ssl_ca = </etc/ssl/certs/ca-certificates.crt
#   ssl_client_cert = </var/lib/acme/mail.lesgrandsvoisins.com/fullchain.pem
#   ssl_client_key = </var/lib/acme/mail.lesgrandsvoisins.com/key.pem
#   passdb {
#     driver = oauth2
#     mechanisms = oauthbearer xoauth2
#     args = /usr/local/config/dovecot-oauth2.conf.ext
#   }
#   '';
# };
#     ssl_client_ca = </etc/ssl/certs/ca-certificates.crt
# security.acme.certs."mail.lesgrandsvoisins.com".group = lib.mkForce "wwwrun";
# users.users."web2ldap" = {
#   isNormalUser = true;
# };
}


