{ config, pkgs, lib, ... }:
let
in {
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    overrideFolders = true;
    overrideDevices = true;
    settings = {
      devices = {
        "mannchrilenovoslim7" = {
          id = "VJKOQSN-AC3YKXV-AV4N74C-MH7HZ4R-GBTAGOV-SETMPBT-GCKJC5M-G6XSVQL";
          autoAcceptFolders = true;
        };
        "mannchriphone" = {
          id = "SUJCVUC-XXVY326-42GP5IU-UO6RMEJ-2IHAXEL-KBA4YPU-BQFQMYN-YG66ZQZ";
          autoAcceptFolders = true;
        };
      };
      folders = {
        "LogSeqMann" = {
          enable = true;
          id = "LogSeqMann";
          label = "LogSeqMann";
          path = "/var/lib/syncthing/LogSeqMann";
          devices = [ "mannchrilenovoslim7" "mannchriphone" ];
          ignorePerms = false; # By default, Syncthing doesn't sync file permissions. This line enables it for this folder.
        };
      };
    };
  };
}
