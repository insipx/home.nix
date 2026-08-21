{ withSystem, inputs, ... }:
{
  perSystem =
    {
      system,
      inputs',
      ...
    }:
    let
      override = final: prev: {
        jujutsu = prev.jujutsu.overrideAttrs {
          doCheck = false;
        };
        # moonlight-qt 6.1.0 — still the latest release, from Sept 2024 —
        # predates FFmpeg 9.0 removing AVVulkanDeviceContext's
        # queue_family_decode_index and nb_decode_queues, which plvk.cpp uses.
        # Upstream master guards them behind
        # LIBAVUTIL_VERSION_INT < AV_VERSION_INT(60, 26, 100) but has not cut a
        # release since, so pin the last ffmpeg that still has the fields.
        # Same breakage as FreeBSD ports bug 297357. Drop once a release lands.
        moonlight-qt = prev.moonlight-qt.override { ffmpeg = prev.ffmpeg_8; };
        # Hyprland's CMake wants `find_package(glaze 7...<8)`, but the flake's
        # glaze-hyprland is just nixpkgs' glaze with SSL/interop disabled, and
        # nixpkgs has moved to 8.0.0. The version range rejects it, CMake falls
        # back to a FetchContent git clone, and the sandbox has no network — so
        # the build dies with "could not find git for clone of glaze". Pin the
        # last 7.x here, keeping the flake's own override (hence overrideAttrs
        # on glaze-hyprland rather than rebuilding it from prev.glaze).
        # Hyprland is called with final.callPackage, so this reaches it.
        # Drop once upstream pins glaze itself.
        glaze-hyprland = prev.glaze-hyprland.overrideAttrs (_: rec {
          version = "7.2.0";
          src = prev.fetchFromGitHub {
            owner = "stephenberry";
            repo = "glaze";
            rev = "v${version}";
            hash = "sha256-f3NVRi3SXKo42hn0WCw7JsOK3EkdOVJIcuzhPorKjFY=";
          };
        });
        # hyprland-guiutils comes from the Hyprland flake's hyprland-extras
        # overlay and builds with the plain stdenv (gcc 15 here), but its
        # hyprtoolkit dependency is not supplied by that flake — it resolves to
        # nixpkgs, which builds it with gcc16Stdenv on purpose. Linking then
        # fails on the C++23 std::format symbols hyprtoolkit references
        # (_M_handle_unrecognized@GLIBCXX_3.4.36 is absent from gcc 15's
        # libstdc++). Borrow hyprtoolkit's own stdenv rather than naming a gcc
        # version, so the two cannot drift apart again.
        hyprland-guiutils = prev.hyprland-guiutils.override {
          inherit (prev.hyprtoolkit) stdenv;
        };
        inherit (inputs'.hy3.packages) hy3;
        inherit (inputs'.claude-chill.packages) claude-chill;
        inherit (inputs'.jayjay.packages) jayjay-gpui;
      };
    in
    {
      imports = [ ./scripts ];
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = with inputs; [
          shadow-nvim.overlays.default
          # inputs.mozilla.overlays.firefox
          fenix.overlays.default
          # inputs.rustowl.overlays.default
          inputs.hyprland.overlays.hyprland-packages
          inputs.hyprland.overlays.hyprland-extras
          rust-overlay.overlays.default
          jujutsu.overlays.default
          environments.overlays.default
          sccache.overlays.default
          unfree.overlays.default
          llm-agents.overlays.shared-nixpkgs
          mcp-servers.overlays.default
          override
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
            inputs.catppuccin.homeModules.catppuccin
            # inputs.doom-emacs.homeModule
            ./home-manager
            ./home-manager/machine-specific/mac
          ];
        };
    in
    {
      nixosConfigurations.tanjiro = inputs.nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = with inputs; [
          inputs.lanzaboote.nixosModules.lanzaboote
          disko.nixosModules.disko
          # common.nix both defines sops.secrets and reads
          # config.sops.secrets.nixGithubNetrc.path, so the NixOS sops module
          # has to be here. It used to arrive transitively via jupiter-secrets;
          # the darwin hosts import darwinModules.sops directly for the same
          # reason.
          sops-nix.nixosModules.sops
          ./linux
          ./cachix.nix
          ./common.nix
          home-manager.nixosModules.home-manager
          inputs.catppuccin.nixosModules.default
          inputs.shadow-nvim.nixosModules.default
          {
            programs.hyprland.portalPackage = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
            home-manager = {
              sharedModules = [
                inputs.sops-nix.homeModules.sops
              ];
              useGlobalPkgs = true;
              useUserPackages = true;
              # first firefox activation clobbers the imperative profiles.ini;
              # back up instead of failing
              backupFileExtension = "backup";
              users.insipx =
                { ... }:
                {
                  imports = [
                    inputs.noctalia.homeModules.default
                    inputs.catppuccin.homeModules.catppuccin
                    inputs.hyprland.homeManagerModules.default
                    inputs.textfox.homeManagerModules.default
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
          ./cachix.nix
          home-manager.darwinModules.home-manager
          sops-nix.darwinModules.sops
          shadow-nvim.darwinModules.shadow-nvim
          inputs.determinate.darwinModules.default
          (
            { config, ... }:
            {
              system.primaryUser = "insipx";
              determinateNix = {
                enable = true;
                customSettings = {
                  trusted-users = [
                    "root"
                    "insipx"
                    "nixbuilder"
                  ];
                  sandbox = "relaxed";
                  # sandbox = true;
                  extra-experimental-features = "external-builders ca-derivations";
                  # xcframework drvs bind Xcode first-launch content via
                  # __impureHostDeps
                  allowed-impure-host-deps = "/bin/sh /dev /usr/lib /System/Library /Library/Developer/PrivateFrameworks";
                };
                # Determinate ignores nix.settings.netrc-file (nix.enable = false),
                # so add our github netrc on top of Determinate's own FlakeHub netrc.
                determinateNixd.authentication.additionalNetrcSources = [
                  config.sops.secrets.nixGithubNetrc.path
                ];
              };
            }
          )
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
          ./cachix.nix
          home-manager.darwinModules.home-manager
          sops-nix.darwinModules.sops
          shadow-nvim.darwinModules.shadow-nvim
          {
            system.primaryUser = "andrewplaza";
            nix.settings.trusted-users = [
              "root"
              "andrewplaza"
              "nixbuilder"
            ];
            # programs.shadow-nvim.enable = true;
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
