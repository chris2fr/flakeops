{ lib, stdenv }:

stdenv.mkDerivation rec {
  pname = "caddy-ui-lesgrandsvoisins";
  version = "1.0.3";

  src = ./caddy-ui-lesgrandsvoisins/.;

  install_commands =   (lib.strings.concatMapStrings (x: "install -Dm644 ${src}/${x} \$out/${x}\n") [
    "assets/portal/templates/lesgrandsvoisins/login.template"
    "assets/images/logo-lesgrandsvoisins-800-400-white.png"
    ] );

  installPhase = lib.strings.concatStrings [
    ''
    mkdir -p $out/assets/portal/templates/lesgrandsvoisins
    mkdir -p $out/assets/images
    ${install_commands}
    ''
    # (lib.strings.concatMapStrings (x: "install -Dm644 ${src}/${x} \$out/${x}\n") [
    # "assets/portal/templates/lesgrandsvoisins/login.template"
    # "assets/images/logo-lesgrandsvoisins-800-400-white.png"
    # ] )
    # ''
    #   echo "${install_commands}" > /tmp/debug
    # ''
  ];
}