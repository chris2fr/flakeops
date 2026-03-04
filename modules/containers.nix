{
  pkgs,
  lib,
  config,
  ...
}: let
  vars = import ../vars.nix;
in {
  imports = [
    # ../containers/syncin.nix
    ../containers/seafile.nix
  ];
}
