{ withSystem, inputs, ... }:
{
  perSystem =
    {
      system,
      self',
      inputs',
      ...
    }:
    let
      override = final: prev: {
        jujutsu = prev.jujutsu.overrideAttrs {
          doCheck = false;
        };
      };
    in
    {
      imports = [ ./scripts ];
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = with inputs; [
          neorg-overlay.overlays.default
          # inputs.mozilla.overlays.firefox
          fenix.overlays.default
          # inputs.rustowl.overlays.default
          rust-overlay.overlays.default
          neovim-nightly.overlays.default
          jujutsu.overlays.default
          environments.overlays.default
          sccache.overlays.default
          override
          (_: _: {
            inherit (self'.packages) sccache_wrapper;
            inherit (inputs'.nvim-fff.packages) fff-nvim;
          })
        ];
        config = {
          allowUnfree = true;
        };
      };
    };
  flake =
    let
      darwinCommon =
        { ... }:
        {
          imports = [
            inputs.nixvim.homeModules.nixvim
            inputs.catppuccin.homeModules.catppuccin
            ./home-manager
            ./home-manager/mac
          ];
        };
    in
    {
      nixosConfigurations.tanjiro = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = with inputs; [
          noctalia.nixosModules.default
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          ./linux
          ./cachix.nix
          ./garnix
          ./common.nix
          home-manager.nixosModules.home-manager
          inputs.catppuccin.nixosModules.default
          {
            home-manager = {
              sharedModules = [
                inputs.sops-nix.homeModules.sops
              ];
              useGlobalPkgs = true;
              useUserPackages = true;
              users.insipx =
                { ... }:
                {
                  imports = [
                    inputs.noctalia.homeModules.default
                    inputs.nixvim.homeModules.nixvim
                    inputs.catppuccin.homeModules.catppuccin
                    inputs.doom-emacs.homeModule
                    ./home-manager
                    ./home-manager/machine-specific/linux
                  ];
                };
              extraSpecialArgs = { inherit inputs; };
            };
          }
          # inputs.nixpkgs.nixosModules.readOnlyPkgs
          (
            { config, ... }:
            {
              # Use the configured pkgs from perSystem
              nixpkgs.pkgs = withSystem config.nixpkgs.hostPlatform.system (
                { pkgs, ... }: # perSystem module arguments
                pkgs
              );
            }
          )
        ];
        specialArgs = {
          inherit inputs;
        };
      };
      nixosConfigurations.arm64Builder = inputs.nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          {
            nixpkgs = {
              config = {
                allowUnfree = true;
              };
            };
          }
          (
            { pkgs, modulesPath, ... }:
            {
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
                experimental-features = [
                  "nix-command"
                  "flakes"
                ];
                trusted-users = [
                  "root"
                  "nixremote"
                  "insipx"
                ];
                system-features = [
                  "nixos-test"
                  "benchmark"
                  "big-parallel"
                  "kvm"
                ];
                substituters = [
                  "https://cache.nixos.org"
                  "https://insipx.cachix.org"
                ];
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

              environment.systemPackages = with pkgs; [
                cachix
                git
                ghostty.terminfo
                htop
              ];
            }
          )
        ];
      };
      darwinConfigurations.cyllene = inputs.nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = with inputs; [
          ./darwin-config.nix
          ./common.nix
          ./determinate.nix
          home-manager.darwinModules.home-manager
          sops-nix.darwinModules.sops
          {
            system.primaryUser = "insipx";
          }
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.insipx = darwinCommon;
              extraSpecialArgs = { inherit inputs; };
            };
          }
          (
            { config, ... }:
            {
              # Use the configured pkgs from perSystem
              nixpkgs.pkgs = withSystem config.nixpkgs.hostPlatform.system (
                { pkgs, ... }: # perSystem module arguments
                pkgs
              );
            }
          )
        ];
        specialArgs = {
          inherit inputs;
        };
      };
      darwinConfigurations.kusanagi = inputs.nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = with inputs; [
          ./darwin-config.nix
          ./common.nix
          home-manager.darwinModules.home-manager
          sops-nix.darwinModules.sops
          {
            system.primaryUser = "andrewplaza";
            nix.settings.trusted-users = [
              "root"
              "andrewplaza"
            ];
          }
          {
            home-manager = {
              sharedModules = [
                inputs.sops-nix.homeManagerModules.sops
              ];
              useGlobalPkgs = true;
              useUserPackages = true;
              users.andrewplaza = darwinCommon;
              extraSpecialArgs = { inherit inputs; };
            };
          }
          (
            { config, ... }:
            {
              # Use the configured pkgs from perSystem
              nixpkgs.pkgs = withSystem config.nixpkgs.hostPlatform.system (
                { pkgs, ... }: # perSystem module arguments
                pkgs
              );
            }
          )
        ];
        specialArgs = {
          inherit inputs;
        };
      };
    };
}
