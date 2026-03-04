{
  config,
  pkgs,
  lib,
  # vars,
  ...
}: let
  vars = import ../vars.nix;
in {
  services.postgresql = {
    enable = true;
  };
}
