{
  config,
  pkgs,
  lib,
  # vars,
  ...
}: let
  # oidcSeafileSecret = import ./secrets/oidc-seafile-secret.nix;
  oidcRosesSecret = import ./secrets/oidc-roses-secret.nix;
  jwtVouchSecret = import ./secrets/jwt-vouch-secret.nix;
in {
  nix.settings.experimental-features = "nix-command flakes";
  system.stateVersion = "25.11";
  imports = [
    ./hardware-configuration.nix
    ./modules/bind.nix
    ./modules/caddy.nix
    ./modules/common.nix # Des configurations communes pratiques
    ./modules/containers.nix
    ./modules/gitea.nix
    ./modules/networking.nix
    ./modules/nfs.nix
    ./modules/nginx.nix
    ./modules/oauth2-proxy.nix
    ./modules/postgresql.nix
    ./modules/users.nix
    # ./modules/acme.nix
    # ./modules/haproxy.nix
    # ./modules/httpd.nix
    # ./modules/seafile.nix
    # ./modules/vouch.nix
  ];
  environment.systemPackages = with pkgs; [
    # agenix-cli
    # gcc
    # apacheHttpd
    # pkg-config
    # apr
    # aprutil
    # curlFull
    # lzlib
    # libgnurl
    # jansson
    # vouch-proxy
    nodenv
    vips
    # vouch-proxy
    # oauth2-proxy
    docker
    docker-compose
    docker-ls
    # authentik
    # authentik-outposts.proxy
    apacheHttpd
    apacheHttpdPackages.mod_auth_mellon
    openssl
    lasso
    pkg-config
    cfssl
    mutagen
    ffmpeg
    python3
    uv
    # luajit
    # luajit_openresty
    # luajitPackages.lua-resty-openidc
    acme-sh
    # caddy.withPlugins {
    #   plugins = ["github.com/greenpau/caddy-security@v1.1.31"];
    #   # plugins = ["github.com/greenpau/caddy-security@v1.1.31" "github.com/mholt/caddy-l4@v0.0.0-20251124224044-66170bec9f4d"];
    #   hash = "sha256-aM5UdzmqOwGcdQUzDAEEP30CC1W2UPD10QhF0i7GwQE=";
    # }
    go
    xcaddy
  ];
  # users.users.wwwrun.extraGroups = [ "acme" "wwwrun" "copyparty"];
  # users.users.nginx.extraGroups = [ "acme" "wwwrun" "copyparty" ];

  virtualisation.docker.enable = true;
  systemd.services.copyparty = {
    enable = true;
    wantedBy = ["default.target"];
    script = "/var/lib/copyparty/.venv/bin/python -m copyparty -c /etc/copyparty.conf ";
    # script = "/home/mannchri/copyparty/.venv/bin/python -m copyparty --xff-hdr x-forwarded-for --rproxy 1 --xff-src=lan -c /home/mannchri/copyparty/copyparty.conf ";
    description = "CopyParty";
    serviceConfig = {
      WorkingDirectory = "/mnt/chrisdatalive/chris";
      User = "copyparty";
      # Group = "wwwrun";
    };
  };
  systemd.services.copyparty-public = {
    enable = true;
    wantedBy = ["default.target"];
    # script = "/home/mannchri/copyparty/.venv/bin/python -m copyparty -c /home/mannchri/copyparty/copyparty.conf ";
    script = "/var/lib/copyparty/.venv/bin/python -m copyparty -c /etc/copyparty-public.conf ";
    # script = "/home/mannchri/copyparty/.venv/bin/python -m copyparty --xff-hdr x-forwarded-for --rproxy 1 --xff-src=lan -c /home/mannchri/copyparty/copyparty.conf ";
    description = "CopyParty Public";
    serviceConfig = {
      WorkingDirectory = "/mnt/chrisdatalive/chris";
      User = "copyparty";
      # Group = "wwwrun";
    };
  };
  # systemd.services.certwarden = {
  #   enable = true;
  #   wantedBy = ["default.target"];

  #   script = "/home/mannchri/certwarden/scripts/";

  #   description = "Certwarden";
  #   serviceConfig = {
  #     WorkingDirectory = "/home/mannchri/certwarden";
  #     User = "mannchri";
  #     Group = "users";
  #   };
  # };
  # nix-shell -p gcc    apacheHttpd    pkg-config    apr    aprutil    curlFull    lzlib libgnurl
  # export APR_CFLAGS="`apr-1-config --cflags`"
  # export APR_LIBS="`apr-1-config --libs`"
  # export LIBCURL_CFLAGS="`gnurl-config --cflags`"

  age.identityPaths = ["/etc/.secrets/.age.key"];
  # age.secrets = {
  #   # "filebrowser" = { file = ./secrets/filebrowser.age; owner="wwwrun";};
  #   "openidc.seafile" = { file = ./secrets/openidc.seafile.age;
  #   owner = "oauth2-proxy";
  #   group = "oauth2-proxy";};
  #   # "httpd.filebrowser.conf" = { file = ./secrets/httpd.filebrowser.conf.age; owner="wwwrun";};
  #   # "httpd.newuser.conf" = { file = ./secrets/httpd.newuser.conf.age; owner="wwwrun";};
  # };
  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  time.timeZone = "Europe/Paris";

  environment.sessionVariables = {
    EDITOR = "vim";
  };
  # nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
  #   "sftpgo"
  # ];
  security.acme = {
    acceptTerms = true;
    defaults.email = "chris@lesgrandsvoisins.com";
  };

  # console.keyMap = "fr";
  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    # keyMap = "fr";
    useXkbConfig = true; # use xkb.options in tty.
  };

  services = {
    syncthing = {
      enable = true;
      openDefaultPorts = true;
    };

    xserver = {
      xkb.layout = "fr";
      enable = true;

      desktopManager = {
        xterm.enable = false;
        xfce.enable = true;
      };
    };
    displayManager.defaultSession = "xfce";
    locate = {
      enable = true;
      package = pkgs.mlocate;
      # localuser = null;
    };
    # nextcloud = {
    #   enable = true;
    #   hostName = "roses.lesgrandsvoisins.com";
    #   config = {
    #     adminpassFile = "/etc/.secrets/.nextcloud/.adminpass";
    #     dbtype = "sqlite";
    #   };
    #   # database = {
    #   #   createLocally = true;
    #   # };
    # };
  };

  systemd = {
    settings.Manager.DefaultTimeoutStartSec = "600s";
    tmpfiles.rules = [
      "d /export 0755 nfsuser users"
      "d /export/data1 0755 nfsuser users"
      "d /export/data2 0755 nfsuser users"
      "d /export/data3 0755 nfsuser users"
      "d /export/data4 0755 nfsuser users"
      "d /export/data5 0755 nfsuser users"
      "d /export/data6 0755 nfsuser users"
      "d /export/data7 0755 nfsuser users"
      "d /export/data8 0755 nfsuser users"
      "d /export/data9 0755 nfsuser users"
      "d /srv 0755 nfsuser users"
      "d /srv/data1 0755 nfsuser users"
      "d /srv/data2 0755 nfsuser users"
      "d /srv/data3 0755 nfsuser users"
      "d /srv/data4 0755 nfsuser users"
      "d /srv/data5 0755 nfsuser users"
      "d /srv/data6 0755 nfsuser users"
      "d /srv/data7 0755 nfsuser users"
      "d /srv/data8 0755 nfsuser users"
      "d /srv/data9 0755 nfsuser users"
    ];
  };

  services = {
    openssh = {
      enable = true;
      listenAddresses = [
        {
          addr = "0.0.0.0";
          port = 22;
        }
        {
          addr = "[::]";
          port = 22;
        }
      ];
      settings.PermitRootLogin = "no";
    };
    rsyncd.enable = true;
  };
}
