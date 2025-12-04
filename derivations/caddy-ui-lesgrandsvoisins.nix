{ lib, stdenv }:

stdenv.mkDerivation rec {
  pname = "caddy-ui-lesgrandsvoisins";
  version = "1.0.0";

  src = ./caddy-ui-lesgrandsvoisins/.;

}