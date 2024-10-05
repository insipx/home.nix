{ config, pkgs, nixvim, ... }:
let
  #privateConfiguration = builtins.fetchGit {
  #  url = "git@github.com:insipx/home.private.nix.git";
  #  rev = "f4df03bac3812d9ff901f1e7822c8490a42c351b";
  #  allRefs = true;
  #};
  nerdfonts = pkgs.nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; };
in
{
  inherit (pkgs) lib;
  imports = [
    nixvim.homeManagerModules.nixvim
    (import ./configure-neovim.nix { inherit config pkgs; })
    # (import privateConfiguration)
  ];
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
    packages = with pkgs; [
      # Fonts, Github's Font, minecraft font, minecraft font vectorized
      monaspace
      monocraft
      miracode
      nerdfonts

      ripgrep
      grc # Colorizer
      eza # replacement for ls
      du-dust # replacement for du
      fd # find
      macchina
      glow
      git
      bat # Cat clone with syntax highlighting and git integration
      tokei
      erdtree
      # ncdu
      htop
      xq # Json format
      duf # alternative to df, filesystem free space viewer
      websocat # Query websockets
      wget
      spotifyd

      # Nix & General linting applicable to p. much everything related
      deadnix
      nixfmt
      statix
      # Git
      gitlint

      # General usability
      nix-index # Run `nix-index` and then use `nix-locate` like the normal unix `locate`
      feh
      gh # Github CLI tool
      atuin
      # mpv
      # neovide

      # Fun
      lolcat
      cowsay
      chafa

      # Networking
      nmap
      rustscan
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      fish
      # pkgs.nixgl.auto.nixGLDefault
      # gnupg
      yubikey-personalization
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
      ".config/wezterm" = {
        source = ./dotfiles/wezterm;
        recursive = true;
      };
      ".config/neovide" = {
        source = ./dotfiles/neovide;
        recursive = true;
      };
    };

    sessionVariables = {
      EDITOR = "nvim";
      KEYID = "843D72A9EB79A8692C585B3AE7738A7A0F5CDB89";
      CACHEPOT_CACHE_SIZE = "50G";
    };
  };
  programs = {
    wezterm = {
      enable = true;
      enableZshIntegration = false;
      enableBashIntegration = false;
    };
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    fish = {
      enable = true;
      shellAliases = {
        vi = "nvim";
        vim = "nvim";
        ls = "eza";
        du = "dust";
        # sw = "darwin-rebuild switch --flake ~/.config/nix-darwin/";
        cat = "bat --theme TwoDark";
        # s = "kitty +kitten ssh";
        jq = "xq";
      };
      #   loginShellInit = ''
      #     eval (direnv hook fish)
      #   '';
      interactiveShellInit = ''
            set fish_greeting # Disable greeting
            if test (uname) = Darwin
        	    fish_add_path /opt/homebrew/bin
            end
            set -x GPG_TTY (tty)
            set -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
            gpgconf --launch gpg-agent
            fish_vi_key_bindings
            atuin init fish | source

            #  set -gx VOLTA_HOME "$HOME/.volta"
            # set -gx PATH "$VOLTA_HOME/bin" $PATH
            set -gx PATH "$HOME/.scripts" $PATH
            if test (uname) = Darwin
              fish_add_path --prepend --global "$HOME/.nix-profile/bin" /nix/var/nix/profiles/default/bin /run/current-system/sw/bin
              fish_add_path --prepend --global "$HOME/.foundry/bin"
            end
      '';
      plugins = [
        {
          name = "grc";
          inherit (pkgs.fishPlugins.grc) src;
        }
        {
          name = "colored-man-pages";
          inherit (pkgs.fishPlugins.colored-man-pages) src;
        }
        {
          name = "done";
          inherit (pkgs.fishPlugins.done) src;
        }
        {
          name = "pure";
          inherit (pkgs.fishPlugins.pure) src;
        }
      ];
    };

    git = {
      enable = true;
      userName = "Andrew Plaza";
      userEmail = "github@andrewplaza.dev";
      signing = {
        key = "843D72A9EB79A8692C585B3AE7738A7A0F5CDB89";
        signByDefault = true;
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        rust-lang.rust-analyzer
        asvetliakov.vscode-neovim
        serayuzgur.crates
      ];
    };
  };

  xdg.enable = true;
}
