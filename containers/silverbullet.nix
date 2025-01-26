{ config, pkgs, lib, ... }:
let
  home-manager = import ../vars/home-manager.nix;
in
{
  containers.silverbullet = {
    autoStart = true;
    privateNetwork = true;
    # macvlans = ["vlan2"];
    # hostBridge = "br2";
    hostAddress = "192.168.102.1";
    localAddress = "192.168.102.2";
    hostAddress6 = "fc00::2:1";
    localAddress6 = "fc00::2:2";
    bindMounts = {
      "/var/lib/silverbullet/back" = {
        hostPath = "/var/lib/silverbullet/back";
        isReadOnly = false;
      }; 
      # "/var/lib/burp/etc/silverbullet.resdigita.com" = {
      #   hostPath = "/var/lib/acme/silverbullet.resdigita.com";
      #   isReadOnly = true;
      # }; 
    };
    config = { config, pkgs, lib, ... }: {
      nix.settings.experimental-features = "nix-command flakes";
      time.timeZone = "Europe/Amsterdam";
      system.stateVersion = "24.11";
      environment.systemPackages = with pkgs; [
        ((vim_configurable.override {  }).customize{
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
          }
        )
        python311
        busybox
        curl
        wget
        lynx
        dig    
        git
        tmux
        killall
        pwgen
        gettext
        home-manager
        # burp
        # backintime
        # deno
        kopia
      ];
      networking = {
        firewall.allowedTCPPorts = [ 3000 4971 4972 22 25 80 443 143 587 993 995 636 8443 9443 ];
        # useHostResolvConf = true;
        useHostResolvConf = lib.mkForce false;
        # nameservers = ["8.8.8.8" "8.8.4.4" "2001:4860:4860::8888" "2001:4860:4860::8844"];
        # nameservers = ["8.8.8.8" "8.8.4.4"];
      };
      users.users = {
        mannchri.isNormalUser = true;
        silverbullet.isNormalUser = true;
      };
      imports = [
         (import "${home-manager}/nixos")
      ];
      home-manager.users.silverbullet = {pkgs, ...}: {
        home.packages = with pkgs; [ 
          deno
        ];
        home.stateVersion = "24.11";
        programs.home-manager.enable = true;
      };
      services = {
        resolved.enable = true;
        # bourgbackup = {
        #   enable = true;
        #   jobs = {
        #      paths = "/home/silverbullet/quartz/";
        #      exclude = [ "/home/silverbullet/quartz/.git" ];
        #      repo = "/mnt/host/silverbullet";
        #      startAt = "daily";
        #   };
        # };
      };
      systemd = {
        timers.kopia = {
          description = "Kopia backup schedule";
          timerConfig = {
            Unit = "kopia.service";
            OnUnitActiveSec = "1h";
            OnBootSec = "15min";
          };
          wantedBy = ["timers.target"];
        };
        services = {
          kopia = {
            description = "Kopia Snapshot of Silverbullet";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              WorkingDirectory = "/home/silverbullet/quartz/";
              Environment = "PATH=/run/wrappers/bin:/home/silverbullet/.nix-profile/bin:/nix/profile/bin:/home/silverbullet/.local/state/nix/profile/bin:/etc/profiles/per-user/silverbullet/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin;";
              Restart = "no";
              User = "silverbullet";
              Group = "users";
            };
            script = ''
              /run/current-system/sw/bin/kopia repository connect from-config --token ${(lib.removeSuffix "\n" (builtins.readFile ../secrets/kopia.silverbullet))}
              /run/current-system/sw/bin/kopia snapshot create /home/silverbullet/quartz/
              return 0
            '';
          };
          silverbullet = {
            description = "SilverBullet.Resdigita.com";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              WorkingDirectory = "/home/silverbullet/.nix-profile/bin/";
              Environment = "PATH=/home/silverbullet/.deno/bin:/run/wrappers/bin:/home/silverbullet/.nix-profile/bin:/nix/profile/bin:/home/silverbullet/.local/state/nix/profile/bin:/etc/profiles/per-user/silverbullet/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin;";
              ExecStart = ''/home/silverbullet/.deno/bin/silverbullet -L 192.168.102.2 /home/silverbullet/quartz/'';
              Restart = "always";
              RestartSec = "10s";
              User = "silverbullet";
              Group = "users";
            };
            unitConfig = {
              StartLimitInterval = "1min";
            };
          };
        };
      };
    };
  };
}