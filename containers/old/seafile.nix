{ config, pkgs, lib, ... }:
let
in
{
  # containers.seafile = {
  #   autoStart = true;container@freeipa.service
  #   privateNetwork = true;
  #   hostAddress = "192.168.101.10";domainName
  #   localAddress = "192.168.101.11";
  #   hostAddress6 = "fd00::1";
  #   localAddress6 = "fd00::2";
  #   config = { config, pkgs, lib, ...  }: {
  #     environment.systemPackages = with pkgs; [
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
  #           set expandtabafthttps://app.mailjet.com/campaigns/creation/278443/confirmer
  #           set autoindent
  #           set smartindent
  #           " ...
  #         '';
  #         }
  #       )
  #       (python311.withPackages my-python-packages)
  #       # python311Packages.bleach 
  #       # python311Packages.captcha domainName
  #       # python311Packages.cffi 
  #       # python311Packages.chardet 
  #       # python311Packages.devtools
  #       # python311Packages.django
  #       # python311Packages.django_4
  #       # python311Packages.django-formtools
  #       # python311Packages.django-picklefield
  #       # python311Packages.django-simple-captcha
  #       # python311Packages.django-statici18n
  #       # python311Packages.django-webpack-loader
  #       # python311Packages.djangorestframework
  #       # python311Packages.future
  #       # python311Packages.gunicorn
  #       # python311Packages.ldap3
  #       # python311Packages.markdown 
  #       # python311Packages.mysqlclient
  #       # python311Packages.mysqlclient
  #       # python311Packages.openpyxl 
  #       # python311Packages.pillow 
  #       # python311Packages.pip
  #       # python311Packages.pycryptodome
  #       # python311Packages.pyjwt
  #       # python311Packages.pysaml2
  #       # python311Packages.python-dateutil
  #       # python311Packages.python-ldap
  #       # python311Packages.qrcode 
  #       # python311Packages.requests
  #       # python311Packages.requests-oauthlib
  #       #python311
  #       #python311Full
  #       autoconf
  #       automake 
  #       busybox
  #       ceph-client
  #       cmake
  #       curl
  #       cyrus_sasl
  #       docker
  #       docker-compose
  #       flex 
  #       fuse
  #       gcc
  #       git
  #       glib
  #       intltool
  #       jansson
  #       libarchive
  #       libevent
  #       libgcc
  #       libglibutilcontainer@freeipa.service
  #       libmysqlclient
  #       libtool
  #       libuuid
  #       lynx
  #       mariadb
  #       mariadb-embedded
  #       openldap
  #       openssh
  #       openssl
  #       openssl
  #       re2c
  #       seafile-server
  #       sqlitecontainer@freeipa.service
  #       stdenv
  #       util-linux
  #       vala
  #       vim
  #       wget
  #       libxml2
  #       netcat
  #       unzip
  #       libffi
  #       pcre
  #       libz
  #       xz
  #       nginx
  #       pkg-config
  #       poppler_utils
  #       libmemcached
  #       sudo
  #       libjwt
  #     ];
  #     virtualisation.docker.enable = true;
  #     system.stateVersion = "24.05";
  #     nix.settings.experimental-features = "nix-command flakes";
  #     networking = {
  #       firewall.enable = false;
  #       # firewall = {
  #       #   enable = true;
  #       #   allowedTCPPorts = [ 80 443 ];
  #       # };
  #       # Use systemd-resolved inside the container
  #       useHostResolvConf = lib.mk  # containers.freeipa = {
  #   autoStart = true;

  #   privateNetwork = true;
  #   hostAddress = "192.168.107.10";
  #   localAddress = "192.168.107.11";
  #   hostAddress6 = "fa01::1";
  #   localAddress6 = "fa01::2";
  #   config = { config, pkgs, lib, ...  }: {
  #     environment.systemPackages = with pkgs; [
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
  #       freeipa
  #     ];
  #     system.stateVersion = "24.05";
  #     nix.settings.experimental-features = "nix-command flakes";
  #     networking = {
  #       firewall.allowedTCPPorts = [ 3000 4971 4972 22 25 80 443 143 587 993 995 636 8443 9443 ];
  #       # useHostResolvConf = true;
  #       useHostResolvConf = lib.mkForce false;
  #     };
  #     time.timeZone = "Europe/Amsterdam";
  #   };
  # };Force false;
  #     };
  #     users.users.seafile = {
  #       isNormalUser = true;
  #       extraGroups = ["docker"];
  #     };
  #     services = {
  #       resolved.enable = true;
  #       seafile = {
  #         enable = true;
  #         adminEmail = "chris@mann.fr";
  #         initialAdminPassword = "aes3xaiThe7Ungi0iDe0aehongideik";
  #         ccnetSettings.General.SERVICE_URL = "https://seafile.resdigita.com";
  #       };
  #       mysql = {
  #         enable = true;
  #         package = pkgs.mariadb;
  #       };
  #     };
  #   };
  # };    

}