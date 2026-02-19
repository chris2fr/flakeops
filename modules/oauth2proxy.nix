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
  };
}
