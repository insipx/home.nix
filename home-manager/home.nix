{ config
, pkgs
, nixvim
, catppuccin
, swww
, ...
}@inputs:
let
  privateConfiguration = builtins.fetchGit {
    url = "git@github.com:insipx/home.private.nix.git";
    rev = "98f0c6cbf66d7b80607be566546fd2ddb43ad611";
    allRefs = true;
  };
in
{
  inherit (pkgs) lib;
  imports = [
    nixvim.homeManagerModules.nixvim
    catppuccin.homeManagerModules.catppuccin
    (import ./neovim-configuration { inherit config pkgs; })
    (import privateConfiguration)
  ];
  catppuccin.enable = true;
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
        # ghostty not packaged for darwin yet

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

        # General usability
        nix-index # Run `nix-index` and then use `nix-locate` like the normal unix `locate`
        feh
        gh # Github CLI tool
        graphite-cli
        # mpv

        # Fun
        lolcat
        cowsay
        chafa

        # Networking
        nmap
        rustscan
      ] ++ lib.optionals
        pkgs.stdenv.isLinux
        [
          # pkgs.nixgl.auto.nixGLDefault
          # gnupg
          yubikey-personalization
          cachix
          swww.packages.${pkgs.system}.swww
          inputs.nix-gl-host
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
      ".ssh/config" = {
        text = ''
          Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"
        '';
      };
      ".config/ghostty" = {
        source = ./dotfiles/ghostty;
        recursive = true;
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
    neovide = {
      enable = false;
      settings = {
        vsync = true;
        font = {
          normal = [ "Berkeley Mono" "Symbols Nerd Font Mono" ];
          size = 14;
        };
      };
    };
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
      extraPackages = with pkgs.bat-extras; [
        prettybat
        batwatch
        batpipe
        batman
        batgrep
        batdiff
      ];
    };
    eza = {
      enable = true;
      enableFishIntegration = true;
      git = true;
      icons = "always";
    };
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    #ghostty = { does not work on macos yet
    #  enable = true;
    #  enableFishIntegration = true;
    #  settings = {
    #    font-family = "Berekely Mono";
    #    theme = "catppuccin-mocha";
    #    font-size = "16";
    #  };
    #};
    fish = {
      enable = true;
      shellAliases = {
        vi = "nvim";
        vim = "nvim";
        ls = "eza";
        du = "dust";
        pretty = "prettybat";
        diff = "batdiff";
        # less = "batpipe";
        man = "batman";
        rg = "batgrep";
        grep = "batgrep";
        # ssh = "GPG_TTY=$(tty) ssh";
        cat = "bat";
        jq = "xq";
        nix = "nix --log-format bar";
      };
      #   loginShellInit = ''
      #     eval (direnv hook fish)
      #   '';
      interactiveShellInit = ''
            macchina
            set fish_greeting # Disable greeting
            if test (uname) = Darwin
        	    fish_add_path /opt/homebrew/bin
            end
            set -x GPG_TTY (tty)
            set -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
            gpgconf --launch gpg-agent
            fish_vi_key_bindings
            set -x KEYID "843D72A9EB79A8692C585B3AE7738A7A0F5CDB89"

            # Batpipe setup
            set -x LESSOPEN "|${pkgs.bat-extras.batpipe}/bin/.batpipe-wrapped %s";
            set -e LESSCLOSE;

            # The following will enable colors when using batpipe with less:
            set -x LESS "$LESS -R";
            set -x BATPIPE "color";

            #  set -gx VOLTA_HOME "$HOME/.volta"
            # set -gx PATH "$VOLTA_HOME/bin" $PATH
            set -gx PATH "$HOME/.scripts" $PATH
            fish_add_path --prepend --global /usr/lib/emscripten
            if test (uname) = Darwin
              fish_add_path --prepend --global "$HOME/.nix-profile/bin" /nix/var/nix/profiles/default/bin /run/current-system/sw/bin
              fish_add_path --prepend --global "$HOME/.foundry/bin"
            end

            function ssh --wraps ssh
              set --function --export GPG_TTY $(tty)
              echo $GPG_TTY
              command ssh $argv
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
        {
          name = "forgit";
          inherit (pkgs.fishPlugins.forgit) src;
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
      extraConfig = {
        rerere.enabled = true;
        pull = {
          rebase = true;
        };
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  xdg.enable = true;
}
