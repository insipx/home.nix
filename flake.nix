{
  description = "Insi Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Other Sources
    # neovim-nightly.url = "github:nix-community/neovim-nightly-overlay?rev=1b313b2d3fafd50aaf06733cc8753660068ec19b";
    ghostty.url = "github:ghostty-org/ghostty";

    neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";
    neorg-overlay.inputs.nixpkgs.follows = "nixpkgs";

    nixvim = {
      url = "github:nix-community/nixvim";
    };
    # nixgl.url = "github:nix-community/nixGL";
    mozilla.url = "github:mozilla/nixpkgs-mozilla";
    swww.url = "github:LGFae/swww";
    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";
    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    nix-gl-host.url = "github:numtide/nix-gl-host";
    sops-nix.url = "github:Mic92/sops-nix";
    # tidal.url = "github:mitchmindtree/tidalcycles.nix";
    # hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    # where {version} is the hyprland release version
    # or "github:hyprwm/Hyprland?submodules=1" to follow the development branch

    #hy3 = {
    #  url = "github:outfoxxed/hy3?ref=hl{version}"; # where {version} is the hyprland release version
    #  # or "github:outfoxxed/hy3" to follow the development branch.
    #  # (you may encounter issues if you dont do the same for hyprland)
    #  inputs.hyprland.follows = "hyprland";
    #};
  };

  # `...` allows defining additional inputs to the outputs
  # without changing the fn signature. It makes the flake more flexible.
  outputs =
    { self
    , nix-darwin
    , nixpkgs
    , home-manager
    , nixvim
    , swww
    , ghostty
    , catppuccin
    , sops-nix
      # , hy3
    , ...
    }@inputs:

    let
      inherit (nixpkgs.lib) attrValues;
      inherit (nix-darwin.lib) darwinSystem;

      darwinCommon = { ... }: {
        imports = [
          nixvim.homeManagerModules.nixvim
          catppuccin.homeModules.catppuccin
          ./home-manager/home.nix
          ./home-manager/mac.nix
        ];
      };
      # the `self.overlays` in the `nixpkgsConfig`
      nixpkgsConfig = {
        config = { allowUnfree = true; };
        overlays = attrValues self.overlays ++ [
          # neorg-overlay.overlays.default
          # inputs.mozilla.overlays.firefox
          inputs.fenix.overlays.default
        ]; # adds all overlays to list
      };

    in
    {
      overlays = {
        # neovim = inputs.neovim-nightly.overlays.default;
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."kusanagi".pkgs;


      homeConfigurations."tanjiro" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs ({
          system = "x86_64-linux";
          overlays = nixpkgsConfig.overlays ++ [ ghostty.overlays.default ];
        } // nixpkgsConfig);
        modules = [
          ./home-manager/home.nix
          ./linux-config.nix
          nixvim.homeManagerModules.nixvim
          catppuccin.homeModules.catppuccin
          sops-nix.homeManagerModules.sops
          # inputs.hyprland.homeManagerModules.default
          {
            home = {
              username = "insipx";
              homeDirectory = "/home/insipx";
            };
          }
        ];
        extraSpecialArgs = { inherit nixvim catppuccin swww; nix-gl-host = inputs.nix-gl-host.defaultPackage.x86_64-linux; };
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
            system.primaryUser = "insipx";
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
