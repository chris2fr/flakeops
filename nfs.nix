{ config, pkgs, lib, ... }:
let 
  sambaBaseParams = {
    "browseable" = "yes";
    "read only" = "no";
    "guest ok" = "no";
    "create mask" = "0664";
    "directory mask" = "0775";
    "force user" = "nfsuser";
    "force group" = "nfsuser";
  };
in 
{
  services.nfs.server = {
    enable = true;
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
    extraNfsdConfig = '''';
  };
  fileSystems = {
    "/export/data1" = {device="/mnt/chrisdatalive";options=["bind"];};
  };
  services.nfs.server.exports = ''
    /export 192.168.1.0/24(rw,fsid=0,no_subtree_check)
    /export/data1 192.168.1.0/24(rw,nohide,insecure,no_subtree_check)
  '';
}