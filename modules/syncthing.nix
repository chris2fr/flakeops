{
  config,
  pkgs,
  lib,
  ...
}: let
  # oidcSeafileSecret = import ../secrets/oidc-seafile-secret.nix;
  oidcRosesSecret = import ../secrets/oidc-roses-secret.nix;
  jwtVouchSecret = import ../secrets/jwt-vouch-secret.nix;
in {
}
