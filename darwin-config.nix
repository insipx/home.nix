{ pkgs, config, ... }: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [ pkgs.vim ];
  ids.gids.nixbld = 350;

  sops = {
    age = {
      # keyFile = "${config.system.primaryUserHome}/.config/sops/age/keys.txt"; # For age keys
      generateKey = false;
      sshKeyPaths = [ ];
    };
    # secrets.anthropic_key = {
    #   group = "staff";
    #   owner = "${config.system.primaryUser}";
    #   mode = "0400"; # Read-only by owner
    # };
    # secrets.cachix_auth_token = {
    #   group = "staff";
    #   owner = "${config.system.primaryUser}";
    #   mode = "0400"; # Read-only by owner
    # };
    # defaultSopsFile = ./secrets/env.yaml;
    # gnupg.sshKeyPaths = [ ];
    # gnupg.home = "${config.system.primaryUserHome}/.gnupg";
  };
  # Add nix settings to seperate conf file
  # since we use Determinate Nix on our systems.
  #environment = {
  #  etc."nix/nix.custom.conf".text = pkgs.lib.mkForce ''
  #    # Add nix settings to seperate conf file
  #    # since we use Determinate Nix on our systems.
  #    trusted-users = insipx andrewplaza
  #    extra-substituters = https://cache.nixos.org https://xmtp.cachix.org
  #    extra-trusted-public-keys = nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= xmtp.cachix.org-1:nFPFrqLQ9kjYQKiWL7gKq6llcNEeaV4iI+Ka1F+Tmq0= xmtp.cachix.org-1:nFPFrqLQ9kjYQKiWL7gKq6llcNEeaV4iI+Ka1F+Tmq0=
  #  '';
  #};

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
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config = {
      allowUnfree = true;
      allowBroken = false;
      allowUnsupportedSystem = true;
    };
  };

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
    casks = [ "firefox@nightly" "raycast" "orbstack" "claude" "claude-code" ];
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
    };
  };
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

}
