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

    neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # `...` allows defining additional inputs to the outputs 
  # without changing the fn signature. It makes the flake more flexible.
  outputs = { self, nix-darwin, nixpkgs, home-manager, nixvim, neorg-overlay, ... }@inputs:

    let
      inherit (nixpkgs.lib) attrValues makeOverridable optionalAttrs singleton;
      inherit (nix-darwin.lib) darwinSystem;

      # the `self.overlays` in the `nixpkgsConfig`
      nixpkgsConfig = {
        config = { allowUnfree = true; };
        overlays = attrValues self.overlays ++ [ neorg-overlay.overlays.default ];
      };

      options = (import ./options.nix { inherit self nixpkgs; });

    in {
      overlays = { neovim = inputs.neovim-nightly-overlay.overlays.default; };

      # Expose the package set, including verlays, for convenience.
      darwinPackages = self.darwinConfigurations."kusanagi".pkgs;

      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#cyllene
      darwinConfigurations."cyllene" = darwinSystem {
        modules = [
          options
          ./configuration.nix
          home-manager.darwinModules.home-manager
          # nixvimpkg.homeManagerModules.nixvim
          {
            nixpkgs = nixpkgsConfig;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.insipx = import ./home-manager/home.nix;
            home-manager.extraSpecialArgs = { inherit nixvim; };
          }
        ];
      };

      darwinConfigurations."kusanagi" = darwinSystem {
        modules = [
          options
          ./configuration.nix
          home-manager.darwinModules.home-manager
          # nixvimpkg.homeManagerModules.nixvim
          {
            nixpkgs = nixpkgsConfig;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.andrewplaza = import ./home-manager/home.nix;
          }
        ];
      };
    };
}
