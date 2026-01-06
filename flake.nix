{
  description = "Insi Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # nixpkgs.url = "github:NixOS/nixpkgs/68ed3354133f549b9cb8e5231a126625dca4e724";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Other Sources
    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neorg-overlay = {
      url = "github:nvim-neorg/nixpkgs-neorg-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jujutsu = {
      url = "github:jj-vcs/jj/v0.34.0";
      # url = "github:jj-vcs/jj";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
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
    # rustowl = {
    #   url = "github:nix-community/rustowl-flake";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    swww.url = "github:LGFae/swww";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    environments = {
      url = "github:insipx/environments";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-trusted-public-keys = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    extra-substituters = "nix-community.cachix.org";
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
      override = final: prev: {
        jujutsu = prev.jujutsu.overrideAttrs {
          doCheck = false;
        };
      };
      # the `self.overlays` in the `nixpkgsConfig`
      nixpkgsConfig = {
        config = { allowUnfree = true; };
        overlays = [
          inputs.neorg-overlay.overlays.default
          # inputs.mozilla.overlays.firefox
          inputs.fenix.overlays.default
          # inputs.rustowl.overlays.default
          inputs.rust-overlay.overlays.default
          inputs.neovim-nightly.overlays.default
          inputs.jujutsu.overlays.default
          inputs.environments.overlays.default
          override
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
          ./common.nix
          inputs.determinate.nixosModules.default
          home-manager.nixosModules.home-manager
          inputs.catppuccin.nixosModules.default
          {
            nixpkgs = nixpkgsConfig;
            home-manager = {
              sharedModules = [
                inputs.sops-nix.homeManagerModules.sops
              ];
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

      nixosConfigurations.arm64Builder = nixosSystem {
        system = "aarch64-linux";
        modules = [
          {
            nixpkgs = {
              config = { allowUnfree = true; };
            };
          }
          ({ pkgs, modulesPath, ... }: {
            users.users.insipx = {
              isNormalUser = true;
              extraGroups = [ "wheel" ];
              openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUArrr4oix6p/bSjeuXKi2crVzsuSqSYoz//YJMsTlo cardno:14_836_775"
              ];
              packages = with pkgs; [
                tree
              ];
            };
            users.users.nixremote = {
              isNormalUser = true;
              packages = with pkgs; [
                tree
              ];
              openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOIPrcoSB8P1OImd7wxZ7TqW4QQ02JQ4aIhpbtaOmweC root@tanjiro"
              ];
            };
            nix.settings = {
              experimental-features = [ "nix-command" "flakes" ];
              trusted-users = [ "root" "nixremote" "insipx" ];
              system-features = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
              substituters = [ "https://cache.nixos.org" "https://insipx.cachix.org" ];
              trusted-public-keys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                "insipx.cachix.org-1:JMvQq3zItXN5AO7VfPUAILAwMXQrzQ78rLoQTktWs14="
              ];
              post-build-hook = pkgs.writeShellScript "upload-to-cachix" ''
                set -eu
                set -f # disable globbing
                export IFS=' '
                echo "Uploading paths" $OUT_PATHS
                exec ${pkgs.cachix}/bin/cachix push insipx $OUT_PATHS
              '';
            };
            networking.hostName = "nixos-builder-arm64";

            imports = [
              (modulesPath + "/virtualisation/amazon-image.nix")
            ];
            services.openssh = {
              enable = true;
            };
            networking.firewall.allowedTCPPorts = [ 22 ];

            environment.systemPackages = with pkgs; [ cachix git ghostty.terminfo htop ];
          })
        ];
      };

      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#cyllene
      darwinConfigurations."cyllene" = darwinSystem {
        modules = [
          ./darwin-config.nix
          ./common.nix
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
