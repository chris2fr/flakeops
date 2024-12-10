{ config, pkgs, lib, ... }:
let
in
{
  # containers.mailserver = {
  #   autoStart = true;
  #   # localAddress6 = "2a01:4f8:241:4faa::1";
  #   privateNetwork = true;
  #   hostAddress = "192.168.107.10";
  #   localAddress = "192.168.107.11";
  #   hostAddress6 = "fa01::1";
  #   localAddress6 = "fa01::2";
  #   # bindMounts = { 
  #   #   "/var/lib/acme/${domainName}" = { 
  #   #     hostPath = "/var/lib/acme/${domainName}";
  #   #     isReadOnly = false; 
  #   #   }; 
  #   # };
  #   config = { config, pkgs, lib, ...  }: {
  #     imports = [
  #       (builtins.fetchTarball {
  #         url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/ldap-support/nixos-mailserver-nixos-24.05.tar.gz";
  #         # url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-24.05/nixos-mailserver-nixos-24.05.tar.gz";
  #         sha256 = "sha256:15v6b5z8gjspps5hyq16bffbwmq0rwfwmdhyz23frfcni3qkgzpc";
  #       })
  #     ];
  #     nix.settings.experimental-features = "nix-command flakes";
  #     system.stateVersion = "24.05";
  #     networking = {
  #       firewall.allowedTCPPorts = [ 22 80 443 1360 11211 25 ];
  #       # trustedInterfaces = ["eno1" "lo"];
  #       # hosts = {
  #       #   "192.168.107.11" = ["ldap.gv.coop"];
  #       # };
  #       # useHostResolvConf = true;
  #       useHostResolvConf = lib.mkForce false;
  #       # resolvconf.enable = true;
  #       nat = {
  #           externalIPv6 = "2a01:4f8:241:4faa::1";
  #           forwardPorts = [
  #             {
  #               destination = "192.168.107.11:1360";
  #               proto = "tcp";
  #               sourcePort = 1360;
  #             }
  #             {
  #               destination = "[fa01::2]:1360";
  #               proto = "tcp";
  #               sourcePort = 1360;
  #             }
  #           ];
  #       };
  #     };
  #     time.timeZone = "Europe/Paris";
  #     environment.systemPackages = with pkgs; [
  #       lynx
  #       nettools
  #       wget
  #       dig
  #       ((vim_configurable.override {  }).customize{
  #         name = "vim";
  #         vimrcConfig.customRC = ''
  #           " your custom vimrc
  #           set mouse=a
  #           set nocompatible
  #           colo torte
  #           syntax on
  #           set tabstop     =2
  #           set softtabstop =2
  #           set shiftwidth  =2
  #           set expandtab
  #           set autoindent
  #           set smartindent
  #           " ...
  #         '';
  #         }
  #       )
  #       # postgresql_14
  #       pwgen
  #     ];
  #     users = {
  #       groups = {
  #         "acme".gid = 993;
  #         "wwwrun".gid = 54;
  #       };
  #       users = {
  #         "acme" = {
  #           uid = 994;
  #           group = "acme";
  #         };
  #         "wwwrun" = {
  #           uid = 54;
  #           group = "wwwrun";
  #         };
  #         # dovecot2.extraGroups = ["wwwrun"];
  #       };
  #     };
  #     # systemd.tmpfiles.rules = [
  #     #   "d /var/lib/acme/${ldapDomainName} 0755 acme wwwrun"
  #     #   "f /var/lib/openldap/pmw/schema/pwm.ldif 0755 openldap openldap"
  #     # ];
  #     security.acme.defaults.email = "chris@mann.fr";
  #     security.acme.acceptTerms = true;
  #     security.acme.certs."mail.lesgrandsvoisins.com".listenHTTP = "1360";
  #     # security.acme.certs."mail.gv.coop".listenHTTP = "1360";
  #     mailserver = {
  #       enable = true;
  #       fqdn = domainName;
  #       domains = mailServerDomainAliases;
  #       certificateScheme = "acme";
  #       certificateFile = "/var/lib/acme/${domainName}/fullchain.pem";
  #       certificateDirectory = "/var/lib/acme/${domainName}/";
  #       keyFile =  "/var/lib/acme/${domainName}/key.pem"; 
  #       messageSizeLimit = 209715200;
  #       # indexDir = "/var/lib/dovecot/indices";
  #       ldap = {
  #         enable = true;
  #         bind = {
  #           dn = "cn=admin,${ldapBaseDN}";
  #           passwordFile = "/etc/nixos/.secrets.bind";
  #         };
  #         uris = [
  #           "ldaps://ldap.lesgrandsvoisins.com:10636/"
  #           # "ldaps://ldap.gv.coop:10636/"
  #         ];
  #         searchBase = "ou=users,${ldapBaseDN}";
  #         searchScope = "sub";
  #         tlsCAFile = "/var/lib/acme/${domainName}/fullchain.pem";
  #         startTls = false;
  #         # postfix = {
  #         #   mailAttribute = "mail";
  #         #   uidAttribute = "cn";
  #         #   #  filter = "(cn=%s)";
  #         # };
  #       };
  #       fullTextSearch = {
  #         enable = true;
  #         # index new email as they arrive
  #         autoIndex = true;
  #         # this only applies to plain text attachments, binary attachments are never indexed
  #         indexAttachments = false;
  #         enforced = "yes";
  #         memoryLimit = 2000;
  #       };
  #     };
  #     systemd.extraConfig = ''
  #       DefaultTimeoutStartSec=600s
  #     '';
  #     services = {
  #       postfix = {
  #         enable = true;
  #       };
  #       # postfix.config.maillog_file = "/var/log/postfix.log";
  #       # postfix.masterConfig.postlog = {
  #       #   command = "postlogd";
  #       #   type = "unix-dgram";
  #       #   privileged = true;
  #       #   private = false;
  #       #   chroot = false;
  #       #   maxproc = 1;
  #       # };
  #       # fail2ban = {
  #       #   enable = true;
  #       #   maxretry = 5; # Observe 5 violations before banning an IP
  #       #   ignoreIP = whitelistSubnets;
  #       #   bantime = "24h"; # Set bantime to one day
  #       #   bantime-increment = {
  #       #     enable = true; # Enable increment of bantime after each violation
  #       #     formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
  #       #     # multipliers = "1 2 4 8 16 32 64";
  #       #     maxtime = "168h"; # Do not ban for more than 1 week
  #       #     overalljails = true; # Calculate the bantime based on all the violations
  #       #   };
  #       #   jails = {
  #       #     apache-nohome-iptables = ''
  #       #       # Block an IP address if it accesses a non-existent
  #       #       # home directory more than 5 times in 10 minutes,
  #       #       # since that indicates that it's scanning.
  #       #       filter = apache-nohome
  #       #       action = iptables-multiport[name=HTTP, port="http,https"]
  #       #       logpath = /var/log/httpd/error_log*
  #       #       backend = auto
  #       #       findtime = 600
  #       #       bantime  = 600
  #       #       maxretry = 5
  #       #     '';
  #       #     postfix = ''
  #       #       port     = smtp,465,submission,imap,imaps,pop3,pop3s
  #       #       action = iptables-multiport[name=HTTP, port="smtp,465,submission,imap,imaps,pop3,pop3s"]
  #       #       logpath  = /var/log/postfix.log
  #       #       backend  = auto
  #       #       enabled  = true
  #       #       filter   = postfix[mode=auth]
  #       #       mode     = more
  #       #     '';
  #       #     # dovecot = ''
  #       #     #   port     = smtp,465,submission
  #       #     #   logpath  = /var/log/fail2ban.log
  #       #     #   backend  = auto
  #       #     #   enabled  = true
  #       #     #   mode     = more
  #       #     # '';
  #       #     # postfix-sasl = ''
  #       #     #   filter   = postfix[mode=auth]
  #       #     #   port     = smtp,465,submission,imap,imaps,pop3,pop3s
  #       #     #   logpath  = /var/log/fail2ban.log
  #       #     #   backend  = auto
  #       #     #   enabled  = true
  #       #     #   mode     = more
  #       #     # '';
  #       #   };
  #       # };
  #       # roundcube = {
  #       #   enable = true;
  #       #   # this is the url of the vhost, not necessarily the same as the fqdn of
  #       #   # the mailserver
  #       #   hostName = "mail.gv.coop";
  #       #   #  dicts =  [ en fr de ];
  #       #   extraConfig = ''
  #       #       # starttls needed for authentication, so the fqdn required to match
  #       #       # the certificate
  #       #       $config['smtp_server'] = "tls://mail.gv.coop";
  #       #       $config['smtp_user'] = "%u";
  #       #       $config['smtp_pass'] = "%p";
  #       #       # $config['oauth_provider'] = 'generic';
  #       #       # $config['oauth_provider_name'] = 'authentik';
  #       #       # $config['oauth_client_id'] = 'q3nTVQdV2ctY8GeNKvPuHokNa5RxT0VhZbVFCyY3';
  #       #       # $config['oauth_client_secret'] = '${oauthPassword}';
  #       #       # $config['oauth_auth_uri'] = 'https://authentik.resdigita.com/application/o/authorize/';
  #       #       # $config['oauth_token_uri'] = 'https://authentik.resdigita.com/application/o/token/';
  #       #       # $config['oauth_identity_uri'] = 'https://authentik.resdigita.com/application/o/userinfo/';
  #       #       # $config['oauth_scope'] = "openid dovecotprofile email";
  #       #       # $config['oauth_auth_parameters'] = [];
  #       #       # $config['oauth_identity_fields'] = ['email'];
  #       #       $config['generic_message_footer_html'] = '<a href="https://www.gv.coop">Les Grands Voisins .com comme communautés</a>';
  #       #       $config['session_samesite'] = "Lax";
  #       #       $config['support_url'] = 'https://www.gv.coop';
  #       #       $config['product_name'] = 'Roundcube Webmail des GV';
  #       #       $config['session_debug'] = true;
  #       #       $config['session_domain'] = 'mail.gv.coop';
  #       #       $config['login_password_maxlen'] = 4096;
  #       #   '';
  #       #   dicts = [ pkgs.aspellDicts.fr pkgs.aspellDicts.en ];
  #       #   maxAttachmentSize = 75;
  #       # };
  #       # memcached = {
  #       #   enable = true;
  #       #   # maxMemory = 256;
  #       #   # enableUnixSocket = true;
  #       #   # port = 11211;
  #       #   # listen = "[::1]";
  #       #   # user = "sogo";
  #       # };
  #       openssh = {
  #         enable = true;
  #       };

  #       # resolved = {
  #       #   enable = true;
  #       #   fallbackDns = [
  #       #       "8.8.8.8"
  #       #       "2001:4860:4860::8844"
  #       #     ];
  #       # };

  #     };
  #   };
  # };
}