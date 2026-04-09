{
  config,
  pkgs,
  lib,
  ...
}: let
  domainName = import mailserver/vars/domain-name-mx.nix;
  ldapBaseDCDN = import mailserver/vars/ldap-base-dc-dn.nix;
  roundcube-ui-gv = pkgs.callPackage ./services/roundcube/roundcube-ui-gv.nix {};
  mailServerDomainAliases = [
    "maelanc.com"
    "gvcoop.org"
    "lesgrandsvoisins.com"
    "mail.lesgrandsvoisins.com"
    "resdigita.com"
    "mail.resdigita.com"
    "lesgrandsvoisins.fr"
    "village.ngo"
    "village.ong"
    "parisle.com"
    "parisle.org"
    "paris14.cc"
    "discourse.paris14.cc"
    "yanlomsprod.org"
    "lgv.info"
    "discourse.lgv.info"
    "mm.lgv.info"
    "gdvoisins.com"
    "gv.style"
    "gvstyle.org"
    "gvplace.com"
    "hopgv.com"
    "hopgv.org"
    "gafam.us"
    "gdvoisins.org"
    "gv.je"
    "mail.gv.je"
    "libregood.com"
  ];
  # roundcube-ui-gv = pkgs.callPackage ./services/roundcube/roundcube-ui-gv.nix;
