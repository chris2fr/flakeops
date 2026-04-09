{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
}:
pkgs.stdenv.mkDerivation rec {
  pname = "update-initials";
  version = "1.0";

  src = ./.;

  phases = ["installPhase"];

  installPhase = ''
    mkdir -p $out/bin
    cp ${src}/gv-ldap-update.sh $out/bin/gv-ldap-update.sh
    chmod +x $out/bin/gv-ldap-update.sh
  '';
}
