{ config, pkgs, ... }:

{
  imports = [ ./profile.nix ];

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
    grc
    exa # replacement for ls
    du-dust # replacement for du
    fd
    ripgrep
    tree-sitter
    glow
    rust-analyzer
    git
    bat # Cat clone with syntax highlighting and git integration
    tokei

    # NixOs related
    deadnix
    cbfmt
    nixfmt
    statix
    # Git
    gitlint
    # General
    codespell

    # General usability
    feh
    gh # Github CLI tool
    ncdu

    # Networking
    nmap
    rustscan

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/insipx/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    # EDITOR = "emacs";
    KEYID = "25CB17AB243484C1687D6D067976AC4AEB07F67F";
  };

  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
    pinentryFlavor = "gnome3";
    enableFishIntegration = true;
    extraConfig = ''
      allow-emacs-pinentry
    '';
  };

  services.lorri = {
    enable = true;
    enableNotifications = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.fish = {
    enable = true;
    shellAliases = {
      vi = "nvim";
      vim = "nvim";
      ls = "exa";
      du = "dust";
      hms = "home-manager switch";
      cat = "bat";
    };
    loginShellInit = ''
      eval (direnv hook fish)
    '';
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      set -x GPG_TTY (tty)
      set -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
      gpgconf --launch gpg-agent
      fish_vi_key_bindings
      atuin init fish | source
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
  #programs.kitty = {
  #  enable = true;
  #  shellIntegration.enableFishIntegration = true;
  #  theme = "Spacedust";
  #  # font.package = "${pkgs.pragmatapro}";
  #  font.name = "mononoki Nerd Font";
  #  font.size = 10;
  #  keybindings = {
  #    "ctrl+shift+z"     = "goto_layout stack";
  #    "ctrl+shift+a"     = "goto_layout tall";
  #    "super+shift+["    = "previous_tab";
  #    "super+shift+]"    = "next_tab";
  #    "super+shift+t"    = "new_tab";
  #    "alt+shift+ctrl+left" = "move_tab_backward"; # meh + left
  #    "alt+shift+ctrl+right" = "move_tab_forward"; # meh + right
  #    
  #    "ctrl+shift+enter" = "new_window";
  #    "alt+shift+ctrl+1" = "first_window";
  #    "alt+shift+ctrl+2" = "second_window";
  #    "alt+shift+ctrl+3" = "third_window";
  #    "alt+shift+ctrl+4" = "fourth_window";
  #    "alt+shift+ctrl+5" = "fifth_window";
  #    "alt+shift+ctrl+6" = "sixth_window";
  #    "alt+shift+ctrl+7" = "seventh_window";
  #    "alt+shift+ctrl+8" = "eight_window";
  #    "alt+shift+ctrl+9" = "ninth_window";
  #    "alt+shift+ctrl+0" = "tenth_window";
  #    "alt+shift+ctrl+s" = "goto_layout stack";
  #    "alt+shift+ctrl+t" = "goto_layout tall";
  #    "alt+shift+ctrl+z" = "toggle_layout stack";
  #    # Focus
  #    "alt+shift+ctrl+l" = "neighboring_window right";
  #    "alt+shift+ctrl+j" = "neighboring_window down";
  #    "alt+shift+ctrl+k" = "neighboring_window up";
  #    "ctrl+alt+h" = "neighboring_window left";
  #    "alt+shift+ctrl+super+r" = "set_tab_title";
  #  };
  #  extraConfig = ''
  #    modify_font underline_position +2
  #    modify_font underline_thickness 200%
  #    modify_font strikethrough_position 2px
  #    tab_bar_style slant
  #    tab_title_template "{title}"
  #    # repaint_delay 6
  #    # dim_opacity 0.9
  #    # background_opacity 1.0
  #  '';
  #};
  # programs.neovim = {
  #   enable = true;
  #   withPython3 = true;
  #   withNodeJs = true;
  #   withRuby = true;
  #   defaultEditor = true;
  #   extraPython3Packages = (ps: with ps; [ pynvim unidecode black isort ]);
  # };
  programs.ssh = {
    enable = true;
    serverAliveInterval = 5;
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "insipx";
        identityFile = "/home/insipx/.ssh/id_rsa_yubikey.pub";
      };
    };
  };
  programs.git = {
    enable = true;
    userName = "Andrew Plaza";
    userEmail = "aplaza@liquidthink.net";
    signing = {
      key = "25CB17AB243484C1687D6D067976AC4AEB07F67F";
      signByDefault = true;
    };
  };
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  xdg.enable = true;
  xdg.configFile = {
    "kitty" = {
      source = ./dotfiles/kitty;
      recursive = true;
    };
  };
  xdg.configFile = {
    "nvim" = {
      source = ./dotfiles/insipx-nvim;
      recursive = true;
    };
  };

}
