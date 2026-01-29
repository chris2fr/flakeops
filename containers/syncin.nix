{
  pkgs,
  lib,
  config,
  ...
}:
let
  vars = import ../vars.nix;
in
{
  containers.syncin = {
    autoStart = true;
    config = {
      system.stateVersion = "25.11";
      systemd.tmpfiles.rules = [
        "d /var/lib/syncin 775 syncin services"
        "d /var/lib/syncin/data 775 syncin services"
      ];
      imports = [
        ../common.nix
      ];
      environment.systemPackages = with pkgs; [
        nodejs
        mariadb
        go
        gcc
        postgresql
      ];
      users.users.syncin = {
        isNormalUser = true;
        home = "/var/lib/syncin";
        uid = vars.uids.syncin;
        group = "services";
      };
      users.groups.services.gid = vars.gids.services;
      services.postgresql = {
        enable = true;
        ensureUsers = [
          {
            name = "phylum";
            ensureDBOwnership = true;
          }
        ];
        ensureDatabases = [ "phylum" ];
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
