{ config, pkgs, lib, ... }:
let
in
{
  containers.filestash = {
    autoStart = true;
    privateNetwork = true;
    extraVeths.eveth0 = {
      hostAddress = "192.168.1.100";
      localAddress = "192.168.1.111";
      hostAddress6 = "fe80::1298:36ff:fea0:2131";
      localAddress6 = "fe80::1298:36ff:fea0:0111";
    };
    # macvlans = ["eno1"];

    # hostBridge = "br-erdock";
    # hostAddress = "192.168.1.100";
    # localAddress = "192.168.1.111";
    # hostAddress6 = "fe80::1298:36ff:fea0:2131";
    # localAddress6 = "fe80::1298:36ff:fea0:0111";
    interfaces = ["eno1"];
    # bindMounts = {};
    config = { config, pkgs, ... }: {
      nix.settings.experimental-features = "nix-command flakes";
      time.timeZone = "Europe/Paris";
      system.stateVersion = "25.05";
      networking = {
        firewall.enable = false;
        # firewall = {
        #   enable = true;
        #   allowedTCPPorts = [ 80 443 ];
        # };
        # Use systemd-resolved inside the container
        useHostResolvConf = lib.mkForce false;
      };
      environment.systemPackages = with pkgs; [
        ((vim_configurable.override { }).customize {
          name = "vim";
          vimrcConfig.customRC = ''
            " your custom vimrc
            set mouse=a
            set nocompatible
            colo torte
            syntax on
            set tabstop     =2
            set softtabstop =2
            set shiftwidth  =2
            set expandtab
            set autoindent
            set smartindent
            " ...
          '';
        })
        docker-compose
        git
        wget
        perl
        podman
        # for fielstash
        ffmpeg
        libjpeg
        libtiff
        libpng
        libwebp
        libraw
        libheif
        giflib
        vips
        go_1_23
        glibc
        perl
        jansson

      ];
      # systemd.tmpfiles.rules = [];
      virtualisation.docker.enable = true;
      virtualisation.podman.enable = true;
      services = {
        resolved.enable = true;
      };
      users.users.filestash = {
        isNormalUser = true;
        extraGroups = ["docker"];
      };
      users.extraGroups.docker.members = [ "filestash" ];
    };
  };
}