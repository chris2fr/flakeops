{pkgs ? import <nixpkgs>}:
pkgs.stdenv.mkDerivation {
  pname = "roundcube-ui-gv";
  version = "1.0.0";
  src = ./.;
  nativeBuildInputs = [];
  installPhase = pkgs.lib.strings.concatStrings [
    ''
      mkdir -p $out/plugins/roundcube-ui-gv
      cp -a $src/floating_button.php $out/plugins/roundcube-ui-gv/floating_button.php
    ''
  ];
}
