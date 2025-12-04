{ lib, stdenv }:

stdenv.mkDerivation rec {
  pname = "caddy-ui-lesgrandsvoisins";
  version = "1.0.1";

  src = ./caddy-ui-lesgrandsvoisins;
  installPhase = lib.strings.concatStrings [
    ''
    mkdir -p $out/assets/portal/templates/lesgrandsvoisins
    mkdir -p $out/assets/images
    ''
    (lib.strings.concatMapStrings (x: "install -Dm644 ./${x} out/${x}\n") [
    "assets/portal/templates/lesgrandsvoisins/login.template"
    "assets/images/logo-lesgrandsvoisins-800-400-white.png"
    ] )
  ];
}