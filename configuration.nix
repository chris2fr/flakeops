{ config, pkgs, lib, ... }:
let 
in
{
  nix.settings.experimental-features = "nix-command flakes";
  system.stateVersion = "24.11";
  imports = [
    ./hardware-configuration.nix
    ./common.nix # Des configurations communes pratiques
    ./networking.nix
    ./users.nix
    ./nfs.nix
  ];
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

  console.keyMap = "fr";
  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8"; 
     console = { 
     font = "Lat2-Terminus16";
     keyMap = "fr";
     useXkbConfig = true; # use xkb.options in tty.
   };

  services = {
    # 
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
      localuser = null;
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
    seafile = {
      enable = true;

      adminEmail = "chris@lesgrandsvoisins.com";
      initialAdminPassword = "change this later!";

      ccnetSettings.General.SERVICE_URL = "https://roses.lesgrandsvoisins.com";

      seafileSettings = {
        fileserver = {
          host = "unix:/run/seafile/server.sock";
        };
      }; 
    };
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
      # listenAddresses = [
      #   {
      #     addr = "0.0.0.0";
      #     port = 22;
      #   } 
      # ];
      settings.PermitRootLogin = "no";
    };
    rsyncd.enable = true;
    nginx = {
      enable = true;
      clientMaxBodySize = "6G";
      virtualHosts = {
        localhost = {
          locations."/" = {
            return = "200 '<html><body>It works</body></html>'";
            extraConfig = ''
              default_type text/html;
            '';
          };
        };
        "roses.lesgrandsvoisins.com" = {
          # sslCertificate = "/path/to/cert.pem";
          # sslCertificateKey = "/path/to/key.key";
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              proxyPass = "http://unix:/run/seahub/gunicorn.sock";
              extraConfig = ''
                proxy_set_header   Host $host;
                proxy_set_header   X-Real-IP $remote_addr;
                proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header   X-Forwarded-Host $server_name;
                proxy_read_timeout  1200s;
                client_max_body_size 0;
              '';
            };
            "/seafhttp" = {
              proxyPass = "http://unix:/run/seafile/server.sock";
              extraConfig = ''
                rewrite ^/seafhttp(.*)$ $1 break;
                client_max_body_size 0;
                proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_connect_timeout  36000s;
                proxy_read_timeout  36000s;
                proxy_send_timeout  36000s;
                send_timeout  36000s;
              '';
            };
          };
        };
      };
    };
  };
}
