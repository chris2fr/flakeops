{ config, pkgs, lib, ... }:
let
in
{
  systemd.tmpfiles.rules = [
    "d /var/local/cherryldap 0755 cherryldap users"
  ];
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
    bindMounts = {
      "/var/local/cherryldap" = {
        hostPath = "/var/local/cherryldap";
        isReadOnly = false;
      };
    };
    config = { config, pkgs, ... }: {
      nix.settings.experimental-features = "nix-command flakes";
      time.timeZone = "Europe/Paris";
      system.stateVersion = "24.11";
      environment.systemPackages = with pkgs; [
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
        # python311Packages.cherrypy-cors
        # python311Packages.pillow
        # python311Packages.gunicorn
        # python311Packages.pip
        # libjpeg
        # zlib
        # libtiff
        # freetype
        # python311Packages.venvShellHook
        curl
        wget
        lynx
        libclang
        # dig    
        # python311Packages.pylibjpeg-libjpeg
        git
        # tmux
        # bat
        # cowsay
        # lzlib
        # killall
        # pwgen
        # python311Packages.pypdf2
        # python311Packages.pq
        # python311Packages.aiosasl
        # python311Packages.psycopg2
        # gettext
        # sqlite
        # postgresql_14
        # pipx
        gnumake
        gcc
        glibcLocales
        # python311Packages.manimpango
        # python311Packages.devtools

        # python311Packages.django-auth-ldap
        # python311Packages.pq
        # python311Packages.aiosasl
        # python311Packages.pylibjpeg-libjpeg
        # python311Packages.virtualenv
        # python311Packages.toolz
        # libpqxx
        # postgresql
        openldap
        # python311Packages.pgcli
        # cairo
        # cairomm
        # python311Packages.pycairo
        # python311Packages.cairosvg
        # python311Packages.cairocffi

        gnutls
        gnulib
        gnumake
        openssl
        cyrus_sasl
        # ldapcherry
        (pkgs.python3.withPackages (python-pkgs: [
          # python-pkgs.devtools
          # python-pkgs.pydevtool
          python-pkgs.cherrypy
          python-pkgs.mako
          python-pkgs.pyyaml
          python-pkgs.python-ldap
          python-pkgs.yq
          python-pkgs.pip
          # python-pkgs.python-ldap-test
          # python-pkgs.ldappool
          # python-pkgs.wheel
          # python-pkgs.wheelUnpackHook
          # python-pkgs.installer
          # python-pkgs.bootstrap.installer
          # python-pkgs.pandas
          # python-pkgs.requests
        ]))

        ninja
        cmake
        # PHP
        php
      ];
      networking = {
        hostName = "cherryldap";
        firewall.allowedTCPPorts = [ 22 25 53 80 443 143 587 993 995 636 ];
        useHostResolvConf = lib.mkForce false;
      };
      services.resolved.enable = true;
      users.users.cherryldap = {
        isNormalUser = true;
        uid = 11111;
      };
      systemd.tmpfiles.rules = [
        "d /var/local/cherryldap 0755 cherryldap users"
        "d /var/local/cherryldap/settings_local.py 0644 cherryldap users"
      ];

      # systemd.services.cherryldap = {
      #   description = "ResDigita FFDN Coin";
      #   after = [ "network.target" ];
      #   wantedBy = [ "multi-user.target" ];
      #   serviceConfig = {
      #     WorkingDirectory = "/var/local/cherryldap/";
      #     ExecStart = ''/var/local/cherryldap/venv/bin/gunicorn --env LDAP_ACTIVATE='true' --env='DEFAULT_FROM_EMAIL' --access-logfile /var/log/cherryldap-access.log --error-logfile /var/log/cherryldap-error.log --chdir /var/local/cherryldap --workers 12 --bind 127.0.0.1:8000 lesgv.wsgi:application'';
      #     Restart = "always";
      #     RestartSec = "10s";
      #     User = "wagtail";
      #     Group = "users";
      #   };
      #   unitConfig = {
      #     StartLimitInterval = "1min";
      #   };
      # };
    };
  };
}
