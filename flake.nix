{
  description = "Insi Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
    let
      configuration = { pkgs, config, ... }: {
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages = [ pkgs.vim ];
        environment.variables = { MACHINE = "macbook"; };

        users.users.insipx = {
          home = "/Users/insipx";
          shell = pkgs.fish;
        };

        users.users.andrewplaza = {
          home = "/Users/andrewplaza";
          shell = pkgs.fish;
        };

        # Auto upgrade nix package and the daemon service.
        services.nix-daemon.enable = true;
        # nix.package = pkgs.nix;

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";
        nix.settings.trusted-users = [ "root" "insipx" "andrewplaza" ];

        # Create /etc/zshrc that loads the nix-darwin environment.
        programs.zsh.enable = true; # default shell on catalina
        programs.fish.enable = true;

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 4;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";
        nixpkgs.config.allowUnfree = true;

        homebrew = {
          enable = true;
          brews = [
            "gnu-sed"
            "gnupg"
            "yubikey-personalization"
            "hopenpgp-tools"
            "ykman"
            "pinentry-mac"
            "swiftformat"
          ];
          casks = [ "docker" ];
        };
        # launchd.user.agents = {
        #   "lorri" = {
        #     serviceConfig = {
        #       WorkingDirectory = config.users.users.insipx.home;
        #       EnvironmentVariables = { };
        #       KeepAlive = true;
        #       RunAtLoad = true;
        #       StandardOutPath = "/var/tmp/lorri.log";
        #       StandardErrorPath = "/var/tmp/lorri.log";
        #     };
        #     script = ''
        #       source ${config.system.build.setEnvironment}
        #       exec ${pkgs.lorri}/bin/lorri daemon
        #     '';
        #   };
        # };
      };
    in {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#cyllene
      darwinConfigurations."cyllene" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.insipx = import ./home-manager/home.nix;
          }
        ];
      };

      darwinConfigurations."kusanagi" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.andrewplaza = import ./home-manager/home.nix;
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."cyllene".pkgs;
    };
}
