{ pkgs, config, ... }: {
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
  system.configurationRevision = config.system.flakeRevision;

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
}

