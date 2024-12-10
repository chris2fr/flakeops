{ config, pkgs, lib, ... }:
let 
in{
    services.radicale = {
      enable = true;
      settings = {
        auth.type = "http_x_remote_user";
        # logging.level = "debug";
        # web.type = "none";
        # server = {
        #   ssl = true;
        #   certificate = "/var/lib/acme/dav.resdigita.com/fullchain.pem";
        #   key = "/var/lib/acme/dav.resdigita.com/key.pem";
        #   certificate_authority = "/var/lib/acme/dav.resdigita.com/fullchain.pem";
        # };
      };
      rights = {
        root = {
          user = ".+";
          collection = "";
          permissions = "R";
        };
        principal = {
          user = ".+";
          collection = "{user}/[^/]+";
          permissions = "rw";
        };
        shared = {
          user = ".*";
          collection = "(shared|resdigita|interetpublic|lesgrandsvoisins)/[^/]*";
          permissions = "RW";
        };
      };
    };
}