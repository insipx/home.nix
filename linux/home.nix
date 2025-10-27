# NixOs-specific home-manager configuration
{ pkgs, config, ... }:
{
  # nix = {
  #   package = pkgs.nix;
  #   settings = {
  #     experimental-features = "nix-command flakes";
  #     trusted-users = [ "root" "insipx" "andrewplaza" ];
  #     extra-substituters = "https://nix-community.cachix.org";
  #     extra-trusted-public-keys =
  #       "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
  #   };
  # };
  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-curses;
    enableFishIntegration = true;
  };
  # THIS DOES NOT SEEM TO WORK
  # NEED .gnupg/scdaemon.conf
  # disable-ccid
  programs.gpg.scdaemonSettings = {
    disable-ccid = true;
  };

  services.lorri = {
    enable = false;
    enableNotifications = true;
  };

  programs = {
    neovide = {
      enable = true;
      settings = {
        # neovim-bin = "${pkgs.neovim}/bin/nvim";
        vsync = false;
        font = {
          normal = [ "Berkeley Mono" ];
          size = 16;
        };
      };
    };
  };
  #sops = {
  #  defaultSopsFile = ./secrets/env.yaml;
  #  secrets.anthropic_key = { };
  #  gnupg.home = "${config.home.homeDirectory}/.gnupg";
  #};

  #programs = {
  #  fish = {
  #    #interactiveShellInit = ''
  #    #  set -x ANTHROPIC_API_KEY (cat ${config.sops.secrets.anthropic_key.path})
  #    #'';
  #  };
  #  ssh.enable = true;
  #};
}

