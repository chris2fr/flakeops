# NOT USED

# { config, pkgs, lib, ... }:
# let
# in
# {
#   containers.ghostlesgrandsvoisinscom = {

#   };
#   autoStart = true;
#   config = { config, pkgs, ... }: {
#     users.users.wagtail.uid = 1003;
#     users.users.wwwrun.gid = 54;
#     users.groups.wwwrun.gid = 54;
#     users.groups.wwwrun.members = [ "wagtail" "wwwrun" ];
#     users.users.ghost = {
#       isNormalUser = true;
#       openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
#       extraGroups = [ "wwwrun" ];
#       packages = with pkgs; [
#         nodejs_20
#         # nodejs_18
#       ];
#     };
#     users.users = {
#       wagtail.isNormalUser = true;
#       wwwrun.isNormalUser = true;
#     };
#     nix.settings.experimental-features = "nix-command flakes";
#     time.timeZone = "Europe/Paris";
#     system.stateVersion = "24.11";
#     environment.systemPackages = with pkgs; [
#       ((vim_configurable.override { }).customize {
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
#       }
#       )
#       curl
#       wget
#       lynx
#       dig
#       git
#       tmux
#       gnumake
#     ];
#     systemd.services.ghostio = {
#       enable = true;
#       description = "Ghost systemd service for blog: localhost";
#       environment = {
#         NODE_ENV = "production";
#       };
#       documentation = [ "https://ghost.org/docs/" ];
#       serviceConfig = {
#         Type = "simple";
#         WorkingDirectory = "/var/www/ghost";
#         User = "ghost";
#         ExecStart = "/home/ghost/.nix-profile/bin/node /home/ghost/node_modules/ghost-cli/bin/ghost run";
#         Restart = "always";
#       };
#       wantedBy = [ "multi-user.target" ];
#     };
# }