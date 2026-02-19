{
  config,
  pkgs,
  lib,
  caddy-ui-lesgv,
  ...
}: let
in {
  services.oauth2-proxy = {
    enable = true;
    oidcIssuerUrl = "https://key.gv.je/realms/master";
    keyFile = "/etc/oauth2proxy/.keys.env";
  };
}
