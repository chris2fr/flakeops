{ config, pkgs, lib, ... }:
let
  lgvLdapDomainName = import ../vars/lgv-ldap-domain-name.nix;
  lgvLdapBaseDN = import ../vars/lgv-ldap-base-dn.nix;
  bindSlappasswd = import ../secrets/bind.slappasswd;
in
{
  containers.lgvldap = {
    autoStart = true;
    bindMounts = { 
      "/var/lib/acme/${lgvLdapDomainName}" = { 
        hostPath = "/var/lib/acme/${lgvLdapDomainName}";
        isReadOnly = false; 
      }; 
    };
    config = { config, pkgs, lib, ...  }: {
      nix.settings.experimental-features = "nix-command flakes";
      system.stateVersion = "24.11";
      time.timeZone = "Europe/Paris";
      environment.systemPackages = with pkgs; [
        lynx
        nettools
        wget
        dig
        ((vim_configurable.override {  }).customize{
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
          }
        )
        # postgresql_14
        pwgen
      ];
      # imports = [
      #   (builtins.fetchTarball {
      #     url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-24.05/nixos-mailserver-nixos-24.05.tar.gz";
      #     sha256 = "sha256:0clvw4622mqzk1aqw1qn6shl9pai097q62mq1ibzscnjayhp278b";
      #   })
      # ];
      users = {
        groups = {
          "acme".gid = 993;
          "wwwrun".gid = 54;
        };
        users = {
          "acme" = {
            uid = 994;
            group = "acme";
          };
          "wwwrun" = {
            uid = 54;
            group = "wwwrun";
          };
        };
      };
      systemd.tmpfiles.rules = [
        "d /var/lib/acme/${lgvLdapDomainName} 0755 acme wwwrun"
        "f /var/lib/openldap/pmw/schema/pwm.ldif 0755 openldap openldap"
        "d /var/www/lesgrandsvoisins.com/ldap 0775 wwwrun wwwrun"
      ];
      security.acme.defaults.email = "chris@mann.fr";
      security.acme.acceptTerms = true;
      services = {
        openldap = {
          enable = true;
          urlList = ["ldap://${lgvLdapDomainName}:14389/ ldaps://${lgvLdapDomainName}:14636/ ldapi:///"];
          # urlList = ["ldap://${lgvLdapDomainName}:14389/ ldaps://${lgvLdapDomainName}:14636/ ldapi:///"];
          settings = {
            attrs = {
              olcLogLevel = "conns config";
              /* settings for acme ssl */
              olcTLSCACertificateFile = "/var/lib/acme/${lgvLdapDomainName}/full.pem";
              olcTLSCertificateFile = "/var/lib/acme/${lgvLdapDomainName}/full.pem";
              olcTLSCertificateKeyFile = "/var/lib/acme/${lgvLdapDomainName}/key.pem";
              olcTLSCipherSuite = "HIGH:MEDIUM:+3DES:+RC4:+aNULL";
              olcTLSCRLCheck = "none";
              olcTLSVerifyClient = "never";
              olcTLSProtocolMin = "3.1";
              olcThreads = "16";
            };
             # Flake this
            children = {
              "cn=schema".includes = [
                "${pkgs.openldap}/etc/schema/core.ldif"
                "${pkgs.openldap}/etc/schema/cosine.ldif"
                "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
                "${pkgs.openldap}/etc/schema/nis.ldif"
              ]; 
              "olcDatabase={1}mdb".attrs = {
                objectClass = [ "olcDatabaseConfig" "olcMdbConfig" ];
                olcDbIndex = [
                  "displayName,description eq,sub"
                  "uid,ou,c eq"
                  "carLicense,labeledURI,telephoneNumber,mobile,homePhone,title,street,l,st,postalCode eq"
                  "objectClass,cn,sn,givenName,mail eq"
                ];
                olcDatabase = "{1}mdb";
                olcDbDirectory = "/var/lib/openldap/data";
                olcSuffix = "${lgvLdapBaseDN}";
                /* your admin account, do not use writeText on a production system */
                olcRootDN = "cn=admin,${lgvLdapBaseDN}";
                olcRootPW = "${bindSlappasswd}";
                olcAccess = [
                  /* custom access rules for userPassword attributes */
                  /* allow read on anything else */
                  ''{0}to dn.subtree="ou=newusers,${lgvLdapBaseDN}"
                      by dn.exact="cn=newuser,ou=users,${lgvLdapBaseDN}" write
                      by group.exact="cn=administration,ou=groups,${lgvLdapBaseDN}" write
                      by self write
                      by anonymous auth
                      by * read''
                  ''{1}to dn.subtree="ou=invitations,${lgvLdapBaseDN}"
                      by dn.exact="cn=newuser,ou=users,${lgvLdapBaseDN}" write
                      by group.exact="cn=administration,ou=groups,${lgvLdapBaseDN}" write
                      by self write
                      by anonymous auth
                      by * read''
                  ''{2}to dn.subtree="ou=users,${lgvLdapBaseDN}"
                      by dn.exact="cn=admin@lesgrandsvoisins.com,ou=users,${lgvLdapBaseDN}" manage
                      by dn.exact="cn=newuser,ou=users,${lgvLdapBaseDN}" write
                      by group.exact="cn=administration,ou=groups,${lgvLdapBaseDN}" write
                      by self write
                      by anonymous auth
                      by * read''
                  ''{3}to attrs=userPassword
                      by dn.exact="cn=admin@lesgrandsvoisins.com,ou=users,${lgvLdapBaseDN}" manage
                      by self write
                      by anonymous auth
                      by * none''
                  ''{4}to *
                      by dn.exact="cn=sogo@lesgrandsvoisins.com,ou=users,${lgvLdapBaseDN}" manage
                      by dn.exact="cn=chris@lesgrandsvoisins.com,ou=users,${lgvLdapBaseDN}" manage
                      by dn.exact="cn=chris@mann.fr,ou=users,${lgvLdapBaseDN}" manage
                      by dn.exact="cn=admin@lesgrandsvoisins.com,ou=users,${lgvLdapBaseDN}" manage
                      by self write
                      by anonymous auth''
                  /* custom access rules for userPassword attributes */
                  ''{5}to attrs=cn,sn,givenName,displayName,member,memberof
                      by self write
                      by * read''
                  ''{6}to *
                      by * read''
                ];
              };
            };
          };
        };
      };
      systemd.services.openldap = {
        wants = [ "acme-${lgvLdapDomainName}.service" ];
        after = [ "acme-${lgvLdapDomainName}.service" ];
        serviceConfig = {
          RemainAfterExit = false;
        };
      };
      users.groups.wwwrun.members = [ "openldap" ];
      users.groups.acme.members = [ "openldap" ];
    };
  };
}