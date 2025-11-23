{ config, pkgs, lib, ... }:
let
  # httpsDomainName = "10.ipv6.configmagic.com";
  # lgvLdapBaseDN = import ../vars/lgv-ldap-base-dn.nix;
  # bindSlappasswd = import ../secrets/bind.slappasswd;
in
{
  containers.haproxy = {
    autoStart = true;
    # bindMounts = {
    #   "/var/lib/acme/${httpsDomainName}" = {
    #     hostPath = "/var/lib/acme/${httpsDomainName}";
    #     isReadOnly = false;
    #   };
    # };  
    config = { config, pkgs, lib, ... }: {
      nix.settings.experimental-features = "nix-command flakes";
      system.stateVersion = "25.05";
      time.timeZone = "Europe/Paris";
      environment.systemPackages = with pkgs; [
        lynx
        nettools
        wget
        dig
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
        }
        )
        # postgresql_14
        pwgen
      ];

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
        # "d /var/lib/acme/${lgvLdapDomainName} 0755 acme wwwrun"
        # "f /var/lib/openldap/pmw/schema/pwm.ldif 0755 openldap openldap"
        # "d /var/www/lesgrandsvoisins.com/ldap 0775 wwwrun wwwrun"
      ];

      security.acme.defaults.email = "chris@mann.fr";
      security.acme.acceptTerms = true;
      services = {
        haproxy = {
          enable = true;
          config = ''
            global
              daemon
              maxconn 1000

            defaults
              log     global
              mode    http
              option  httplog
              option  dontlognull
              option  forwardfor
              timeout connect 10s
              timeout client  60s
              timeout server  60s
              errorfile 400 /var/log/haproxy/errors/400.http
              errorfile 403 /var/log/haproxy/errors/403.http
              errorfile 408 /var/log/haproxy/errors/408.http
              errorfile 500 /var/log/haproxy/errors/500.http
              errorfile 502 /var/log/haproxy/errors/502.http
              errorfile 503 /var/log/haproxy/errors/503.http
              errorfile 504 /var/log/haproxy/errors/504.http


          '';
        };
      };
    };
  };
}