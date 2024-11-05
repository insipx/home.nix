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
    # nixgl.url = "github:nix-community/nixGL";
    mozilla.url = "github:mozilla/nixpkgs-mozilla";
  };

  # `...` allows defining additional inputs to the outputs
  # without changing the fn signature. It makes the flake more flexible.
  outputs =
    { self
    , nix-darwin
    , nixpkgs
    , home-manager
    , nixvim
    , neorg-overlay
    , mozilla
      # , nixgl
    , ...
    }@inputs:

    let
      inherit (nixpkgs.lib) attrValues;
      inherit (nix-darwin.lib) darwinSystem;

      # the `self.overlays` in the `nixpkgsConfig`
      nixpkgsConfig = {
        config = { allowUnfree = true; };
        overlays = attrValues self.overlays ++ [
          neorg-overlay.overlays.default
          mozilla.overlays.firefox
        ]; # adds all overlays to list
      };

      options = import ./options.nix { inherit self nixpkgs; };
    in
    {
      overlays = { neovim = inputs.neovim-nightly-overlay.overlays.default; };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."kusanagi".pkgs;


      homeConfigurations."tanjiro" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit (nixpkgsConfig) config;
          system = "x86_64-linux";
          inherit (nixpkgsConfig) overlays; # ++ [ nixgl.overlay ];
        };
        modules = [
          ./home-manager/home.nix
          ./linux-config.nix
          {
            home = {
              username = "insipx";
              homeDirectory = "/home/insipx";
            };
          }
        ];
        extraSpecialArgs = { inherit nixvim; };
      };

      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#cyllene
      darwinConfigurations."cyllene" = darwinSystem {
        modules = [
          options
          ./darwin-config.nix
          home-manager.darwinModules.home-manager
          {
            nixpkgs = nixpkgsConfig;
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.insipx = import ./home-manager/home.nix;
              extraSpecialArgs = { inherit nixvim; };
            };
          }
        ];
      };

      darwinConfigurations."kusanagi" = darwinSystem {
        modules = [
          options
          ./darwin-config.nix
          home-manager.darwinModules.home-manager
          {
            nixpkgs = nixpkgsConfig;
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.andrewplaza = import ./home-manager/home.nix;
              extraSpecialArgs = { inherit nixvim; };
            };
          }
        ];
      };
    };
}
