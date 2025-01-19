# /etc/nixos/flake.nix
{
  inputs = {
    # NOTE: Replace "nixos-23.11" with that which is in system.stateVersion of
    # configuration.nix. You can also use latter versions if you wish to
    # upgrade.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  #    home-manager = {
  #      url = "github:nix-community/home-manager";
  #      inputs.nixpkgs.follows = "nixpkgs";
  #    };
    agenix.url = "github:ryantm/agenix";
  };
  outputs = { self, nixpkgs, home-manager, agenix, ... }@inputs: {
    # NOTE: 'nixos' is the default hostname set by the installer
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      # NOTE: Change this to aarch64-linux if you are on ARM
      system = "x86_64-linux";
      modules = [   
        ./configuration.nix
        agenix.nixosModules.default
      ];
    };
    # homeConfigurations = {
    # #  mannchri = home-manager.lib.homeManagerConfiguration {
    # #    extraSpecialArgs = {inherit nixpkgs;};
    # #    modules = [./home-manager/mannchri.nix];
    # #  };
    # };
  };
}

