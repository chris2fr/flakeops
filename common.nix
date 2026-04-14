{
  config,
  pkgs,
  lib,
  ...
}: let
in {
  environment.systemPackages = with pkgs; [
    (
      (vim-full.override {}).customize {
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
    #vim
    #django-redis
    cowsay
    home-manager
    curl
    wget
    lynx
    git
    tmux
    bat
    zlib
    lzlib
    dig
    killall
    # inetutils
    pwgen
    openldap
    mysql80
    sqlite-interactive
    btrfs-progs
    #    wkhtmltopdf
    (pkgs.python313.withPackages (python-pkgs:
      with python-pkgs; [
        pillow
        gunicorn
        pip
        libsass
        python-ldap
        pyscss
        django-libsass
        pylibjpeg-libjpeg
        pypdf
        # venvShellHook
        pq
        aiosasl
        psycopg2
        django
        wagtail
        python-dotenv
        dj-database-url
        # psycopg2-binary
        django-taggit
        #wagtail-modeladmin
        ## wagtailmenus
        ## Public facing server, I think
        python-keycloak
        ## Dev
        ## djlint
        django-debug-toolbar
      ]))
    # python311
    # python311Packages.pip
    # python311Packages.pypdf2
    # python311Packages.python-ldap
    # python311Packages.pq
    # python311Packages.aiosasl
    # python311Packages.psycopg2
    # python311Packages.pillow
    # python311Packages.pylibjpeg-libjpeg
    #    gccgo
    #    gnumake
    #    python311Packages.ldappool
    #    python311Packages.ldap3
    #   python311Packages.bonsai
    #    python311Packages.python-ldap-test
    #    ldapvi
    #    shelldap
    #    python311Packages.devtools
    #    python311Packages.ldaptor
    #    python311Packages.setuptools
    #    python311Packages.libsass
    #    libsass
    #    sass
    #    sassc
    #    python311Packages.cython
    #    python311Packages.pip
    #    python311Packages.pyproject-api
    #    python311Packages.pyproject-hooks
    busybox
    gnumake
    oauth2-proxy
    #  nftables
    htop
    inetutils
    dnsutils
    host
    dnslookup
    dig
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "qtwebkit-5.212.0-alpha4"
    "sope-5.11.2"
    "python3.15-pypdf2-3.0.1"
    "python3.13-pypdf2-3.0.1"
    "python3.11-pypdf2-3.0.1"
  ];
}
