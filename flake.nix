# /etc/nixos/flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    caddy-ui-lesgv.url = "path:./flakes/caddy-ui";
    agenix.url = "github:ryantm/agenix";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    agenix,
    caddy-ui-lesgv,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        vars = import ./vars.nix;
      in {
      }
    )
    // {
      # NOTE: 'nixos' is the default hostname set by the installer
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          # NOTE: Change this to aarch64-linux if you are on ARM
          # system = "x86_64-linux";
          modules = [
            ./configuration.nix
            agenix.nixosModules.default
          ];
          # vars = import ./vars.nix;
          specialArgs = {inherit caddy-ui-lesgv;};
        };
      };
    };
}
