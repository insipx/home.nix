{ pkgs, ... }:
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [ pkgs.vim ];
  ids.gids.nixbld = 350;
  sops = {
    age = {
      # keyFile = "${config.system.primaryUserHome}/.config/sops/age/keys.txt"; # For age keys
      generateKey = false;
    };
  };

  # Set Git commit hash for darwin-version.
  # system.configurationRevision = config.system.flakeRevision;

  programs.zsh.enable = true; # default shell on catalina
  programs.fish = {
    enable = true;
    #interactiveShellInit = ''
    #  # set -x ANTHROPIC_API_KEY (cat ${config.sops.secrets.anthropic_key.path})
    #'';
  };

  users.users.insipx = {
    home = "/Users/insipx";
    shell = pkgs.fish;
  };

  users.users.andrewplaza = {
    home = "/Users/andrewplaza";
    shell = pkgs.fish;
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

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
      "pinentry"
      "pinentry-mac"
      # "cxreiff/tap/ttysvr"
    ];
    casks = [
      "firefox@nightly"
      "raycast"
      "orbstack"
      "claude"
      "claude-code"
      "visual-studio-code"
    ];
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
    };
  };
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

}
