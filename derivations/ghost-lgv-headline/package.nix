{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  stdenv ? pkgs.stdenv,
  fetchurl ? pkgs.fetchurl,
  autoPatchelfHook ? pkgs.autoPatchelfHook,
  makeWrapper ? pkgs.makeWrapper,
  glibc ? pkgs.glibc,
  go_1_26 ? pkgs.go_1_26,
  fetchFromGitHub ? pkgs.fetchFromGitHub,
  buildGoModule ? pkgs.buildGoModule,
  ...
}:
stdenv.mkDerivation rec {
  pname = "ghost-lgv-headline";
  version = "gv0.26.1";

  # meta.mainProgram = "memos";

  src = fetchFromGitHub {
    owner = "lesgrandsvoisins";
    repo = "ghost-lgv-headline";
    rev = "gv0.26.2";
    hash = "sha256-EmnRL4hwXzbht1U20bG+nfgPzLn3hwd2I2I8iYNaZOA=";
  };

  buildPhase = ''
    mkdir -p $out
    cp -a . $out
  '';
}
