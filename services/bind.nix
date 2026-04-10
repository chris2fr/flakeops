{
  config,
  pkgs,
  lib,
  ...
}: let
  vars = import ../vars.nix;
in {
  users.users.named.uid = vars.uid.named;
  users.users.named.group = "named";
  users.groups.named.gid = vars.gid.named;
  systemd.tmpfiles.rules = [
    "d /var/lib/bind/zones 0775 named named"
  ];
  services.bind = {
    enable = true;

    zones = {
      "configmagic.com" = {
        master = false;
        file = "/var/lib/bind/zones/configmagic.com.txt";
        masters = ["213.239.216.138"];
      };
      "coolgv.com" = {
        master = false;
        file = "/var/lib/bind/zones/coolgv.com.txt";
        masters = ["213.239.216.138"];
      };
      "coolgv.org" = {
        master = false;
        file = "/var/lib/bind/zones/coolgv.org.txt";
        masters = ["213.239.216.138"];
      };
      "coopgv.com" = {
        master = false;
        file = "/var/lib/bind/zones/coopgv.com.txt";
        masters = ["213.239.216.138"];
      };
      "franc.paris" = {
        master = false;
        file = "/var/lib/bind/zones/franc.paris.txt";
        masters = ["213.239.216.138"];
      };
      "gafam.us" = {
        master = false;
        file = "/var/lib/bind/zones/gafam.us.txt";
        masters = ["213.239.216.138"];
      };
      "gdv1.com" = {
        master = false;
        file = "/var/lib/bind/zones/gdv1.com.txt";
        masters = ["213.239.216.138"];
      };
      "gdv1.org" = {
        master = false;
        file = "/var/lib/bind/zones/gdv1.org.txt";
        masters = ["213.239.216.138"];
      };
      # "gdvoisins.org" = {
      #   master = false;
      #   file = "/var/lib/bind/zones/gdvoisins.org.txt";
      #   masters = ["213.239.216.138"];
      # };
      "gdvox.com" = {
        master = false;
        file = "/var/lib/bind/zones/gdvox.com.txt";
        masters = ["213.239.216.138"];
      };
      "ggvv.org" = {
        master = false;
        file = "/var/lib/bind/zones/ggvv.org.txt";
        masters = ["213.239.216.138"];
      };
      "grandsvoisins.com" = {
        master = false;
        file = "/var/lib/bind/zones/grandsvoisins.com.txt";
        masters = ["213.239.216.138"];
      };
      "grandsvoisins.fr" = {
        master = false;
        file = "/var/lib/bind/zones/grandsvoisins.fr.txt";
        masters = ["213.239.216.138"];
      };
      "grandsvoisins.org" = {
        master = false;
        file = "/var/lib/bind/zones/grandsvoisins.org.txt";
        masters = ["213.239.216.138"];
      };
      "grandv.org" = {
        master = false;
        file = "/var/lib/bind/zones/grandv.org.txt";
        masters = ["213.239.216.138"];
      };
      "grandzine.com" = {
        master = false;
        file = "/var/lib/bind/zones/grandzine.com.txt";
        masters = ["213.239.216.138"];
      };
      "grandzine.org" = {
        master = false;
        file = "/var/lib/bind/zones/grandzine.org.txt";
        masters = ["213.239.216.138"];
      };
      "gvcoop.org" = {
        master = false;
        file = "/var/lib/bind/zones/gvcoop.org.txt";
        masters = ["213.239.216.138"];
      };
      "gv.coop" = {
        master = false;
        file = "/var/lib/bind/zones/gv.coop.txt";
        masters = ["213.239.216.138"];
      };
      "gv.je" = {
        master = false;
        file = "/var/lib/bind/zones/gv.je.txt";
        masters = ["213.239.216.138"];
      };
      "gvois.com" = {
        master = false;
        file = "/var/lib/bind/zones/gvois.com.txt";
        masters = ["213.239.216.138"];
      };
      "gvois.org" = {
        master = false;
        file = "/var/lib/bind/zones/gvois.org.txt";
        masters = ["213.239.216.138"];
      };
      "gvplace.com" = {
        master = false;
        file = "/var/lib/bind/zones/gvplace.com.txt";
        masters = ["213.239.216.138"];
      };
      "gvstyle.com" = {
        master = false;
        file = "/var/lib/bind/zones/gvstyle.com.txt";
        masters = ["213.239.216.138"];
      };
      "gv.style" = {
        master = false;
        file = "/var/lib/bind/zones/gv.style.txt";
        masters = ["213.239.216.138"];
      };
      "hopgv.org" = {
        master = false;
        file = "/var/lib/bind/zones/hopgv.org.txt";
        masters = ["213.239.216.138"];
      };
      "l14s.com" = {
        master = false;
        file = "/var/lib/bind/zones/l14s.com.txt";
        masters = ["213.239.216.138"];
      };
      "lesgrandsvoisins.com" = {
        master = false;
        file = "/var/lib/bind/zones/lesgrandsvoisins.com.txt";
        masters = ["213.239.216.138"];
      };
      "lesgv.com" = {
        master = false;
        file = "/var/lib/bind/zones/lesgv.com.txt";
        masters = ["213.239.216.138"];
      };
      "lesgv.org" = {
        master = false;
        file = "/var/lib/bind/zones/lesgv.org.txt";
        masters = ["213.239.216.138"];
      };
      "lesgvs.com" = {
        master = false;
        file = "/var/lib/bind/zones/lesgvs.com.txt";
        masters = ["213.239.216.138"];
      };
      "lgv1.com" = {
        master = false;
        file = "/var/lib/bind/zones/lgv1.com.txt";
        masters = ["213.239.216.138"];
      };
      "lgv.info" = {
        master = false;
        file = "/var/lib/bind/zones/lgv.info.txt";
        masters = ["213.239.216.138"];
      };
      "libregood.com" = {
        master = false;
        file = "/var/lib/bind/zones/libregood.com.txt";
        masters = ["213.239.216.138"];
      };
      "maelanc.com" = {
        master = false;
        file = "/var/lib/bind/zones/maelanc.com.txt";
        masters = ["213.239.216.138"];
      };
      "pargv.com" = {
        master = false;
        file = "/var/lib/bind/zones/pargv.com.txt";
        masters = ["213.239.216.138"];
      };
      "paris14.cc" = {
        master = false;
        file = "/var/lib/bind/zones/paris14.cc.txt";
        masters = ["213.239.216.138"];
      };
      "parisgv.com" = {
        master = false;
        file = "/var/lib/bind/zones/parisgv.com.txt";
        masters = ["213.239.216.138"];
      };
      "parisgv.org" = {
        master = false;
        file = "/var/lib/bind/zones/parisgv.org.txt";
        masters = ["213.239.216.138"];
      };
      "parisle.com" = {
        master = false;
        file = "/var/lib/bind/zones/parisle.com.txt";
        masters = ["213.239.216.138"];
      };
      "parislenuage.com" = {
        master = false;
        file = "/var/lib/bind/zones/parislenuage.com.txt";
        masters = ["213.239.216.138"];
      };
      "parisle.org" = {
        master = false;
        file = "/var/lib/bind/zones/parisle.org.txt";
        masters = ["213.239.216.138"];
      };
      "quiquequoi.com" = {
        master = false;
        file = "/var/lib/bind/zones/quiquequoi.com.txt";
        masters = ["213.239.216.138"];
      };
      "quiquoietc.com" = {
        master = false;
        file = "/var/lib/bind/zones/quiquoietc.com.txt";
        masters = ["213.239.216.138"];
      };
      "resdigita.com" = {
        master = false;
        file = "/var/lib/bind/zones/resdigita.com.txt";
        masters = ["213.239.216.138"];
      };
      "whowhatetc.com" = {
        master = false;
        file = "/var/lib/bind/zones/whowhatetc.com.txt";
        masters = ["213.239.216.138"];
      };
      "yanlomsprod.org" = {
        master = false;
        file = "/var/lib/bind/zones/yanlomsprod.org.txt";
        masters = ["213.239.216.138"];
      };
    };
  };
}
