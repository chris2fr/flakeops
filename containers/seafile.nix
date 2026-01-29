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
  containers.seafile = {
    autoStart = true;
    config = {
      system.stateVersion = "25.11";
      systemd.tmpfiles.rules = [
        "d /var/lib/seafile 775 syncin services"
        "d /var/lib/seafile/data 775 syncin services"
      ];
      imports = [
        ../common.nix
      ];
      environment.systemPackages = with pkgs; [
        # nodejs
      ];
      users.users.seafile = {
        isNormalUser = true;
        home = "/var/lib/syncin";
        uid = vars.uids.seafile;
        group = "services";
      };
      users.groups.services.gid = vars.gids.services;
    };
  };
}
