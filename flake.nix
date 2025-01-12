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
    ghostty.url = "github:ghostty-org/ghostty";
    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay?rev=d3963249e534e247041862b8162fb738c8604d3a";

    neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mozilla.url = "github:mozilla/nixpkgs-mozilla";
    catppuccin.url = "github:catppuccin/nix";
  };

  # `...` allows defining additional inputs to the outputs
  # without changing the fn signature. It makes the flake more flexible.
  outputs =
    { self
    , nix-darwin
    , nixpkgs
    , home-manager
    , nixvim
    , mozilla
    , ghostty
    , catppuccin
    , ...
    }@inputs:

    let
      inherit (nixpkgs.lib) attrValues mkMerge;
      inherit (nix-darwin.lib) darwinSystem;

      # the `self.overlays` in the `nixpkgsConfig`
      nixpkgsConfig = {
        config = { allowUnfree = true; };
        overlays = attrValues self.overlays ++ [
          # neorg-overlay.overlays.default
          mozilla.overlays.firefox
        ]; # adds all overlays to list
      };

      options = import ./options.nix { inherit self nixpkgs; };
    in
    {
      overlays = {
        neovim = inputs.neovim-nightly-overlay.overlays.default;
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."kusanagi".pkgs;


      homeConfigurations."tanjiro" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs ({
          system = "x86_64-linux";
          overlays = nixpkgsConfig.overlays ++ [ ghostty.overlays.default ]; # ghostty packaged for linux
        } // nixpkgsConfig);
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
        extraSpecialArgs = { inherit nixvim catppuccin; };
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
              users.insipx = mkMerge [ (import ./home-manager/home.nix) (import ./home-manager/mac.nix) ];
              extraSpecialArgs = { inherit nixvim catppuccin; };
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
              users.andrewplaza = mkMerge [ (import ./home-manager/home.nix) (import ./home-manager/mac.nix) ];
              extraSpecialArgs = { inherit nixvim catppuccin; };
            };
          }
        ];
      };
    };
}
