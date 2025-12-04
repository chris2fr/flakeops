# /etc/nixos/flake.nix
{
  inputs = {
    # NOTE: Replace "nixos-23.11" with that which is in system.stateVersion of
    # configuration.nix. You can also use latter versions if you wish to
    # upgrade.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    filestash.url = "github:dermetfan/filestash.nix";
    caddy-ui-lesgv.url = "path:./flakes/caddy-ui";
  # caddy-ui-lesgv.inputs.nixpkgs.follows = "nixpkgs";
    # copyparty.url = "github:9001/copyparty";
  #    home-manager = {
  #      url = "github:nix-community/home-manager";
  #      inputs.nixpkgs.follows = "nixpkgs";
  #    };
    agenix.url = "github:ryantm/agenix";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, filestash, agenix, caddy-ui-lesgv, ... }@inputs: 
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        # packages = {
        #   mod_auth_openidc = pkgs.callPackage ./derivations/mod_auth_openidc-binary.nix {};
        # };
      }
    ) // {
      # NOTE: 'nixos' is the default hostname set by the installer
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          # NOTE: Change this to aarch64-linux if you are on ARM
          system = "x86_64-linux";
          modules = [   
            ./configuration.nix
            # ({ pkgs, ... }: {
            #   nixpkgs.overlays = [
            #     (final: prev: {
            #       mod_auth_openidc = self.packages.${prev.system}.mod_auth_openidc;
            #     })
            #   ];
            # })
            agenix.nixosModules.default
            filestash.nixosModules.default
          ];
          specialArgs = { inherit filestash; };
        };
      };
      # homeConfigurations = {
      # #  mannchri = home-manager.lib.homeManagerConfiguration {
      # #    extraSpecialArgs = {inherit nixpkgs;};
      # #    modules = [./home-manager/mannchri.nix];
      # #  };
      # };
    };
}
