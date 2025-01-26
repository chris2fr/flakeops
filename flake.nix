# /etc/nixos/flake.nix
{
  inputs = {
    # NOTE: Replace "nixos-23.11" with that which is in system.stateVersion of
    # configuration.nix. You can also use latter versions if you wish to
    # upgrade.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.11";  
  };
  outputs = { self, nixpkgs, home-manager, agenix, simple-nixos-mailserver, ... }@inputs: {
    # NOTE: 'nixos' is the default hostname set by the installer
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      # NOTE: Change this to aarch64-linux if you are on ARM
      system = "x86_64-linux";
      modules = [   
        ./configuration.nix
        agenix.nixosModules.default
        simple-nixos-mailserver.nixosModule
        home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mannchri = import ./home-mannchri.nix;
            home-manager.users.fossil = import ./home-fossil.nix;
            home-manager.users.filebrowser = import ./home-filebrowser.nix;
            home-manager.users.guichet = import ./home-guichet.nix;
          }
      ];
    };
    # homeConfigurations = {
    #   fossil = home-manager.lib.homeManagerConfiguration {
    #     extraSpecialArgs = {inherit nixpkgs;};
    #     modules = [./home-manager/fossil.nix];
    #   };
    #   wagtail = home-manager.lib.homeManagerConfiguration {
    #     extraSpecialArgs = {inherit nixpkgs;};
    #     modules = [./home-manager/wagtail.nix];
    #   };
    #   mannchri = home-manager.lib.homeManagerConfiguration {
    #     extraSpecialArgs = {inherit nixpkgs;};
    #     modules = [./home-manager/mannchri.nix];
    #   };
    # };
  };
}