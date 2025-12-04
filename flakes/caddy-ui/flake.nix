{
  description = "Flake that installs one static image file into the Nix store";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    packages.${system}.default = pkgs.stdenv.mkDerivation {
      pname = "caddy-ui-lesgv";
      version = "1.0.0";

      # The file you want to copy
      # e.g. ./my-image.png should exist next to this flake.nix
      src = ./.;
      # srcs = {
      #   assets = ./assets;
      # };

      # install_string = pkgs.lib.strings.concatMapStrings (x: "install -Dm644 ./${x} out/${x}\n") [
      #   "assets/portal/templates/lesgrandsvoisins/login.template"
      #   "assets/images/logo-lesgrandsvoisins-800-400-white.png"
      # ] ;
      # .map(x: "install -Dm644 ./${x} out/${x}")

      installPhase = pkgs.lib.strings.concatStrings [
        ''
        mkdir -p $out/assets/portal/templates/lesgrandsvoisins
        mkdir -p $out/assets/images
        ''
        (pkgs.lib.strings.concatMapStrings (x: "install -Dm644 ./${x} out/${x}\n") [
        "assets/portal/templates/lesgrandsvoisins/login.template"
        "assets/images/logo-lesgrandsvoisins-800-400-white.png"
        ] )
      ];
      #   install install -Dm644 ./assets/portal/templates/lesgrandsvoisins/login.template out/assets/portal/templates/lesgrandsvoisins/login.template
      #   install install -Dm644 ./assets/images/logo-lesgrandsvoisins-800-400-white.png out/assets/images/logo-lesgrandsvoisins-800-400-white.png
      # '';
    };
  };
}
