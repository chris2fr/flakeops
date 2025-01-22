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
    "/srv/data1" = {mountPoint = "/srv/data1";device="/dev/disk/by-label/CHRISDATALIVE";};
    "/export/data1" = {device="/srv/data1";options=["bind"];};  
  };
  services.nfs.server.exports = ''
    /export 192.168.1.0/24(rw,fsid=0,no_subtree_check)
    /export/data1 192.168.1.0/24(rw,nohide,insecure,no_subtree_check)
  '';
}