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
  version = "gv1.26.3";

  # meta.mainProgram = "memos";

  src = fetchFromGitHub {
    owner = "lesgrandsvoisins";
    repo = "ghost-lgv-headline";
    rev = "gv1.26.3";
    hash = "sha256-nJwl85rfZX4ngVlboRIwF5P7y9PFqJTmKi0SIJHa2pM=";
  };

  buildPhase = ''
    mkdir -p $out
    cp -a . $out
  '';
}
