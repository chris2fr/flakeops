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
  # home-manager = import vars/home-manager.nix;
in
{
  #  environment.systemPackages = with pkgs; [
  #   gcc 
  #   pkg-config
  #   openssl
  #  ];
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };
  # Define a user account. Don't forget to set a password with ‘passwd’.
  
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