{ config, pkgs, lib, ... }:
let
in {
  imports = [
    # Include the results of the hardware scan.
    # services/bind.nix
    services/haproxy.nix
    services/radicale.nix
    services/sftpgo.nix
    services/vikunja.nix
    services/syncthing.nix
    services/homepage-dashboard.nix
  ];
  # List services that you want to enable:
  services = {
    writefreely = {
      acme.enable = true;
      admin.name = "lesgrandsvoisins";
      # database.createLocally = true;
      # database.passwordFile = "/etc/.secret.writefreely.mysql";
      # database.type = "mysql";
      enable = true;
      host = "writefreely.lesgrandsvoisins.com";
      nginx.enable = true;
      nginx.forceSSL = true;
      settings = {
        # server = {
        #   port = 9090;
        # };
        app = {
          site_name = "Les Grands Voisins";
          min_username_len = 3;
          site_description = "WriteFreely for Les Grands Voisins";
          editor = "classic";
          single_user = false;
          federation = true;
          monetization = true;
          open_registration = true;
          private = false;
          user_invites = true;
        };
      };
    };
    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      settings.PermitRootLogin = "prohibit-password";
    };
    vaultwarden = {
      enable = true;
    };
    uptime-kuma = {
      enable = true;
    };
    ethercalc = {
      enable = true;
      port = 8123;
    };
    xandikos = {
      enable = true;
      port = 5280;
      extraOptions = [
        "--autocreate"
        "--defaults"
      ];
    };
    minio = {
      enable = true;
    };
    etebase-server = {
      enable = true;
      unixSocket = "/var/lib/etebase-server/etebase-server.sock";
      user = "etebase-server";
      settings = {
        global.debug = false;
        global.secret_file = "/var/lib/etebase-server/.secrets.etebase"; # mind permissions
        allowed_hosts.allowed_host1 = "ete.village.ngo";
      };
    };
    # etesync-dav = {
    #   enable = true;
    #   apiUrl = "https://ete.village.ngo";
    #   # sslCertificate = "/var/lib/acme/ete.village.ngo/full.pem";
    #   # sslCertificateKey = "/var/lib/acme/ete.village.ngo/key.pem";
    #   host = "https://etedav.village.ngo";
    # };
    # coredns = {
    #   enable = true;
    #   config = ''
    #   '';
    # };
    # seafile = {
    #   enable = true;
    #   adminEmail = "chris@lesgrandsvoisins.com";
    #   initialAdminPassword = emailList;
    #   seahubAddress = "https://drive.lesgrandsvoisins.com:10443";
    # };
  };
}
