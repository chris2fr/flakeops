{ config, pkgs, lib, ... }:
let
in
{
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
    #    wkhtmltopdf
    (pkgs.python3.withPackages (python-pkgs: with python-pkgs; [
            pillow
            gunicorn
            pip
            libsass
            python-ldap
            pyscss
            django-libsass
            pylibjpeg-libjpeg
            pypdf2
            #venvShellHook
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
    python312Full
    python312Packages.pip
    python312Packages.pypdf2
    python312Packages.python-ldap
    python312Packages.pq
    python312Packages.aiosasl
    python312Packages.psycopg2
    python312Packages.pillow
    python312Packages.pylibjpeg-libjpeg
    #    gccgo
    #    gnumake
    #    python312Packages.ldappool
    #    python312Packages.ldap3
    #   python312Packages.bonsai
    #    python312Packages.python-ldap-test
    #    ldapvi
    #    shelldap
    #    python312Packages.devtools
    #    python312Packages.ldaptor
    #    python312Packages.setuptools
    #    python312Packages.libsass
    #    libsass
    #    sass
    #    sassc
    #    python312Packages.cython
    #    python312Packages.pip
    #    python312Packages.pyproject-api
    #    python312Packages.pyproject-hooks
    busybox
    gnumake
    #  nftables
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "qtwebkit-5.212.0-alpha4"
  ];

}
