{ config, stdenv, pkgs, lib, ... }:
let
  privateConfiguration = builtins.fetchGit {
    url = "git@github.com:insipx/home.private.nix.git";
    rev = "77a7772aa8cc6f32f9fc48822d142d380afda411";
    allRefs = true;
  };
in {
  imports = [ (import privateConfiguration) ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # Fonts, Github's Font
    monaspace

    grc # Colorizer
    eza # replacement for ls
    du-dust # replacement for du
    fd # find
    ripgrep
    tree-sitter
    glow
    git
    bat # Cat clone with syntax highlighting and git integration
    tokei
    erdtree
    htop
    jq # Json format
    duf # alternative to df, filesystem free space viewer
    websocat # Query websockets
    wget

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
    ncdu
    atuin

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
  home.file = {
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
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
    KEYID = "843D72A9EB79A8692C585B3AE7738A7A0F5CDB89";
    CACHEPOT_CACHE_SIZE = "50G";
  };

  programs.wezterm = {
    enable = true;
    enableZshIntegration = false;
    enableBashIntegration = false;
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.fish = {
    enable = true;
    shellAliases = {
      vi = "nvim";
      vim = "nvim";
      ls = "eza";
      du = "dust";
      # hms = "home-manager switch";
      sw = "darwin-rebuild switch --flake ~/.config/nix-darwin/";
      cat = "bat --theme zenburn";
      s = "kitty +kitten ssh";
      commit-ai = "aicommits -a --type conventional --generate 4";
    };
    #   loginShellInit = ''
    #     eval (direnv hook fish)
    #   '';
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      fish_add_path /opt/homebrew/bin
      set -x GPG_TTY (tty)
      set -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
      gpgconf --launch gpg-agent
      fish_vi_key_bindings
      atuin init fish | source

      set -gx VOLTA_HOME "$HOME/.volta"
      set -gx PATH "$VOLTA_HOME/bin" $PATH
      set -gx PATH "$HOME/.scripts" $PATH
      if test (uname) = Darwin
        fish_add_path --prepend --global "$HOME/.nix-profile/bin" /nix/var/nix/profiles/default/bin /run/current-system/sw/bin
      end
    '';
    plugins = [
      {
        name = "grc";
        src = pkgs.fishPlugins.grc.src;
      }
      {
        name = "colored-man-pages";
        src = pkgs.fishPlugins.colored-man-pages.src;
      }
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "pure";
        src = pkgs.fishPlugins.pure.src;
      }
    ];
  };

  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    theme = "Spacedust";
    font.name = "Input";
    font.size = 13;
    keybindings = {
      "ctrl+shift+z" = "goto_layout stack";
      "ctrl+shift+a" = "goto_layout tall";
      "super+shift+[" = "previous_tab";
      "super+shift+]" = "next_tab";
      "super+shift+t" = "new_tab";
      "alt+shift+ctrl+left" = "move_tab_backward"; # meh + left
      "alt+shift+ctrl+right" = "move_tab_forward"; # meh + right

      "ctrl+shift+enter" = "new_window";
      "alt+shift+ctrl+1" = "first_window";
      "alt+shift+ctrl+2" = "second_window";
      "alt+shift+ctrl+3" = "third_window";
      "alt+shift+ctrl+4" = "fourth_window";
      "alt+shift+ctrl+5" = "fifth_window";
      "alt+shift+ctrl+6" = "sixth_window";
      "alt+shift+ctrl+7" = "seventh_window";
      "alt+shift+ctrl+8" = "eight_window";
      "alt+shift+ctrl+9" = "ninth_window";
      "alt+shift+ctrl+0" = "tenth_window";
      "alt+shift+ctrl+s" = "goto_layout stack";
      "alt+shift+ctrl+t" = "goto_layout tall";
      "alt+shift+ctrl+z" = "toggle_layout stack";
      # Focus
      "ctrl+l" = "neighboring_window right";
      "ctrl+j" = "neighboring_window down";
      "ctrl+k" = "neighboring_window up";
      "ctrl+h" = "neighboring_window left";
      "ctrl+alt+h" = "neighboring_window left";
      "alt+shift+ctrl+super+r" = "set_tab_title";
    };
    extraConfig = ''
      modify_font underline_position +2
      modify_font underline_thickness 200%
      modify_font strikethrough_position 2px
      tab_bar_style powerline
      tab_powerline_style round
      tab_title_template "{title}"
      draw_minimal_borders no
      repaint_delay 8
      window_border_width 1pt
      # repaint_delay 6
      # dim_opacity 0.9
      # background_opacity 1.0
      symbol_map U+23FB-U+23FE,U+2665,U+26A1,U+2B58,U+E000-U+E00A,U+E0A0-U+E0A3,U+E0B0-U+E0D4,U+E200-U+E2A9,U+E300-U+E3E3,U+E5FA-U+E6AA,U+E700-U+E7C5,U+EA60-U+EBEB,U+F000-U+F2E0,U+F300-U+F32F,U+F400-U+F4A9,U+F500-U+F8FF,U+F0001-U+F1AF0 Symbols Nerd Font Mono
    '';
  };

  programs.neovim = {
    enable = true;
    withPython3 = true;
    withNodeJs = true;
    withRuby = true;
    defaultEditor = true;
    extraPython3Packages = (ps: with ps; [ pynvim unidecode black isort ]);
  };

  programs.git = {
    enable = true;
    userName = "Andrew Plaza";
    userEmail = "github@andrewplaza.dev";
    signing = {
      key = "843D72A9EB79A8692C585B3AE7738A7A0F5CDB89";
      signByDefault = true;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      rust-lang.rust-analyzer
      asvetliakov.vscode-neovim
      serayuzgur.crates
    ];
  };

  xdg.enable = true;
  # xdg.configFile = {
  #   "kitty" = {
  #     source = ./dotfiles/kitty;
  #     recursive = true;
  #   };
  # };

  xdg.configFile = {
    "nvim" = {
      source = ./dotfiles/insipx-nvim;
      recursive = true;
    };
  };
}
