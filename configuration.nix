{ config, pkgs, lib, ... }:
let 
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
  ];

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

  services = {

    nginx.enable = true;

    oauth2-proxy = {
      enable = true;

      # Common configuration
      provider = "keycloak-oidc"; # or "github", "gitlab", "azure", etc.
      email.domains = ["*"]; # restrict to specific email domains
      
      # Client credentials (register your app with the OAuth provider)
      clientID = "searfile";
      clientSecret = "your-client-secret";
      
      # Cookie settings
      cookie.secret = "NgbKPVOqtJn5bipSRGuR22BwasVS1J5u"; # generate with: openssl rand -base64 32 | head -c 32 | base64
      
      # Additional settingsenvironment.systemPackages = with pkgs; [
      # upstream = "http://localhost:1234"; # your backend service
      httpAddress = "0.0.0.0:4180"; # where oauth2-proxy listens
      reverseProxy = false;
      upstream = "file:///var/www/default";
      tls = {
        enable = true;
        certificate = "/var/lib/acme/roses.lgv.info/fullchain.pem";
        key = "/var/lib/acme/roses.lgv.info/privkey.pem";
        httpsAddress = ":443";
      };
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
      seahubExtraConf = ''
        FILE_PREVIEW_MAX_SIZE = 100 * 1024 * 1024
        THUMBNAIL_IMAGE_SIZE_LIMIT = 100 # MB

        # ENABLE_REMOTE_USER_AUTHENTICATION = True

        # # Optional, HTTP header, which is configured in your web server conf file,
        # # used for Seafile to get user's unique id, default value is 'HTTP_REMOTE_USER'.
        # REMOTE_USER_HEADER = 'HTTP_REMOTE_USER'

        # # Optional, when the value of HTTP_REMOTE_USER is not a valid email address，
        # # Seafile will build a email-like unique id from the value of 'REMOTE_USER_HEADER'
        # # and this domain, e.g. user1@example.com.
        # REMOTE_USER_DOMAIN = 'lesgrandsvoisins.com'

        # # Optional, whether to create new user in Seafile system, default value is True.
        # # If this setting is disabled, users doesn't preexist in the Seafile DB cannot login.
        # # The admin has to first import the users from external systems like LDAP.
        # REMOTE_USER_CREATE_UNKNOWN_USER = True

        # # Optional, whether to activate new user in Seafile system, default value is True.
        # # If this setting is disabled, user will be unable to login by default.
        # # the administrator needs to manually activate this user.
        # REMOTE_USER_ACTIVATE_USER_AFTER_CREATION = True

        # # Optional, map user attribute in HTTP header and Seafile's user attribute.
        # REMOTE_USER_ATTRIBUTE_MAP = {
        #     'HTTP_DISPLAYNAME': 'name',
        #     'HTTP_MAIL': 'contact_email',

        #     # for user info
        #     "HTTP_GIVENNAME": 'givenname',
        #     "HTTP_SN": 'surname',
        #     "HTTP_ORGANIZATION": 'institution',

        #     # for user role
        #     'HTTP_SHIBBOLETH_AFFILIATION': 'affiliation',
        # }

        # # Map affiliation to user role. Though the config name is SHIBBOLETH_AFFILIATION_ROLE_MAP,
        # # it is not restricted to Shibboleth
        # SHIBBOLETH_AFFILIATION_ROLE_MAP = {
        #     'employee@uni-mainz.de': 'staff',
        #     'member@uni-mainz.de': 'staff',
        #     'student@uni-mainz.de': 'student',
        #     'employee@hu-berlin.de': 'guest',
        #     'patterns': (
        #         ('*@hu-berlin.de', 'guest1'),
        #         ('*@*.de', 'guest2'),
        #         ('*', 'guest'),
        #     ),
        # }
      '';
      # seahubExtraConf = ''
      #   ENABLE_OAUTH = True

      #   # If create new user when he/she logs in Seafile for the first time, defalut `True`.
      #   OAUTH_CREATE_UNKNOWN_USER = True

      #   # If active new user when he/she logs in Seafile for the first time, defalut `True`.
      #   OAUTH_ACTIVATE_USER_AFTER_CREATION = True

      #   # Usually OAuth works through SSL layer. If your server is not parametrized to allow HTTPS, some method will raise an "oauthlib.oauth2.rfc6749.errors.InsecureTransportError". Set this to `True` to avoid this error.
      #   OAUTH_ENABLE_INSECURE_TRANSPORT = False

      #   # Client id/secret generated by authorization server when you register your client application.
      #   OAUTH_CLIENT_ID = "seafile"
      #   OAUTH_CLIENT_SECRET = open("/etc/.secrets/.seafile_client_secret").read().strip()

      #   # Callback url when user authentication succeeded. Note, the redirect url you input when you register your client application MUST be exactly the same as this value.
      #   OAUTH_REDIRECT_URL = 'https://roses.lesgrandsvoisins.com/oauth/callback/'

      #   # The following should NOT be changed if you are using Github as OAuth provider.
      #   OAUTH_PROVIDER_DOMAIN = 'key.lesgrandsvoisins.com' 
      #   OAUTH_PROVIDER = 'key.lesgrandsvoisins.com'

      #   OAUTH_AUTHORIZATION_URL = 'https://key.lesgrandsvoisins.com/realms/master/protocol/openid-connect/auth'
      #   OAUTH_TOKEN_URL = 'https://key.lesgrandsvoisins.com/realms/master/protocol/openid-connect/token'
      #   OAUTH_USER_INFO_URL = 'https://key.lesgrandsvoisins.com/realms/master/protocol/openid-connect/userinfo'
      #   OAUTH_SCOPE = ["profile", "openid", "email"]
      #   OAUTH_ATTRIBUTE_MAP = {
      #     "email": (True, "uid"),
      #     "name": (False, "name")
      #   }
      # '';
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
  };
}
