{
  description = "Custom Caddy build using xcaddy with static assets";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    packages.${system}.default = pkgs.stdenv.mkDerivation {
      pname = "custom-caddy";
      version = "1.0.0";

      # Your static files—this can point to any directory in your repo
      # For example: ./static/index.html, ./static/img/foo.png, etc.
      src = ./.;

      # xcaddy is used as the builder
      buildInputs = [
        pkgs.xcaddy
        pkgs.caddy
        pkgs.go
      ];

      # Where to place static files inside output
      staticFiles = pkgs.linkFarm "static-files" {
        "assets/portal/templates/lesgrandsvoisins/login.template" =  "./assets/portal/templates/lesgrandsvoisins/login.template";
        "assets/images/logo-lesgrandsvoisins-800-400-white.png"  = "./assets/images/logo-lesgrandsvoisins-800-400-white.png";
      };

      buildPhase = ''
        mkdir -p build
        cd build

        # Example: build Caddy with plugins
        xcaddy build \
          --with github.com/greenpau/caddy-security
      '';

      installPhase = ''
        mkdir -p $out/bin
        install -Dm755 build/caddy $out/bin/caddy

        mkdir -p $out/share/assets/portal/templates/lesgrandsvoisins
        mkdir -p $out/share/assets/images
        cp -r ${self.packages.${system}.default.staticFiles}/* $out/share/
      '';

      # (Optional) Expose assets as separate output paths
      outputs = [ "out" ];
    };
  };
}
