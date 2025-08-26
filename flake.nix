{
  description = "Insi Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Other Sources
    # neovim-nightly.url = "github:nix-community/neovim-nightly-overlay?rev=1b313b2d3fafd50aaf06733cc8753660068ec19b";
    ghostty.url = "github:ghostty-org/ghostty";
    ghostty.inputs.nixpkgs.follows = "nixpkgs";

    neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";
    neorg-overlay.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    # nixgl.url = "github:nix-community/nixGL";
    # mozilla.url = "github:mozilla/nixpkgs-mozilla";
    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";
    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    # tidal.url = "github:mitchmindtree/tidalcycles.nix";
    rustowl = {
      url = "github:nix-community/rustowl-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    swww.url = "github:LGFae/swww";
  };

  # `...` allows defining additional inputs to the outputs
  # without changing the fn signature. It makes the flake more flexible.
  outputs =
    { self
    , disko
    , nix-darwin
    , nixpkgs
    , home-manager
    , sops-nix
    , ...
    }@inputs:

    let
      inherit (nixpkgs.lib) attrValues nixosSystem;
      inherit (nix-darwin.lib) darwinSystem;

      darwinCommon = { ... }: {
        imports = [
          inputs.nixvim.homeManagerModules.nixvim
          inputs.catppuccin.homeModules.catppuccin
          ./home-manager/home.nix
          ./home-manager/mac.nix
        ];
        extraSpecialArgs = { inherit inputs; };
      };
      # the `self.overlays` in the `nixpkgsConfig`
      nixpkgsConfig = {
        config = { allowUnfree = true; };
        overlays = [
          # neorg-overlay.overlays.default
          # inputs.mozilla.overlays.firefox
          inputs.fenix.overlays.default
          inputs.rustowl.overlays.default
          inputs.rust-overlay.overlays.default
        ];
      };

    in
    {
      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."kusanagi".pkgs;

      nixosConfigurations.tanjiro = nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          ./linux/configuration.nix
          home-manager.nixosModules.home-manager
          {
            nixpkgs = nixpkgsConfig;
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.insipx = { ... }: {
                imports = [
                  inputs.nixvim.homeManagerModules.nixvim
                  inputs.catppuccin.homeModules.catppuccin
                  ./home-manager/home.nix
                  ./linux
                ];
              };
              extraSpecialArgs = { inherit inputs; };
            };
          }
        ];
        specialArgs = {
          inherit inputs;
        };
      };

      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#cyllene
      darwinConfigurations."cyllene" = darwinSystem {
        modules = [
          ./options.nix
          ./darwin-config.nix
          home-manager.darwinModules.home-manager
          sops-nix.darwinModules.sops
          {
            system. primaryUser = "insipx";
          }
          {
            nixpkgs = nixpkgsConfig;
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.insipx = darwinCommon;
            };
          }
        ];
      };

      darwinConfigurations."kusanagi" = darwinSystem {
        modules = [
          ./options.nix
          ./darwin-config.nix
          home-manager.darwinModules.home-manager
          {
            system.primaryUser = "andrewplaza";
          }
          {
            nixpkgs = nixpkgsConfig;
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.andrewplaza = darwinCommon;
            };
          }
        ];
      };
    };
}
