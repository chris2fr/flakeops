{
  description = "Flake that installs one static image file into the Nix store";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    # system = "x86_64-linux";
    pkgs = import nixpkgs {};
    # pkgs = import nixpkgs {inherit system;};
  in {
    packages."x86_64-linux".default = pkgs.stdenv.mkDerivation {
      pname = "caddy-ui-lesgv";
      version = "1.0.0";

      src = ./.;

      installPhase = pkgs.lib.strings.concatStrings [
        ''
          mkdir -p $out/assets/portal/templates/lesgrandsvoisins
          mkdir -p $out/assets/images
        ''
        (pkgs.lib.strings.concatMapStrings (x: "install -Dm644 ./${x} out/${x}\n") [
          "assets/portal/templates/lesgrandsvoisins/login.template"
          "assets/images/logo-lesgrandsvoisins-800-400-white.png"
        ])
      ];
    };
  };
}
