{ pkgs, ... }: {
  inherit (pkgs) lib;
  imports = [
    ./neovim-configuration
    ./ghostty.nix
    ./jujutsu.nix
    ./git.nix
    ./fish.nix
    #   (import privateConfiguration)
  ];
  catppuccin.enable = true;
  catppuccin.mako.enable = false;
  home = {
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "23.05"; # Please read the comment before changing.
    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages =
      with pkgs;
      [
        # Fonts, Github's Font, minecraft font, minecraft font vectorized
        nerd-fonts.symbols-only
        # berkeley-mono

        ripgrep
        grc # Colorizer
        du-dust # replacement for du
        fd # find
        macchina
        glow
        git
        tokei
        erdtree
        # ncdu
        htop
        xq # Json format
        duf # alternative to df, filesystem free space viewer
        websocat # Query websockets
        wget
        spotifyd
        fzf

        # Nix & General linting applicable to p. much everything related
        deadnix
        nixfmt
        statix
        # Git
        gitlint
        gh # Github CLI tool
        graphite-cli

        # General usability
        nix-index # Run `nix-index` and then use `nix-locate` like the normal unix `locate`
        feh
        rage
        # mpv

        # Fun
        lolcat
        cowsay
        chafa

        # Networking
        nmap
        rustscan
      ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      ".scripts" = {
        source = ./dotfiles/.scripts;
        recursive = true;
      };
      ".config/codespellrc".text = ''
        [codespell]
        ignore-words-list = create
      '';
      ".config/sops/age/keys.txt" = {
        source = ./../keys/age-yubikey-identity-e5e2e0d8.txt;
      };
      ".config/sops/age/age-yubi-cyllene.txt" = {
        source = ./../keys/age-yubi-cyllene.txt;
      };
      ".ssh/config" = {
        text = ''
          Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"
        '';
      };
    };

    sessionVariables = {
      EDITOR = "nvim";
      KEYID = "843D72A9EB79A8692C585B3AE7738A7A0F5CDB89";
      CACHEPOT_CACHE_SIZE = "50G";
    };
  };
  # allows apps to find fonts
  # NOTE: I SYMLINKED /usr/share/fonts/* to .nix-profile/fonts dir
  fonts.fontconfig.enable = true;
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    atuin = {
      enable = true;
      enableFishIntegration = true;
    };
    # less.enable = true;
    bat = {
      enable = true;
      themes = {
        catppuccin = {
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "699f60fc8ec434574ca7451b444b880430319941";
            sha256 = "sha256-6fWoCH90IGumAMc4buLRWL0N61op+AuMNN9CAR9/OdI=";
          };
          file = "themes/Catppuccin Mocha.tmTheme";
        };
      };
      config = {
        theme = "Catppuccin Mocha";
      };
      #  extraPackages = with pkgs.bat-extras; [
      #    prettybat
      #    batwatch
      #    batpipe
      #    batman
      #    batgrep
      #    batdiff
      #  ];
    };
    eza = {
      enable = true;
      enableFishIntegration = true;
      git = true;
      icons = "always";
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  xdg.enable = true;
}
