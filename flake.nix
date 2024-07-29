{
  description = "Insi Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Other Sources
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  # `...` allows defining additional inputs to the outputs 
  # without changing the fn signature. It makes the flake more flexible.
  outputs = { self, nix-darwin, nixpkgs, home-manager, ... }@inputs:

    let
      inherit (nixpkgs.lib) attrValues makeOverridable optionalAttrs singleton;
      inherit (nix-darwin.lib) darwinSystem;

      # the `self.overlays` in the `nixpkgsConfig`
      nixpkgsConfig = {
        config = { allowUnfree = true; };
        overlays = attrValues self.overlays;
      };

      options = (import ./options.nix { inherit self nixpkgs; });

    in {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#cyllene
      darwinConfigurations."cyllene" = darwinSystem {
        modules = [
          options
          ./configuration.nix
          home-manager.darwinModules.home-manager
          {
            nixpkgs = nixpkgsConfig;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.insipx = import ./home-manager/home.nix;
          }
        ];
      };

      darwinConfigurations."kusanagi" = darwinSystem {
        modules = [
          options
          ./configuration.nix
          home-manager.darwinModules.home-manager
          {
            nixpkgs = nixpkgsConfig;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.andrewplaza = import ./home-manager/home.nix;
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."kusanagi".pkgs;

      overlays = { neovim = inputs.neovim-nightly-overlay.overlays.default; };
    };
}