in {
  imports = [
    ./mailserver/sogo.nix
    ./mailserver/ldap.nix
    ./mailserver/httpd.nix
    ./mailserver/fail2ban.nix
  ];
  systemd.tmpfiles.rules = [
    "d /var/lib/roundcube/plugins 0755 roundcube roundcube"
    "L+ ${roundcube-ui-gv}/plugins/roundcube-ui-gv -    -    -     - /var/lib/roundcube/plugins/roundcube-ui-gv"
  ];
  environment.systemPackages = [
    pkgs.sogo
    # pkgs.postgresql_14
    pkgs.openldap
    pkgs.pwgen
    pkgs.roundcube
    roundcube-ui-gv
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
  users.users.nginx.extraGroups = ["wwwrun"];
  services.phpfpm.pools."roundcube" = {
    settings = {
      "listen.owner" = lib.mkForce "wwwrun";
      "listen.group" = lib.mkForce "wwwrun";
    };
  };
  services = {
    # dovecot2 = {
    #   # extraConfig = ''
    #   #   auth_mechanisms = plain login oauth2
    #   #   passdb {
    #   #     driver = oauth2
    #   #     mechanisms = xoauth2 oauthbearer
    #   #     args = /etc/dovecot/dovecot-oauth2.conf.ext
    #   #   }

    #   #   # userdb {
    #   #   #   driver = static
    #   #   #   args = uid=vmail gid=vmail home=/var/vmail/%u
    #   #   # }

    #   #   # authentication debug logging
    #   #   auth_debug = yes
    #   #   auth_verbose = yes

    #   #   # # provide SASL via unix socket to postfix
    #   #   # service auth {
    #   #   #   unix_listener /var/spool/postfix/private/auth {
    #   #   #     mode = 0660
    #   #   #     # Assuming the default Postfix user and group
    #   #   #     user = postfix
    #   #   #     group = postfix
    #   #   #   }
    #   #   # }
    #   # '';
    #   sieve.scripts = {};
    #   sieve.extensions = [
    #     "notify"
    #     "imapflags"
    #     "vnd.dovecot.filter"
    #     "fileinto"
    #   ];
    # };

    # postfix.virtual = ''
    #   max@gdvoisins.com max@lesgrandsvoisins.com
    #   chris@gdvoisins.com chris@lesgrandsvoisins.com
    #   discourseadmin@lesgrandsvoisins.com chris@lesgrandsvoisins.com
    #   sviatlana@lesgrandsvoisins.com sviatlana.viarbitskaya@gmail.com
    #   sviatlana@lesgrandsvoisins.com sviatlana@lesgrandsvoisins.com
    #   arezki@lesgrandsvoisins.com arezkisef@yahoo.fr
    #   arezki@lesgrandsvoisins.com arezki@lesgrandsvoisins.com
    #   caroline@lesgrandsvoisins.com clhomme@gmail.com
    #   pauline@lesgrandsvoisins.com poteomiranda@gmail.com
    #   pauline@lesgrandsvoisins.com pauline@lesgrandsvoisins.com
    #   rayhane@lesgrandsvoisins.com rayhane.baghdadddi@gmail.com
    #   rayhane@lesgrandsvoisins.com rayhane@lesgrandsvoisins.com
    #   abel@lesgrandsvoisins.com abel@lesgrandsvoisins.com
    #   abel@lesgrandsvoisins.com abelmavura@gmail.com
    #   donation@lesgrandsvoisins.com chris@lesgrandsvoisins.com
    #   felicite@yanlomsprod.org associationyanlomsprod@gmail.com
    #   contact@yanlomsprod.org associationyanlomsprod@gmail.com
    #   felicite@yanlomsprod.org yanlomsprod@lesgrandsvoisins.com
    #   contact@yanlomsprod.org yanlomsprod@lesgrandsvoisins.com
    #   yanlomsprod@lesgrandsvoisins.com associationyanlomsprod@gmail.com
    #   yanlomsprod@lesgrandsvoisins.com yanlomsprod@lesgrandsvoisins.com
    #   contact@resdigita.com sviatlana@resdigita.com
    #   contact@resdigita.com chris@resdigita.com
    #   mael@maelanc.com maelnemacherif@yahoo.fr
    #   mael@lesgrandsvoisins.com maelnemacherif@yahoo.fr
    #   mael@lesgrandsvoisins.com mael@lesgrandsvoisins.com
    #   chris@resdigita.com chris@mann.fr
    #   sviatlana@resdigita.com sviatlana.viarbitskaya@gmail.com
    #   axel.leroux@resdigita.com axel.leroux@lesgrandsvoisins.com
    #   alex.leroux@resdigita.com axel.leroux@lesgrandsvoisins.com
    #   alex.quatorzien@resdigita.com axel.leroux@lesgrandsvoisins.com
    #   axel.quatorzien@resdigita.com axel.leroux@lesgrandsvoisins.com
    #   alex.desmoulins@resdigita.com axel.leroux@lesgrandsvoisins.com
    #   axel.desmoulins@resdigita.com axel.leroux@lesgrandsvoisins.com
    #   testalias@resdigita.com chris@lesgrandsvoisins.com
    #   bienvenue@lesgrandsvoisins.com chris@lesgrandsvoisins.com
    #   chris@lesgrandsvoisins.fr chris@lesgrandsvoisins.com
    #   chris@fastoche.org chris@lesgrandsvoisins.com
    #   lesgdvoisins@lesgrandsvoisins.com chris@lesgrandsvoisins.com
    #   quiquoietc@lesgrandsvoisins.com chris@lesgrandsvoisins.com
    #   whowhatetc@lesgrandsvoisins.com chris@lesgrandsvoisins.com
    #   gdvoisins@lesgrandsvoisins.com chris@lesgrandsvoisins.com
    #   grandvoisinage@lesgrandsvoisins.com chris@lesgrandsvoisins.com
    #   lesgrandsvoisins@lesgrandsvoisins.com chris@lesgrandsvoisins.com
    #   lex.larue.fcbk@lesgrandsvoisins.com axel.leroux@lesgrandsvoisins.com
    #   lex.larue.zytho@lesgrandsvoisins.com axel.leroux@lesgrandsvoisins.com
    #   alex.larue.kcbk@lesgrandsvoisins.com axel.leroux@lesgrandsvoisins.com
    #   blex.larue.rock@lesgrandsvoisins.com axel.leroux@lesgrandsvoisins.com
    #   lex.larue.gml@lesgrandsvoisins.com axel.leroux@lesgrandsvoisins.com
    #   lex.larue.fcbk@resdigita.com axel.leroux@lesgrandsvoisins.com
    #   lex.larue.zytho@resdigita.com axel.leroux@lesgrandsvoisins.com
    #   alex.larue.kcbk@resdigita.com axel.leroux@lesgrandsvoisins.com
    #   blex.larue.rock@resdigita.com axel.leroux@lesgrandsvoisins.com
    #   lex.larue.gml@resdigita.com axel.leroux@lesgrandsvoisins.com
    #   @discourse.paris14.cc admin@discourse.paris14.cc
    #   @discourse.lgv.info discourse@lgv.info
    # '';

    memcached = {
      enable = true;
    };
  };

  ###################################################################################################################################
  mailserver = {
    enable = true;
    enablePop3Ssl = true;
    enableImap = true;
    enableImapSsl = true;

    stateVersion = 3;
    acmeCertificateName = config.mailserver.fqdn;
    debug = {
      all = false;
      dovecot = true;
      rspamd = false;
    };
    fqdn = domainName;
    domains = mailServerDomainAliases;
    certificateScheme = "acme";
    # certificateFile = "/var/lib/acme/${domainName}/fullchain.pem";
    # certificateDirectory = "/var/lib/acme/${domainName}/";
    # keyFile = "/var/lib/acme/${domainName}/key.pem";
    messageSizeLimit = 987654321;
    # messageSizeLimit = 209715200;
    indexDir = "/var/lib/dovecot/indices";
    ldap = {
      enable = true;
      bind = {
        dn = "cn=admin,${ldapBaseDCDN}";
        passwordFile = config.age.secrets.bind.path;
      };
      uris = [
        "ldaps://ldap.lesgrandsvoisins.com:14636/"
        # "ldap://ldap.lesgrandsvoisins.com:14389/"
      ];
      searchBase = "ou=users,${ldapBaseDCDN}";
      searchScope = "sub";
      # startTls = false;
      # startTls = true;
      # tlsCAFile = "/var/lib/acme/${domainName}/fullchain.pem";
      postfix = {
        filter = "(mail=%s)";
        # filter = "(|(mail=%s)(cn=%s))";
        # filter = "(|(mail=%s)(cn=%s)(cn=%s@gv.je))";
        mailAttribute = "mail";
        uidAttribute = "mail";
        # filter = "(|(mail=%s)(uid=%s))";
      };
      dovecot = {
        # userFilter = "(|(uid=%{user}@gdvoisins.org)(uid=%{user})(mail=%{user})(mail=%{user}@gdvoisins.org)))";
        # passFilter = "(|(uid=%{user}@gdvoisins.org)(uid=%{user})(mail=%{user})(mail=%{user}@gdvoisins.org)))";
        userFilter = "mail=%{user}";
        # userFilter = "(|(cn=%{user})(mail=%{user}))";
        # userAttrs = "mail cn displayName givenName";
        # userAttrs = "=mail_location=/var/vmail/ldap/%{ldap:cn}/mail/";
        passFilter = "mail=%{user}";
        # passFilter = "(|(cn=%{user})(mail=%{user}))";
        passAttrs = "userPassword=password";
      };
    };

    fullTextSearch = {
      enable = true;
      # index new email as they arrive
      autoIndex = true;
      # this only applies to plain text attachments, binary attachments are never indexed
      # indexAttachments = false;
      enforced = "yes";
      memoryLimit = 2000;
    };

    # extraVirtualAliases = {
    #   "pauline@gdvoisins.com" = ["pauline@lesgrandsvoisins.com" "pauline@gdvoisins.com"];
    #   "chris@gdvoisins.com" = ["chris@lesgrandsvoisins.com" "chris@gdvoisins.com"];
    #   "max@gdvoisins.com" = ["max@lesgrandsvoisins.com" "max@gdvoisins.com"];
    #   "sviatlana@gdvoisins.com" = ["sviatlana@lesgrandsvoisins.com" "sviatlana@gdvoisins.com"];
    #   "mael@gdvoisins.com" = ["mael@lesgrandsvoisins.com" "mael@gdvoisins.com"];
    #   "arezki@gdvoisins.com" = ["arezki@lesgrandsvoisins.com" "arezki@gdvoisins.com"];
    #   "clhomme@gdvoisins.com" = ["clhomme@lesgrandsvoisins.com" "clhomme@gdvoisins.com"];
    #   "ruben@gdvoisins.com" = ["ruben@lesgrandsvoisins.com" "ruben@gdvoisins.com"];
    # };

    forwards = {
      "benaluca@gv.je" = ["kalos.design.jardinage@gmail.com" "benaluca@gv.je"];
      "ateliercomediemusicaleparis@gv.je" = ["ateliercomediemusicaleparis@gmail.com" "ateliercomediemusicaleparis@gv.je"];
      "renel@gv.je" = ["culture.coordination@gmail.com" "renel@gv.je"];
      "m.andrei@lgv.info" = ["m.andrei@outlook.com" "m.andrei@lgv.info"];
      "m.andrei@gdvoisins.com" = ["m.andrei@lgv.info"];
      "m.andrei@lesgrandsvoisins.com" = ["m.andrei@lgv.info"];
      "contact@gdvoisins.com" = ["contact@lesgrandsvoisins.com" "contact@gdvoisins.com"];
      "robert@lgv.info" = ["baldridgeprogram@lgv.info"];
      "baldridgeprogram@lgv.info" = ["baldridgeprogram@gmail.com" "baldridgeprogram@lgv.info"];
      "chris@lgv.info" = ["chris@lesgrandsvoisins.com" "chris@lgv.info"];
      "bienvenue@gdvoisins.com" = ["bienvenue@lesgrandsvoisins.com" "bienvenue@gdvoisins.com"];
      "contact@lesgrandsvoisins.com" = ["chris@lesgrandsvoisins.com" "contact@lesgrandsvoisins.com"];
      "admin@lesgrandsvoisins.com" = ["chris@lesgrandsvoisins.com" "admin@lesgrandsvoisins.com"];
      "pauline@gdvoisins.com" = ["pauline@lesgrandsvoisins.com" "pauline@gdvoisins.com"];
      "chris@gdvoisins.com" = ["chris@lesgrandsvoisins.com" "chris@gdvoisins.com"];
      "max@gdvoisins.com" = ["max@lesgrandsvoisins.com" "max@gdvoisins.com"];
      "sviatlana@gdvoisins.com" = ["sviatlana@lesgrandsvoisins.com" "sviatlana@gdvoisins.com"];
      "mael@gdvoisins.com" = ["mael@lesgrandsvoisins.com" "mael@gdvoisins.com"];
      # "arezki@gdvoisins.com" = ["arezki@lesgrandsvoisins.com" "arezki@gdvoisins.com"];
      "clhomme@gdvoisins.com" = ["clhomme@lesgrandsvoisins.com" "clhomme@gdvoisins.com"];
      "ruben@gdvoisins.com" = ["ruben@lesgrandsvoisins.com" "ruben@gdvoisins.com"];
      "discourseadmin@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
      "sviatlana@lesgrandsvoisins.com" = ["sviatlana@lesgrandsvoisins.com" "sviatlana.viarbitskaya@gmail.com"];
      "arezki@lesgrandsvoisins.com" = ["arezki@lesgrandsvoisins.com" "arezkisef@yahoo.fr"];
      "caroline@lesgrandsvoisins.com" = "clhomme@gmail.com";
      "pauline@lesgrandsvoisins.com" = ["pauline@lesgrandsvoisins.com" "poteomiranda@gmail.com"];
      "julio@lesgrandsvoisins.com" = ["julio@lesgrandsvoisins.com" "donjulioromero.rodriguez@gmail.com"];
      "rayhane@lesgrandsvoisins.com" = ["rayhane@lesgrandsvoisins.com" "rayhane.baghdadddi@gmail.com"];
      "abel@lesgrandsvoisins.com" = ["abel@lesgrandsvoisins.com" "abelmavura@gmail.com"];
      "donation@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
      "felicite@yanlomsprod.org" = ["associationyanlomsprod@gmail.com" "felicite@yanlomsprod.org"];
      "contact@yanlomsprod.org" = ["associationyanlomsprod@gmail.com" "contact@yanlomsprod.org"];
      "yanlomsprod@lesgrandsvoisins.com" = ["yanlomsprod@lesgrandsvoisins.com" "associationyanlomsprod@gmail.com"];
      "contact@resdigita.com" = ["sviatlana@resdigita.com" "chris@resdigita.com"];
      "mael@maelanc.com" = "maelnemacherif@yahoo.fr";
      "mael@lesgrandsvoisins.com" = ["maelnemacherif@yahoo.fr" "mael@lesgrandsvoisins.com"];
      "chris@resdigita.com" = ["chris@resdigita.com" "chris@mann.fr"];
      "mannchri@lesgrandsvoisins.com" = "chris@lesgdvoisins.com";
      "sviatlana@resdigita.com" = ["sviatlana@resdigita.com" "sviatlana.viarbitskaya@gmail.com"];
      "axel.leroux@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
      "alex.leroux@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
      "alex.quatorzien@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
      "axel.quatorzien@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
      "alex.desmoulins@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
      "axel.desmoulins@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
      "testalias@resdigita.com" = "chris@lesgrandsvoisins.com";
      "bienvenue@lesgrandsvoisins.com" = ["contact@lesgrandsvoisins.com" "chris@lesgrandsvoisins.com"];
      "chris@lesgrandsvoisins.fr" = "chris@lesgrandsvoisins.com";
      "chris@fastoche.org" = "chris@lesgrandsvoisins.com";
      "lesgdvoisins@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
      "quiquoietc@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
      "whowhatetc@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
      "gdvoisins@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
      "grandvoisinage@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
      "lesgrandsvoisins@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
      "lex.larue.fcbk@lesgrandsvoisins.com" = "axel.leroux@lesgrandsvoisins.com";
      "lex.larue.zytho@lesgrandsvoisins.com" = "axel.leroux@lesgrandsvoisins.com";
      "alex.larue.kcbk@lesgrandsvoisins.com" = "axel.leroux@lesgrandsvoisins.com";
      "blex.larue.rock@lesgrandsvoisins.com" = "axel.leroux@lesgrandsvoisins.com";
      "lex.larue.gml@lesgrandsvoisins.com" = "axel.leroux@lesgrandsvoisins.com";
      "lex.larue.fcbk@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
      "lex.larue.zytho@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
      "alex.larue.kcbk@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
      "blex.larue.rock@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
      "lex.larue.gml@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
      "@discourse.paris14.cc" = "admin@discourse.paris14.cc";
      "@discourse.lgv.info" = "discourse@lgv.info";
    };
  };
  #############################################
  # services.postfix.settings.main.maillog_file = "/var/log/postfix.log";
  # /run/current-system/sw/bin/postlog
  # services.postfix.settings.master.postlog = {
  #   command = "postlogd";
  #   type = "unix-dgram";
  #   privileged = true;
  #   private = false;
  #   chroot = false;
  #   maxproc = 1;
  # };
  ###################################################################################################################################
  # Chris chris2f mannchri 2025-08-24
  # services.postgresql = {
  #   enable = true;
  #   enableTCPIP = true;
  #   ensureDatabases = [
  #     "sogo"
  #     "odoo"
  #     "odootoo"
  #     "odoothree"
  #     "odoofor"
  #   ];
  #   settings = {
  #     max_connections = 150;
  #     shared_buffers = "60MB";
  #   };
  #   ensureUsers = [
  #     {
  #       name = "sogo";
  #       ensureDBOwnership = true;
  #     }
  #   ];
  # };
  ###################################################################################################################################
  # networking.firewall = {
  #   allowedTCPPorts = [ 80 443 20000 389 636 993 11211 14389 14636 ];
  #   enable = true;
  #   trustedInterfaces = [ "lo" ];
  # };

  # systemd.extraConfig = ''
  #   DefaultTimeoutStartSec=600s
  # '';
  systemd.settings.Manager.DefaultTimeoutStartSec = "300s";

  services.roundcube = {
    enable = true;
    # this is the url of the vhost, not necessarily the same as the fqdn of
    # the mailserver
    hostName = "mail.lesgrandsvoisins.com";
    # dicts =  [ en fr de ];
    extraConfig = ''
      # starttls needed for authentication, so the fqdn required to match
      # the certificate
      $config['smtp_server'] = "ssl://mail.lesgrandsvoisins.com";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
      $config['plugins'] = array('floating_button');
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
    dicts = [pkgs.aspellDicts.fr pkgs.aspellDicts.en];
    maxAttachmentSize = 75;
  };
  users.users.dovecot2.extraGroups = ["wwwrun"];
  # users.users.dovecot.extraGroups = ["wwwrun"];
}
