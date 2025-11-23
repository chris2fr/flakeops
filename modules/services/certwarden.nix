{ config, lib, pkgs, ... }:

let
  cfg = config.services.certwarden;
in
{
  options.services.certwarden = {
    enable = lib.mkEnableOption "Cert Warden service";

    package = lib.mkOption {
      type = lib.types.package;
      description = "Cert Warden package to run.";
    };

    workingDir = lib.mkOption {
      type = lib.types.path;
      default = "/opt/certwarden";
      description = "Working directory containing Cert Warden data and binary.";
    };
  };

  config = lib.mkIf cfg.enable {

    users.users.certwarden = {
      isSystemUser = true;
      group = "certwarden";
      home = cfg.workingDir;
    };

    users.groups.certwarden = {};

    systemd.tmpfiles.rules = [
      "d ${cfg.workingDir} 0755 certwarden certwarden -"
    ];

    systemd.services.certwarden = {
      description = "Cert Warden";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        User = "certwarden";
        WorkingDirectory = cfg.workingDir;
        ExecStart = "${cfg.package}/bin/certwarden";
        Restart = "always";
        RestartSec = "5s";

        # Optional safety
        ProtectSystem = "strict";
        ProtectHome = true;
        NoNewPrivileges = true;
      };
    };
  };
}
