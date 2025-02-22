{ config, pkgs, lib, ... }:
let

  domainName = import mailserver/vars/domain-name-mx.nix;
  ldapBaseDCDN = import mailserver/vars/ldap-base-dc-dn.nix;
  mailServerDomainAliases = [
    "lesgrandsvoisins.com"
    "mail.lesgrandsvoisins.com"
    "resdigita.com"
    "lesgrandsvoisins.fr"
    "village.ngo"
    "village.ong"
    "parisle.com"
    "parisle.org"
  ];
in
{
  imports = [
    ./mailserver/sogo.nix
    ./mailserver/ldap.nix
    ./mailserver/httpd.nix
    ./mailserver/fail2ban.nix
  ];
  environment.systemPackages = with pkgs; [
    sogo
    # postgresql_14
    openldap
    pwgen
  ];
  age.secrets = {
    "oauthpassword" = {
      file = ./secrets/oauthpassword.age;
      group = "mailserver";
      mode = "770";
    };
    "bind" = {
      file = ./secrets/bind.age;
      group = "mailserver";
      mode = "770";
    };
  };
  users.users.nginx.extraGroups = [ "wwwrun" ];
  services.phpfpm.pools."roundcube" = {
    settings = {
      "listen.owner" = lib.mkForce "wwwrun";
      "listen.group" = lib.mkForce "wwwrun";
    };

  };
  services.dovecot2.sieve.scripts = { };
  services.dovecot2.sieve.extensions = [
    "notify"
    "imapflags"
    "vnd.dovecot.filter"
    "fileinto"
  ];
  services = {
    postfix.virtual = ''
      axel.leroux@resdigita.com axel.leroux@lesgrandsvoisins.com
      alex.leroux@resdigita.com axel.leroux@lesgrandsvoisins.com
      alex.quatorzien@resdigita.com axel.leroux@lesgrandsvoisins.com
      axel.quatorzien@resdigita.com axel.leroux@lesgrandsvoisins.com
      alex.desmoulins@resdigita.com axel.leroux@lesgrandsvoisins.com
      axel.desmoulins@resdigita.com axel.leroux@lesgrandsvoisins.com
      testalias@resdigita.com chris@lesgrandsvoisins.com
      bienvenue@lesgrandsvoisins.com chris@lesgrandsvoisins.com
      chris@lesgrandsvoisins.fr chris@lesgrandsvoisins.com
      chris@fastoche.org chris@lesgrandsvoisins.com
      lesgdvoisins@lesgrandsvoisins.com chris@lesgrandsvoisins.com
      quiquoietc@lesgrandsvoisins.com chris@lesgrandsvoisins.com
      whowhatetc@lesgrandsvoisins.com chris@lesgrandsvoisins.com
      gdvoisins@lesgrandsvoisins.com chris@lesgrandsvoisins.com
      grandvoisinage@lesgrandsvoisins.com chris@lesgrandsvoisins.com
      lesgrandsvoisins@lesgrandsvoisins.com chris@lesgrandsvoisins.com
      lex.larue.fcbk@lesgrandsvoisins.com axel.leroux@lesgrandsvoisins.com
      lex.larue.zytho@lesgrandsvoisins.com axel.leroux@lesgrandsvoisins.com
      alex.larue.kcbk@lesgrandsvoisins.com axel.leroux@lesgrandsvoisins.com
      blex.larue.rock@lesgrandsvoisins.com axel.leroux@lesgrandsvoisins.com
      lex.larue.gml@lesgrandsvoisins.com axel.leroux@lesgrandsvoisins.com
      lex.larue.fcbk@resdigita.com axel.leroux@lesgrandsvoisins.com
      lex.larue.zytho@resdigita.com axel.leroux@lesgrandsvoisins.com
      alex.larue.kcbk@resdigita.com axel.leroux@lesgrandsvoisins.com
      blex.larue.rock@resdigita.com axel.leroux@lesgrandsvoisins.com
      lex.larue.gml@resdigita.com axel.leroux@lesgrandsvoisins.com
    '';

    memcached = {
      enable = true;

    };
  };


  ###################################################################################################################################
  mailserver = {
    enable = true;
    fqdn = domainName;
    domains = mailServerDomainAliases;
    certificateScheme = "acme";
    certificateFile = "/var/lib/acme/${domainName}/fullchain.pem";
    certificateDirectory = "/var/lib/acme/${domainName}/";
    keyFile = "/var/lib/acme/${domainName}/key.pem";
    messageSizeLimit = 209715200;
    indexDir = "/var/lib/dovecot/indices";
    ldap = {
      enable = true;
      bind = {
        dn = "cn=admin,${ldapBaseDCDN}";
        passwordFile = config.age.secrets.bind.path;
      };
      uris = [
        "ldap://ldap.lesgrandsvoisins.com:14389/"
      ];
      searchBase = "ou=users,${ldapBaseDCDN}";
      searchScope = "sub";
      startTls = false;
      postfix = {
        mailAttribute = "mail";
        uidAttribute = "mail";

      };
    };

    fullTextSearch = {
      enable = true;
      # index new email as they arrive
      autoIndex = true;
      # this only applies to plain text attachments, binary attachments are never indexed
      indexAttachments = false;
      enforced = "yes";
      memoryLimit = 2000;
    };

  };
  #############################################
  services.postfix.config.maillog_file = "/var/log/postfix.log";
  # /run/current-system/sw/bin/postlog
  services.postfix.masterConfig.postlog = {
    command = "postlogd";
    type = "unix-dgram";
    privileged = true;
    private = false;
    chroot = false;
    maxproc = 1;
  };
  ###################################################################################################################################
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    ensureDatabases = [
      "sogo"
      "odoo"
      "odootoo"
      "odoothree"
      "odoofor"
    ];
    settings = {
      max_connections = 150;
      shared_buffers = "60MB";
    };
    ensureUsers = [
      {
        name = "sogo";
        ensureDBOwnership = true;
      }
    ];
  };
  ###################################################################################################################################
  # networking.firewall = {
  #   allowedTCPPorts = [ 80 443 20000 389 636 993 11211 14389 14636 ];
  #   enable = true;
  #   trustedInterfaces = [ "lo" ];
  # };

  systemd.extraConfig = ''
    DefaultTimeoutStartSec=600s
  '';

  services.roundcube = {
    enable = true;
    # this is the url of the vhost, not necessarily the same as the fqdn of
    # the mailserver
    hostName = "mail.lesgrandsvoisins.com";
    # dicts =  [ en fr de ];
    extraConfig = ''
      # starttls needed for authentication, so the fqdn required to match
      # the certificate
      $config['smtp_server'] = "tls://mail.lesgrandsvoisins.com";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
      # $config['oauth_provider'] = 'generic';
      # $config['oauth_provider_name'] = 'authentik';
      # $config['oauth_client_id'] = 'q3nTVQdV2ctY8GeNKvPuHokNa5RxT0VhZbVFCyY3';
      # $config['oauth_client_secret'] = 'dollar{oauthPassword}';
      # $config['oauth_auth_uri'] = 'https://authentik.resdigita.com/application/o/authorize/';
      # $config['oauth_token_uri'] = 'https://authentik.resdigita.com/application/o/token/';
      # $config['oauth_identity_uri'] = 'https://authentik.resdigita.com/application/o/userinfo/';
      # $config['oauth_scope'] = "openid dovecotprofile email";
      # $config['oauth_auth_parameters'] = [];
      # $config['oauth_identity_fields'] = ['email'];
      $config['generic_message_footer_html'] = '<a href="https://www.lesgrandsvoisins.com">Les Grands Voisins .com comme communautés</a>';
      $config['session_samesite'] = "Lax";
      $config['support_url'] = 'https://www.lesgrandsvoisins.com';
      $config['product_name'] = 'Roundcube Webmail des GV';
      $config['session_debug'] = true;
      $config['session_domain'] = 'mail.lesgrandsvoisins.com';
      $config['login_password_maxlen'] = 4096;
    '';
    dicts = [ pkgs.aspellDicts.fr pkgs.aspellDicts.en ];
    maxAttachmentSize = 75;
  };
  users.users.dovecot2.extraGroups = [ "wwwrun" ];

}


