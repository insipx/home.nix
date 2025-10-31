{
  description = "Insi Darwin system flake";

  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/68ed3354133f549b9cb8e5231a126625dca4e724";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Other Sources
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neorg-overlay = {
      url = "github:nvim-neorg/nixpkgs-neorg-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jujutsu = {
      url = "github:jj-vcs/jj";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    # tidal.url = "github:mitchmindtree/tidalcycles.nix";
    rustowl = {
      url = "github:nix-community/rustowl-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    swww.url = "github:LGFae/swww";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
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
      inherit (nixpkgs.lib) nixosSystem;
      inherit (nix-darwin.lib) darwinSystem;

      darwinCommon = { ... }: {
        imports = [
          inputs.nixvim.homeModules.nixvim
          inputs.catppuccin.homeModules.catppuccin
          ./home-manager/home.nix
          ./home-manager/mac.nix
        ];
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
          inputs.neovim-nightly.overlays.default
          inputs.jujutsu.overlays.default
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
          inputs.determinate.nixosModules.default
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
          ./darwin-config.nix
          home-manager.darwinModules.home-manager
          sops-nix.darwinModules.sops
          {
            system.primaryUser = "insipx";
          }
          {
            nixpkgs = nixpkgsConfig;
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.insipx = darwinCommon;
              extraSpecialArgs = { inherit inputs; };
            };
          }
        ];
        specialArgs = {
          inherit inputs;
        };
      };

      darwinConfigurations."kusanagi" = darwinSystem {
        modules = [
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
              extraSpecialArgs = { inherit inputs; };
            };
          }
        ];
      };
    };
}
