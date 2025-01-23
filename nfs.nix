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


  
  fileSystems = {
    "/dev/disk/by-label/RaidData2" = {mountPoint = "/srv/rd2";device="/dev/disk/by-label/RaidData2";};
    "/dev/disk/by-label/RaidData3" = {mountPoint = "/srv/rd3";device="/dev/disk/by-label/RaidData3";};
    "/dev/disk/by-label/RaidData4" = {mountPoint = "/srv/rd4";device="/dev/disk/by-label/RaidData4";};
    "/export/rd1" = {device="/srv/rd1";options=["bind"];};  
    "/export/rd2" = {device="/srv/rd2";options=["bind"];};  
    "/export/rd3" = {device="/srv/rd3";options=["bind"];};  
    "/export/rd4" = {device="/srv/rd4";options=["bind"];};  
  };

  services.nfs.server = {
    enable = true;
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
    extraNfsdConfig = '''';
    exports = ''
      /export 192.168.1.0/24(rw,fsid=0,no_subtree_check) 10.0.0.0/24(rw,fsid=0,no_subtree_check)
      /export/rd1 192.168.1.0/24(rw,nohide,insecure,no_subtree_check) 10.0.0.0/24(rw,nohide,insecure,no_subtree_check)
      /export/rd2 192.168.1.0/24(rw,nohide,insecure,no_subtree_check) 10.0.0.0/24(rw,nohide,insecure,no_subtree_check)
      /export/rd3 192.168.1.0/24(rw,nohide,insecure,no_subtree_check) 10.0.0.0/24(rw,nohide,insecure,no_subtree_check)
      /export/rd4 192.168.1.0/24(rw,nohide,insecure,no_subtree_check) 10.0.0.0/24(rw,nohide,insecure,no_subtree_check)
    '';
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "resdigidell";
        "netbios name" = "resdigidell";
        "security" = "user";
        #"use sendfile" = "yes";
        #"max protocol" = "smb2";
        # note: localhost is the ipv6 localhost ::1
        "hosts allow" = "192.168.1. 10.0.0. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      # "public" = {
      #   "path" = "/mnt/Shares/Public";
      #   "browseable" = "yes";
      #   "read only" = "no";
      #   "guest ok" = "yes";
      #   "create mask" = "0644";
      #   "directory mask" = "0755";
      #   "force user" = "username";
      #   "force group" = "groupname";
      # };
      "rd2" = lib.recursiveUpdate sambaBaseParams {path = "/export/rd2";};
      "rd3" = lib.recursiveUpdate sambaBaseParams {path = "/export/rd3";};
      "rd4" = lib.recursiveUpdate sambaBaseParams {path = "/export/rd4";};
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

}