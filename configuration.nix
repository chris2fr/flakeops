# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{ config, pkgs, lib, ... }:
let
  # mannchriRsaPublic = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/mailserver/vars/cert-public.nix));
  # keyLesgrandsvoisinsVikunja  = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.keylesgrandsvoisins.vikunja));
  # keycloakVikunja  = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.keycloak.vikunja));
  # keyGVcoopVikunja = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.keygvcoop.vikunja));
  # passwordDBSFTPGO = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.db.sftpgo));
  # emailVikunja  = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.keygvcoop.vikunja));
  # emailList  = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.email.list));
  # bindPW  = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bind));
  # keySftpgo = (lib.removeSuffix "\n" (builtins.readFile  /etc/nixos/.secrets.key.sftpgo ));
  home-manager = import vars/home-manager.nix;
in
{
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.config.allowUnfree = true; 
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 113272;
    "fs.inotify.max_user_instances" = 256;
    "fs.inotify.max_queued_events" = 32768;
  };
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./httpd.nix
    ./mailserver.nix
    ./guichet.nix
    ./postgresql.nix
    ./users.nix
    ./systemd.nix
    ./wagtail.nix
    ./common.nix # Des configurations communes pratiques
    ./servers.nix # I am migrating other services here
    ./services.nix
    ./containers.nix
    ./nginx.nix
    (import "${home-manager}/nixos")
  ];
  systemd.tmpfiles.rules = [
    "d /var/www/key.lesgrandsvoisins.com 0755 www users -"
    "d /var/www/lesgrandsvoisins.com 0755 www users -"
    "d /var/www/lesgrandsvoisins 0755 wagtail users -"
    "d /var/www/lesgrandsvoisins/static 0755 wagtail users -"
    "d /var/www/lesgrandsvoisins/medias 0755 wagtail users -"
    "d /run/wagtail-sockets 0770 wagtail wwwrun -"
    "f /run/wagtail-sockets/wagtail.sock 0660 wagtail wwwrun"
  ];
  #  environment.systemPackages = with pkgs; [
  #   gcc 
  #   pkg-config
  #   openssl
  #  ];
  # Use the systemd-boot EFI boot loader.
  environment.systemPackages = with pkgs; [
    yarn
    filebrowser
    cacert
    # burp
    openssl
    # postgresql_14
    qemu
    # (pkgs.callPackage ./etc/sftpgo/sftpgo/default.nix { }  )
    (pkgs.callPackage ./etc/sftpgo/sftpgo-plugin-auth/sftpgoPluginAuth.nix { }  )
  ];
  age.secrets = {
    "keylesgrandsvoisins.vikunja" = { file = ./secrets/keylesgrandsvoisins.vikunja.age; owner = "vikunja";};
    "key.sftpgo" = { file = ./secrets/key.sftpgo.age; owner = "sftpgo";};
    "keycloak.vikunja" = { file = ./secrets/keycloak.vikunja.age;};
    "email.list" = { file = ./secrets/email.list.age; group="wwwrun"; mode="770";};
    # "bind.slappasswd" = { file = ./secrets/bind.slappasswd.age;};
    "vikunja.env" = { 
      file = ./secrets/vikunja.env.age; 
      owner = "vikunja";
    };
  };
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  # Networking
  networking = {
    # hostName = "hetzner005"; # Define your hostname.
    hostName = "mail"; # Define your hostname
    # networkmanager.enable = true;  # Easiest to use and most distros use this by default.
    useDHCP = true;
    enableIPv6 = true;
    interfaces.eno1.ipv6 = {
      addresses = [
        { address = "2a01:4f8:241:4faa::0"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::1"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::2"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::3"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::4"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::5"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::6"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::7"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::8"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::9"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::10"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::11"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::12"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::13"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::14"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::15"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::16"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::17"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::18"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::19"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::20"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::21"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::22"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::23"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::24"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::25"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::26"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::27"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::28"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::29"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::30"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::31"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::32"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::33"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::34"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::35"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::36"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::37"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::38"; prefixLength = 96; }
        { address = "2a01:4f8:241:4faa::39"; prefixLength = 96; }
      ];
      # routes = [
      #   {
      #     address = "2a01:4f8:241:4faa::";
      #     prefixLength = 96;
      #     via = "fe80::329c:23ff:fed3:5162";
      #   }
      # ];
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eno1";
    };
    nat = {
      forwardPorts = [
      {
        destination = "192.168.103.2:443";
        proto = "tcp";
        sourcePort = 11443;
      }
      # {
      #   destination = "192.168.105.11:14443";
      #   proto = "tcp";
      #   sourcePort = 1443;
      # }
      # {
      #   destination = "192.168.105.11:12443";
      #   proto = "tcp";
      #   sourcePort = 12443;
      # }
      # {
      #   destination = "192.168.107.11:10389";
      #   proto = "tcp";
      #   sourcePort = 10389;
      #   # loopbackIPs = ["116.202.236.241" "2a01:4f8:241:4faa::"];
      # }
      # {
      #   destination = "192.168.107.11:10636";
      #   proto = "tcp";
      #   sourcePort = 10636;
      # }
      # {
      #   destination = "192.168.107.11:10389";
      #   proto = "tcp";
      #   sourcePort = 10389;
      # }
      # {
      #   destination = "192.168.107.11:10636";
      #   proto = "tcp";
      #   sourcePort = 10636;
      # }
      ];
    };
    # firewall.enable = false;
    firewall.trustedInterfaces = [ "docker0" "lxdbr1" "lxdbr0" "ve-silverbullet" "ve-openldap" ];
    # Syncthing ports: 8384 for remote access to GUI
    # 22000 TCP and/or UDP for sync traffic
    # 21027/UDP for discovery
    # source: https://docs.syncthing.net/users/firewall.html
    firewall.allowedTCPPorts = [ 22 25 53 80 443 143 587 993 995
      636 
      8443 
      9080 9443 
      10080 10443 
      11443
      12080 12443
      14443
      8384 22000 
      22000 21027 
      10389 10636 
      14389 14636
      1360
    ];
    firewall.allowedUDPPorts = [53];
  };
  # Set your time zone.
  time.timeZone = "Europe/Paris";
  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };
  # Define a user account. Don't forget to set a password with ‘passwd’.
  
  # home-manager.users.crabfit = {
  #   home.packages = with pkgs; [ 
  #     yarn
  #   ];
  #   home.stateVersion = "24.05";
  #   programs.home-manager.enable = true;
  # };
  home-manager.users = {
    fossil = {pkgs, ...}: {
      home.packages = with pkgs; [ 
        fossil
      ];
      home.stateVersion = "24.05";
      programs.home-manager.enable = true;
    };
    # radicale = {pkgs, ...}: {
    #   home.packages = with pkgs; [ 
    #     python311
    #     python311Packages.gunicorn
    #   ];
    #   home.stateVersion = "24.05";
    #   programs.home-manager.enable = true;
    # };
    guichet = {pkgs, ...}: {
      home.packages = with pkgs; [ 
        go
        gnumake
        python311
        nodejs_20
      ];
      home.stateVersion = "24.05";
      programs.home-manager.enable = true;
    };
    filebrowser = {pkgs, ...}: {
      home.packages = with pkgs; [ 
        filebrowser
      ];
      home.stateVersion = "24.05";
      programs.home-manager.enable = true;
    };
    mannchri = {pkgs, ...}: {
      home.packages = [ 
        pkgs.atool 
        pkgs.httpie 
        pkgs.nodejs_20
      ];
      home.stateVersion = "24.05";
      programs.home-manager.enable = true;
      programs.vim = {
        enable = true;
        plugins = with pkgs.vimPlugins; [ vim-airline ];
        settings = { ignorecase = true; tabstop = 2; };
        extraConfig = ''
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
        '';
      };
    };
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
  environment.sessionVariables = rec {
    EDITOR="vim";
    WAGTAIL_ENV = "production";
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "contact@lesgrandsvoisins.com";
    defaults.webroot = "/var/www/html";
    # certs."0.lesgrandsvoisins.com" = {};  
    # certs."1.lesgrandsvoisins.com" = {};  
    # certs."2.lesgrandsvoisins.com" = {};  
    # certs."3.lesgrandsvoisins.com" = {};  
    # certs."4.lesgrandsvoisins.com" = {};  
    # certs."5.lesgrandsvoisins.com" = {};  
    # certs."6.lesgrandsvoisins.com" = {};  
    # certs."7.lesgrandsvoisins.com" = {};  
    certs."8.lesgrandsvoisins.com" = {};  
    certs."9.lesgrandsvoisins.com" = {};  
    certs."10.lesgrandsvoisins.com" = {};  
    certs."sftpgo.lesgrandsvoisins.com" = {};  
    certs."linkding.lesgrandsvoisins.com" = {};  
  };
  virtualisation.libvirtd.enable = true;
  # programs.virt-manager.enable = true;
  # dconf.settings = {
  #   "org/virt-manager/virt-manager/connections" = {
  #     autoconnect = ["qemu:///system"];
  #     uris = ["qemu:///system"];
  #   };
  # };
  

  # services.authelia.instances = {
  #   main = {
  #     enable = true;
  #     secrets.storageEncryptionKeyFile = "/etc/authelia/storage.key ";
  #     secrets.jwtSecretFile = "/etc/authelia/jwt.key";
  #     settings = {
  #       theme = "light";
  #       default_2fa_method = "totp";
  #       log.level = "debug";
  #       server.disable_healthcheck = true;
  #     };
  #   };
    # preprod = {
    #   enable = false;
    #   secrets.storageEncryptionKeyFile = "/mnt/pre-prod/authelia/storageEncryptionKeyFile";
    #   secrets.jwtSecretFile = "/mnt/pre-prod/jwtSecretFile";
    #   settings = {
    #     theme = "dark";
    #     default_2fa_method = "webauthn";
    #     server.host = "0.0.0.0";
    #   };
    # };
    # test.enable = true;
    # test.secrets.manual = true;
    # test.settings.theme = "grey";
    # test.settings.server.disable_healthcheck = true;
    # test.settingsFiles = [ "/mnt/test/authelia" "/mnt/test-authelia.conf" ];
  # };

  # nixpkgs.config.allowUnfree = true;
  # services.cockroachdb = {
  #    enable = true;
  #    http.port = 9090;
  #    locality = "country=fr";
  #    insecure = true;
  # };


  # services.zitadel = {
  #   enable = true;
  #   masterKeyFile = "/etc/nixos/.secrets.zitadel";
  #   settings = {
  #     TLS.KeyPath = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/key.pem";
  #     TLS.CertPath = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/fullchain.pem";
  #     ExternalDomain = "hetzner005.lesgrandsvosins.com";
  #     ExternalSecure = true;
  #     ExternalPort = 8443;
  #   };
  # };
  # users.users.zitadel.extraGroups = ["wwwrun"];
  
  # services.traefik = {
  #   enable = true;
  #   staticConfigOptions = {
  #     api = true;

  #     entryPoints = {
  #       # web = {
  #       #   address = ":10080/tcp";
  #       #   http.redirections.entrypoint = {
  #       #      to = "websecure";
  #       #      scheme = "https";
  #       #   };
  #       # };
  #       websecure = {
  #         address = ":10443";
  #         # http.tls = true;
  #         # http.tls.domains=[{main="hetzner005.lesgrandsvoisins.com";}];
  #       };
       
  #       # websecure = {
  #       #   address = 10443;
  #       #   http.tls = {
  #       #      certResolver = "leresolver";
  #       #      domains = [{main = "hetzner005.lesgrandsvoisins.com"}];
  #       #   };
  #       # };
  #       # http.redirections.entrypoint = {
  #       #     to = "websecure";
  #       #     scheme = "https";
  #       #   };

  #     };
  #     # providers = {
  #     #   http = {
  #     #     tls = {
  #     #       cert = default;
  #     #       key = default;
  #     #     };
  #     #   };
  #     # };

  #     # forwardedHeaders.insecure = true;
  #     # providers = {
  #     #   http = {
  #     #     endpoint = "https://dav.lesgrandsvoisins.com";
  #     #     tls = {
  #     #       cert = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/fullchain.pem";
  #     #       key = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/key.pem";
  #     #     }
  #     #   }
  #     # }
  #   };
  #   dynamicConfigOptions = {
  #   #   # routes = [{
  #   #   #   match = "(PathPrefix(`/dashboard`)";
  #   #   #   kind = "Rule";
  #   #   #   services = [{name="api@internal";kind="TraefikService";}];
  #   #   # }];
  #   #   # http.middlewares.prefix-strip.stripprefixregex.regex = "/[^/]+";
  #     http = {
  #   #     # services = {
  #   #     #   rtl.loadBalancer.servers = [ { url = "http://169.254.1.29:3000/"; } ];
  #   #     #   spark.loadBalancer.servers = [ { url = "http://169.254.1.17:9737/"; } ];
  #   #     # };
  #       services = {
  #         www.loadBalancer.servers = [ { url = "https://www.lesgrandsvoisins.com/"; } ];
  #       };
  #       routers = {
  #         myrouter = {
  #           rule = "Host(`hetzner005.lesgrandsvoisins.com`)";
  #           # entryPoints = [ "websecure" ];
  #           service = "www";
  #           tls = true;
  #         };
  #       };
  #     };  
  #     tls = {
  #       # certificates = [{
  #       #   certFile = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/fullchain.pem";
  #       #   keyFile = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/key.pem";
  #       #   # stores = "hetzner005.lesgrandsvoisins.com";
  #       # }];
  #       stores.default.defaultCertificate = {
  #         certFile = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/fullchain.pem";
  #         keyFile = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/key.pem";
  #       };
  #     };
  #   };
  # };
}