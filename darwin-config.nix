{ pkgs, config, ... }: {

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [ pkgs.vim ];
  ids.gids.nixbld = 350;

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [ "root" "insipx" "andrewplaza" ];
      sandbox = false;
    };
  };


  # Set Git commit hash for darwin-version.
  system.configurationRevision = config.system.flakeRevision;

  programs.zsh.enable = true; # default shell on catalina
  programs.fish.enable = true;

  users.users.insipx = {
    home = "/Users/insipx";
    shell = pkgs.fish;
  };

  users.users.andrewplaza = {
    home = "/Users/andrewplaza";
    shell = pkgs.fish;
  };

  # The platform the configuration will be used on.
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config = {
      allowUnfree = true;
      allowBroken = false;
    };
  };

  # https://daiderd.com/nix-darwin/manual/index.html
  homebrew = {
    enable = true;
    brews = [
      "neovide"
      "gnu-sed"
      "gnupg"
      "gpgme"
      "yubikey-personalization"
      "hopenpgp-tools"
      "ykman"
      "pinentry"
      # "cxreiff/tap/ttysvr"
    ];
    casks = [ "docker" "firefox@nightly" "ghostty" "raycast" ];
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
    };
  };

  services.aerospace = {
    enable = false;
    settings = {
      gaps = {
        outer = {
          left = 8;
          bottom = 8;
          top = 8;
          right = 8;
        };
        inner = {
          horizontal = 4;
          vertical = 4;
        };
      };
      mode.main.binding = {
        alt-slash = "layout tiles horizontal vertical";
        alt-comma = "layout accordion horizontal vertical";

        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";
        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";
        alt-shift-minus = "resize smart -50";
        alt-shift-equal = "resize smart +50";

        # Workspaces
        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";

        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";
        alt-shift-6 = "move-node-to-workspace 6";
        alt-shift-7 = "move-node-to-workspace 7";
        alt-shift-8 = "move-node-to-workspace 8";
        alt-shift-9 = "move-node-to-workspace 9";

        alt-tab = "workspace-back-and-forth";

        alt-shift-semicolon = "mode service";
      };
      mode.service.binding = {
        r = [ "flatten-workspace-tree" "mode main" ]; # reset layout
        f = [ "layout floating tiling" "mode main" ]; # Toggle between floating and tiling layout
        backspace = [ "close-all-windows-but-current" "mode main" ];

        alt-shift-h = [ "join-with left" "mode main" ];
        alt-shift-j = [ "join-with down" "mode main" ];
        alt-shift-k = [ "join-with up" "mode main" ];
        alt-shift-l = [ "join-with right" "mode main" ];
      };
    };
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

}
