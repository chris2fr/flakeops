{ config, pkgs, lib, ... }:
let 
in
{
  ############################################################
  # FROM NFS.NIX
  ############################################################
  # fileSystems = {
  #   "/dev/disk/by-label/RaidData2" = {mountPoint = "/srv/rd2";device="/dev/disk/by-label/RaidData2";};
  #   "/dev/disk/by-label/RaidData3" = {mountPoint = "/srv/rd3";device="/dev/disk/by-label/RaidData3";};
  #   "/dev/disk/by-label/RaidData4" = {mountPoint = "/srv/rd4";device="/dev/disk/by-label/RaidData4";};
  #   "/export/rd1" = {device="/srv/rd1";options=["bind"];};  
  #   "/export/rd2" = {device="/srv/rd2";options=["bind"];};  
  #   "/export/rd3" = {device="/srv/rd3";options=["bind"];};  
  #   "/export/rd4" = {device="/srv/rd4";options=["bind"];};  
  # };
  # services.nfs.server.exports = ''
  #   /export 192.168.1.0/24(rw,fsid=0,no_subtree_check)
  #   /export/rd1 192.168.1.0/24(rw,nohide,insecure,no_subtree_check)
  #   /export/rd2 192.168.1.0/24(rw,nohide,insecure,no_subtree_check)
  #   /export/rd3 192.168.1.0/24(rw,nohide,insecure,no_subtree_check)
  #   /export/rd4 192.168.1.0/24(rw,nohide,insecure,no_subtree_check)
  # '';
}