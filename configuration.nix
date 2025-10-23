{ config, pkgs, lib, filestash, ... }:
let 
  # oidcSeafileSecret = import ./secrets/oidc-seafile-secret.nix;
    oidcRosesSecret = import ./secrets/oidc-roses-secret.nix;
    jwtVouchSecret = import ./secrets/jwt-vouch-secret.nix;
in
{
  nix.settings.experimental-features = "nix-command flakes";
  system.stateVersion = "25.05";
  imports = [
    ./hardware-configuration.nix
    ./common.nix # Des configurations communes pratiques
    ./networking.nix
    ./users.nix
    # ./httpd.nix
    ./nfs.nix
    ./vouch.nix
    ./nginx.nix
    ./seafile.nix
    # ./oauth2-proxy.nix
    # ./containers.nix
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
    filestash
    vips
    vouch-proxy
    oauth2-proxy
    docker
  ];
  virtualisation.docker.enable = true;
  systemd.services.filestash.environment."FILESTASH_PATH" = "/var/lib/filestash";
  systemd.services.copyparty = {
    enable = true;
    wantedBy = ["default.target"];
    script = "/home/mannchri/copyparty/.venv/bin/python -m copyparty --xff-hdr x-forwarded-for --rproxy 1 --xff-src=lan -c /home/mannchri/copyparty/copyparty.conf ";
    description = "CopyParty";
    serviceConfig = {
      WorkingDirectory = "/mnt/chrisdatalive/chris";
      User = "mannchri";
      Group = "users";
    };
  };
  # nix-shell -p gcc    apacheHttpd    pkg-config    apr    aprutil    curlFull    lzlib libgnurl
  # export APR_CFLAGS="`apr-1-config --cflags`"
  # export APR_LIBS="`apr-1-config --libs`"
  # export LIBCURL_CFLAGS="`gnurl-config --cflags`"

  age.identityPaths = [ "/etc/.secrets/.age.key" ];
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
    EDITOR="vim";
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

  # systemd.services.vouch-proxy = {
  #   description = "Vouch-Proxy OpenIDC server for Nginx";
  #   after = [ "network.target" ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     WorkingDirectory = "/home/mannchri/vouch-proxy/";
  #     ExecStart = "/run/current-system/sw/bin/vouch-proxy -config /home/mannchri/vouch-proxy/config.yml";
  #     Restart = "always";
  #     RestartSec = "10s";
  #     User = "mannchri";
  #     Group = "users";
  #   };
  #   unitConfig = {
  #     StartLimitInterval = "1min";
  #   };
  # };

  services = {
    syncthing = {
      enable=true;
      openDefaultPorts=true;
      
    };
    filestash = {
      enable = true;
      paths = {
        config = "/etc/filestash/config.json";
        # tmp = "/tmp/filestash";
        # log = "/var/log/filestash";
      };
      # # optionally customize configuration
      # settings = {
      #   public_url = "https://roses.lgv.info";
      #   data_dir = "/var/lib/filestash";
      #   port = 8334;
      # };
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
    extraConfig = ''
      DefaultTimeoutStartSec=600s
    '';
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

  # security.acme = {
  #   acceptTerms = true;
  #   defaults.email = "chris@lesgrandsvoisins.com";
  # };

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
