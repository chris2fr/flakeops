{pkgs ? import <nixpkgs>}:
pkgs.stdenv.mkDerivation {
  pname = "roundcube-ui-gv";
  version = "1.0.0";
  src = ./.;
  nativeBuildInputs = [];
  installPhase = pkgs.lib.strings.concatStrings [
    ''
      mkdir -p $out/plugins/${name}
      cp -a $src/floating_button.php $out/plugins/${name}/floating_button.php
      mkdir -p /var/lib/roundcube/plugins
      ln -s $out/plugins/${name} /var/lib/roundcube/plugins/${name}
    ''
  ];
}
