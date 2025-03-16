{ config, pkgs, lib, ... }:
let
in {
  systemd.tmpfiles.rules = [ "d /var/local/cherryldap 0755 cherryldap users" ];
  users.users.cherryldap = {
    isNormalUser = true;
    uid = 11111;
  };
  containers.cherryldap = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.106.1";
    localAddress = "192.168.106.2";
    hostAddress6 = "fc00::6:1";
    localAddress6 = "fc00::6:2";
    # bindMounts = {
    #   "///" = {
    #     hostPath = "///";
    #     isReadOnly = false;
    #   };
    # };
    config = { config, pkgs, ... }: {
      nix.settings.experimental-features = "nix-command flakes";
      time.timeZone = "Europe/Paris";
      system.stateVersion = "24.11";
      environment.systemPackages = with pkgs;
        [
          ((vim_configurable.override { }).customize {
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
          })
        ];
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
    };
  };
}
