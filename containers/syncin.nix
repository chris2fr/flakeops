{
  pkgs,
  lib,
  config,
  ...
}: let
  vars = import ../vars.nix;
in {
  containers.syncin = {
    autoStart = false;
    config = {
      system.stateVersion = "25.11";
      systemd.services.phylum = {
        wantedBy = ["default.target"];
        description = "Casiers électornaiues Phylum";
        serviceConfig = {
          WorkingDirectory = "/var/lib/phylum";
          User = "syncin";
          Group = "services";
        };
        enable = true;
        script = "${pkgs.go}/bin/go run -C server cmd/phylum.go  -W /var/lib/phylum/data/ -c /var/lib/phylum/data/config.yml serve";
        path = with pkgs; [
          go
          gcc
          # postgresql
          vips
        ];
      };
      systemd.tmpfiles.rules = [
        "d /var/lib/syncin 775 syncin services"
        "d /var/lib/syncin/data 775 syncin services"
      ];
      imports = [
        ../modules/common.nix
      ];
      environment.systemPackages = with pkgs; [
        nodejs
        mariadb
        go
        gcc
        postgresql
        vips
      ];
      users.users.syncin = {
        isNormalUser = true;
        home = "/var/lib/syncin";
        uid = vars.uid.syncin;
        group = "services";
      };
      users.groups.services.gid = vars.gid.services;
      services.postgresql = {
        enable = true;
        ensureUsers = [
          {
            name = "phylum";
            ensureDBOwnership = true;
          }
        ];
        ensureDatabases = ["phylum"];
      };
      services.mysql = {
        enable = true;
        package = pkgs.mariadb;
        ensureDatabases = [
          "syncin"
        ];
        ensureUsers = [
          {
            name = "syncin";
            ensurePermissions = {
              "syncin.*" = "ALL PRIVILEGES";
            };
          }
          {
            name = "phylum";
            ensurePermissions = {
              "syncin.*" = "ALL PRIVILEGES";
            };
          }
        ];
        initialDatabases = [
          {
            name = "syncin";
          }
        ];
      };
    };
  };
}
