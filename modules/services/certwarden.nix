{ lib, pkgs, config, ... }:

let
  cfg = config.services.certwarden;

  certwardenPkg = pkgs.buildGoModule {
    pname = "certwarden-backend";
    version = "0.27.1"; # adjust version

    src = pkgs.fetchFromGitHub {
      owner = "gregtwallace";
      repo = "certwarden-backend";
      rev = "v0.27.1";
      # rev = "v${version}";
      sha256 = lib.fakeSha256; # replace with real hash after first build
    };

    vendorHash = lib.fakeSha256;

    subPackages = [ "cmd/api-server" ];

    meta = {
      description = "Cert Warden backend - centralized certificate management";
      homepage = "https://github.com/gregtwallace/certwarden-backend";
      license = lib.licenses.mit;
    };
  };

  # Convert Nix options → YAML config file
  configYaml = pkgs.writeText "certwarden-config.yaml" (builtins.toJSON {
    server = {
      port = cfg.port;
    };
    storage = {
      directory = cfg.dataDir;
    };
    logging = {
      level = cfg.logLevel;
    };
    # Add more config fields if upstream adds new ones
  } // cfg.extraConfig);
in
{
  options.services.certwarden = {
    enable = lib.mkEnableOption "Cert Warden certificate management server";

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/certwarden";
      description = "Directory where Cert Warden stores certificates, DB, keys, etc.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port Cert Warden listens on.";
    };

    logLevel = lib.mkOption {
      type = lib.types.str;
      default = "info";
      description = "Logging verbosity level.";
    };

    extraConfig = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Extra raw attrset merged into YAML config.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.certwarden = {
      isSystemUser = true;
      group = "certwarden";
      home = cfg.dataDir;
      createHome = false;
    };

    users.groups.certwarden = {};

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 certwarden certwarden -"
    ];

    systemd.services.certwarden = {
      description = "Cert Warden Backend Service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = ''
          ${certwardenPkg}/bin/api-server \
            --config ${configYaml}
        '';
        User = "certwarden";
        Group = "certwarden";
        Restart = "on-failure";

        # Security hardening
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
    };

    environment.systemPackages = [ certwardenPkg ];
  };
}
