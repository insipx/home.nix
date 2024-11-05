{ pkgs, config, ... }: {

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [ pkgs.vim ];

  nix = {
    package = pkgs.nix;
    settings.experimental-features = "nix-command flakes";
    settings.trusted-users = [ "root" "insipx" "andrewplaza" ];
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
      allowBroken = true;
    };
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # https://daiderd.com/nix-darwin/manual/index.html
  homebrew = {
    enable = true;
    brews = [
      "gnu-sed"
      "gnupg"
      "gpgme"
      "yubikey-personalization"
      "hopenpgp-tools"
      "ykman"
      "pinentry-mac"
      "cxreiff/tap/ttysvr"
    ];
    casks = [ "docker" ];
  };

  # services.yabai = {
  #   enable = true;
  #   package = pkgs.yabai;
  #   # Requires SIP (Security Integrity Protection) to be disabled.
  #   enableScriptingAddition = false;
  #   config = {
  #     top_padding = 20;
  #     bottom_padding = 20;
  #     left_padding = 20;
  #     right_padding = 20;
  #     window_gap = 20;
  #   };
  #   # extraConfig = "";
  # };

  # services.sketchybar = { enable = true; };

  # services.skhd = {
  #  enable = true;
  # };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

}
