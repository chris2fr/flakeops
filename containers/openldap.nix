{ config, pkgs, lib, ... }:
let
  ldapDomainName = "ldap.gv.coop";
  ldapBaseDN = "dc=gv,dc=coop";
  bindSlappasswd = import ../secrets/bind.slappasswd;
in
{
  containers.openldap = {
    autoStart = true;
    # localAddress6 = "2a01:4f8:241:4faa::1";
    # privateNetwork = true;
    # hostAddress = "192.168.107.10";
    # localAddress = "192.168.107.11";
    # hostAddress6 = "fa01::1";
    # localAddress6 = "fa01::2";
    bindMounts = { 
      "/var/lib/acme/${ldapDomainName}" = { 
        hostPath = "/var/lib/acme/${ldapDomainName}";
        isReadOnly = false; 
      }; 
    };
    config = { config, pkgs, lib, ...  }: {
      nix.settings.experimental-features = "nix-command flakes";
      system.stateVersion = "24.05";
      # networking = {
      #   firewall.allowedTCPPorts = [ 18080 10389 10686 22 80 443 389 636 993 11211 25 ];
      #   # trustedInterfaces = ["eno1" "lo"];
      #   # hosts = {
      #   #   "192.168.107.11" = ["ldap.gv.coop"];
      #   # };
      #   # useHostResolvConf = true;
      #   useHostResolvConf = lib.mkForce false;
      #   # resolvconf.enable = true;
      # };
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
      #   # (builtins.fetchTarball {
      #   # url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-24.05/nixos-mailserver-nixos-24.05.tar.gz";
      #   #   sha256 = "sha256:0clvw4622mqzk1aqw1qn6shl9pai097q62mq1ibzscnjayhp278b";
      #   #   # url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/ldap-support/nixos-mailserver-nixos-24.05.tar.gz";
      #   #   # sha256 = "sha256:15v6b5z8gjspps5hyq16bffbwmq0rwfwmdhyz23frfcni3qkgzpc";
      #   # })
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
        "d /var/lib/acme/${ldapDomainName} 0755 acme wwwrun"
        "f /var/lib/openldap/pmw/schema/pwm.ldif 0755 openldap openldap"
        "d /var/www/lesgrandsvoisins.com/ldap 0775 wwwrun wwwrun"
      ];
      security.acme.defaults.email = "chris@mann.fr";
      security.acme.acceptTerms = true;
      services = {
        openssh = {
          enable = true;
        };

        # resolved = {
        #   enable = true;
        #   fallbackDns = [
        #       "8.8.8.8"
        #       "2001:4860:4860::8844"
        #     ];
        # };
        tomcat = {
          enable = true;
          extraEnvironment = [
            "PWM_APPLICATIONPATH=/var/tomcat/pwm"
          ];
          # extraConfigFiles = [
          #   "/var/tomcat/conf/extra-users.xml"
          # ];
          # javaOpts = [
          #   "-Dcom.sun.jndi.ldap.object.disableEndpointIdentification=true"
          # ];
          serverXml = ''<?xml version="1.0" encoding="UTF-8"?>
            <Server port="18005" shutdown="SHUTDOWN">
              <Listener className="org.apache.catalina.startup.VersionLoggerListener" />
              <!-- Security listener. Documentation at /docs/config/listeners.html
              <Listener className="org.apache.catalina.security.SecurityListener" />
              -->
              <!-- APR library loader. Documentation at /docs/apr.html -->
              <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
              <!-- Prevent memory leaks due to use of particular java/javax APIs-->
              <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
              <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
              <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />

              <!-- Global JNDI resources
                  Documentation at /docs/jndi-resources-howto.html
              -->
                <GlobalNamingResources>
                <!-- Editable user database that can also be used by
                    UserDatabaseRealm to authenticate users
                -->
                <Resource name="UserDatabase" auth="Container"
                          type="org.apache.catalina.UserDatabase"
                          description="User database that can be updated and saved"
                          factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
                          pathname="conf/extra-users.xml" />
                </GlobalNamingResources>
                <Service name="Catalina">
                 <Connector port="18080" protocol="HTTP/1.1"
                    connectionTimeout="20000"
                    redirectPort="8443"
                    maxParameterCount="1000"
                    />
                  <Engine name="Catalina" defaultHost="localhost">
                        <!-- Use the LockOutRealm to prevent attempts to guess user passwords
                        via a brute-force attack -->
                    <Realm className="org.apache.catalina.realm.LockOutRealm">
                      <!-- This Realm uses the UserDatabase configured in the global JNDI
                          resources under the key "UserDatabase".  Any edits
                          that are performed against this UserDatabase are immediately
                          available for use by the Realm.  -->
                      <Realm className="org.apache.catalina.realm.UserDatabaseRealm"
                            resourceName="UserDatabase"/>
                    </Realm>

                    <Host name="localhost"  appBase="webapps"
                          unpackWARs="true" autoDeploy="true">

                      <!-- SingleSignOn valve, share authentication between web applications
                          Documentation at: /docs/config/valve.html -->
                      <!--
                      <Valve className="org.apache.catalina.authenticator.SingleSignOn" />
                      -->

                      <!-- Access log processes all example.
                          Documentation at: /docs/config/valve.html
                          Note: The pattern used is equivalent to using pattern="common" -->
                      <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
                            prefix="localhost_access_log" suffix=".txt"
                            pattern="%h %l %u %t &quot;%r&quot; %s %b" />
                    </Host>
                  </Engine>
              </Service>
            </Server>
          '';
        };
        openldap = {
          enable = true;
          urlList = ["ldap://ldap.gv.coop:10389/ ldaps://ldap.gv.coop:10636/ ldapi:///"];
          #  urlList = ["ldap://ldap.gv.coop:10389/ ldaps://ldap.gv.coop:10636/ ldapi:///"];
          # urlList = [ 
          #   "ldap://ldap.gv.coop:10389/" 
          #   "ldap://192.168.107.11:10389/"
          #   "ldaps://192.168.107.11:10636/"
          #   "ldaps://ldap.gv.coop:10636/"
          #   "ldapi:///"
          #   "ldap://localhost:10389/"
          #   "ldaps://localhost:10636/" 
          # ];
          settings = {
            attrs = {
              # olcTLSReqCert = "allow" ;
              # TLS_CACERTDIR /home/myuser/cacertss
              # LDAPTLS_CACERT /home/myuser/cacerts@@s
              olcLogLevel = "conns config";
              /* settings for acme ssl */
              olcTLSCACertificateFile = "/var/lib/acme/${ldapDomainName}/full.pem";
              olcTLSCertificateFile = "/var/lib/acme/${ldapDomainName}/full.pem";
              # olcTLSCertificateFile = "/var/lib/acme/${ldapDomainName}/cert.pem";
              olcTLSCertificateKeyFile = "/var/lib/acme/${ldapDomainName}/key.pem";
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
                "/var/lib/openldap/pmw/schema/pwm.ldif"
              ]; 
              # Type: attribute
              # Name: pwmData
              # Definition: ( 1.3.6.1.4.1.35015.1.2.7 NAME 'pwmData' SYNTAX 1.3.6.1.4.1.1466.115.121.1.40 )


              # Type: attribute
              # Name: pwmEventLog
              # Definition: ( 1.3.6.1.4.1.35015.1.2.1 NAME 'pwmEventLog' SYNTAX 1.3.6.1.4.1.1466.115.121.1.40 )


              # Type: attribute
              # Name: pwmGUID
              # Definition: ( 1.3.6.1.4.1.35015.1.2.4 NAME 'pwmGUID' SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 )


              # Type: attribute
              # Name: pwmLastPwdUpdate
              # Definition: ( 1.3.6.1.4.1.35015.1.2.3 NAME 'pwmLastPwdUpdate' SYNTAX 1.3.6.1.4.1.1466.115.121.1.24 )


              # Type: attribute
              # Name: pwmOtpSecret
              # Definition: ( 1.3.6.1.4.1.35015.1.2.6 NAME 'pwmOtpSecret' SYNTAX 1.3.6.1.4.1.1466.115.121.1.40 )


              # Type: attribute
              # Name: pwmResponseSet
              # Definition: ( 1.3.6.1.4.1.35015.1.2.2 NAME 'pwmResponseSet' SYNTAX 1.3.6.1.4.1.1466.115.121.1.40 )


              # Type: attribute
              # Name: pwmToken
              # Definition: ( 1.3.6.1.4.1.35015.1.2.5 NAME 'pwmToken' SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 )


              # Type: objectclass
              # Name: pwmUser
              # Definition: ( 1.3.6.1.4.1.35015.1.1.1 NAME 'pwmUser' AUXILIARY MAY ( pwmLastPwdUpdate $ pwmEventLog $ pwmResponseSet $ pwmGUID $ pwmToken $ pwmOtpSecret $ pwmData ) )
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
                olcSuffix = "${ldapBaseDN}";
                /* your admin account, do not use writeText on a production system */
                olcRootDN = "cn=admin,${ldapBaseDN}";
                # olcRootPW = (builtins.readFile /etc/nixos/.secrets.bind);
                olcAccess = [
                  /* custom access rules for userPassword attributes */
                  /* allow read on anything else */
                  ''{0}to dn.subtree="ou=newusers,${ldapBaseDN}"
                      by dn.exact="cn=newuser@lesgrandsvoisins.com,ou=users,${ldapBaseDN}" write
                      by group.exact="cn=administration,ou=groups,${ldapBaseDN}" write
                      by self write
                      by anonymous auth
                      by * read''
                  ''{1}to dn.subtree="ou=invitations,${ldapBaseDN}"
                      by dn.exact="cn=newuser@lesgrandsvoisins.com,ou=users,${ldapBaseDN}" write
                      by group.exact="cn=administration,ou=groups,${ldapBaseDN}" write
                      by self write
                      by anonymous auth
                      by * read''
                  ''{2}to dn.subtree="ou=users,${ldapBaseDN}"
                      by dn.exact="cn=admin@lesgrandsvoisins.com,ou=users,${ldapBaseDN}" manage
                      by dn.exact="cn=newuser@lesgrandsvoisins.com,ou=users,${ldapBaseDN}" write
                      by group.exact="cn=administration,ou=groups,${ldapBaseDN}" write
                      by self write
                      by anonymous auth
                      by * read''
                  ''{3}to attrs=userPassword
                      by dn.exact="cn=admin@lesgrandsvoisins.com,ou=users,${ldapBaseDN}" manage
                      by self write
                      by anonymous auth
                      by * none''
                  ''{4}to *
                      by dn.exact="cn=sogo@lesgrandsvoisins.com,ou=users,${ldapBaseDN}" manage
                      by dn.exact="cn=chris@lesgrandsvoisins.com,ou=users,${ldapBaseDN}" manage
                      by dn.exact="cn=chris@mann.fr,ou=users,${ldapBaseDN}" manage
                      by dn.exact="cn=admin@lesgrandsvoisins.com,ou=users,${ldapBaseDN}" manage
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
      #  /* ensure openldap is launched after certificates are created */
      #  systemd.services.openldap = {
      #    wants = [ "acme-${ldapDomainNameomainName}.service" ];
      #    after = [ "acme-${ldapDomainName}.service" ];
      #  };
      #  /* make acme certificates accessible by openldap */
      #  security.acme.defaults.group = "certs";
      #  users.groups.certs.members = [ "openldap" ];
      #  /* trigger the actual certificate generation for your hostname */
      #  security.acme.certs."${ldapDomainName}" = {
      #    extraDomainNames = [];
      #  };
      #############################
      systemd.services.openldap = {
        wants = [ "acme-${ldapDomainName}.service" ];
        after = [ "acme-${ldapDomainName}.service" ];
        serviceConfig = {
          RemainAfterExit = false;
        };
      };
      users.groups.wwwrun.members = [ "openldap" ];
      users.groups.acme.members = [ "openldap" ];
    };
  };
}