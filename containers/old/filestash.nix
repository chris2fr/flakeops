{ config, pkgs, lib, ... }:
let
in
{
  # containers.filestash = {
  #   autoStart = true;
  #   privateNetwork = true;
  #   hostAddress = "192.168.101.10";
  #   localAddress = "192.168.101.11";
  #   hostAddress6 = "fd00::1";
  #   localAddress6 = "fd00::2";
  #   config = { config, pkgs, lib, ...  }: {
  #     environment.systemPackages = with pkgs; [
  #       ((vim_configurable.override {  }).customize{
  #         name = "vim";
  #         vimrcConfig.customRC = ''
  #           " your custom vimrc  # containers.freeipa = {
  #   autoStart = true;

  #   privateNetwork = true;
  #   hostAddress = "192.168.107.10";
  #   localAddress = "192.168.107.11";
  #   hostAddress6 = "fa01::1";
  #   localAddress6 = "fa01::2";
  #   config = { config, pkgs, lib, ...  }: {
  #     environment.systemPackages = with pkgs; [
  #       ((vim_configurable.override {  }).customize{
  #         name = "vim";
  #         vimrcConfig.customRC = ''
  #           " your custom vimrc
  #           set mouse=a
  #           set nocompatible
  #           colo torte
  #           syntax on
  #           set tabstop     =2
  #           set softtabstop =2
  #           set shiftwidth  =2
  #           set expandtab
  #           set autoindent
  #           set smartindent
  #           " ...
  #         '';
  #         }
  #       )
  #       freeipa
  #     ];
  #     system.stateVersion = "24.11";
  #     nix.settings.experimental-features = "nix-command flakes";
  #     networking = {
  #       firewall.allowedTCPPorts = [ 3000 4971 4972 22 25 80 443 143 587 993 995 636 8443 9443 ];
  #       # useHostResolvConf = true;
  #       useHostResolvConf = lib.mkForce false;
  #     };
  #     time.timeZone = "Europe/Amsterdam";
  #   };
  # };
  #           set mouse=a
  #           set nocompatible
  #           colo torte
  #           syntax on
  #           set tabstop     =2
  #           set softtabstop =2
  #           set shiftwidth  =2
  #           set expandtab
  #           set autoindent
  #           set smartindent
  #           " ...
  #         '';
  #         }
  #       )
  #       wget
  #       vim
  #       curl
  #       lynx
  #       docker-compose
  #       docker
  #       glib
  #       gotools
  #       libraw
  #       python311
  #       stdenv
  #       vips
  #       util-linux
  #     ];
  #     system.stateVersion = "24.11";
  #     nix.settings.experimental-features = "nix-command flakes";
  #     networking = {
  #       firewall = {
  #         enable = true;
  #         allowedTCPPorts = [ 80 443 8334 ];
  #       };
  #       # Use systemd-resolved inside the container
  #       useHostResolvConf = lib.mkForce false;
  #     };
  #     users.users.filestash = {
  #       isNormalUser = true;
  #       extraGroups = ["docker"];
  #     };
  #     services = {
  #       resolved.enable = true;
  #     };
  #   };
  # };


  # networking.nat = {
  #   enable = true;
  #   internalInterfaces = ["ve-+"];
  #   externalInterface = "ens3";
  #   # Lazy IPv6 connectivity for the container
  #   enableIPv6 = true;
  # };

  # networking.vlans."vlandav" = {
  #   id = 8;
  #   interface = "eno1";
  # };

  # To be able to ping containers from the host, it is necessary
  # to create a macvlan on the host on the VLAN 1 network.
  # networking.macvlans.mv-eno1-host = {
  #   interface = "eno1";
  #   mode = "bridge";
  # };
  # networking.interfaces.eno1.ipv4.addresses = lib.mkForce [];
  # networking.interfaces.eno1.ipv6.addresses = lib.mkForce [];
  # networking.interfaces.mv-eno1-host = {
  #   ipv4.addresses = [ { address = "192.168.8.1"; prefixLength = 24; } ];
  #   ipv6.addresses = [ { address = "fc00::8:8:1"; prefixLength = 96; } ];
  # };

  # networking.interfaces."vlandav" = {
  #   ipv4 = {
  #     addresses = [
  #       {
  #         address = "10.8.8.1";
  #         prefixLength = 24;
  #       }
  #     ];
  #   };
  #   ipv6 = {
  #     addresses = [
  #       {
  #         address = "fc00::8:8:1";
  #         prefixLength = 96;
  #       }
  #     ];
  #   };  
  # };

    # networking.firewall.trustedInterfaces = [
    #   "br0"
    # ];

    # networking.bridges = { br0 = { interfaces = [ "enp0s31f6" "ve-dav" ]; }; };
    # networking.interfaces.br0 = {
    #   ipv4.addresses = [ { address = "192.168.8.1"; prefixLength = 24; } ];
    #   ipv6.addresses = [ { address = "fc00::8:8:1"; prefixLength = 96; } ];
    # };

}