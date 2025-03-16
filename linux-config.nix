{ pkgs, hy3, system, ... }:
{
  imports = [
    #   (builtins.fetchurl {
    #     url = "https://raw.githubusercontent.com/Smona/home-manager/nixgl-compat/modules/misc/nixgl.nix";
    #     sha256 = "01dkfr9wq3ib5hlyq9zq662mp0jl42fw3f6gd2qgdf8l8ia78j7i";
    #   })
  ];

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [ "root" "insipx" "andrewplaza" ];
      extra-substituters = "https://nix-community.cachix.org";
      extra-trusted-public-keys =
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    };
  };

  wayland.windowManager.hyprland = {
    enable = false;
    plugins = [ hy3.packages.${system}.hy3 ];
    settings = {
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "XDG_SESSION_TYPE,wayland"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"

      ];
      cursor = {
        no_hardware_cursors = true;
      };
    };
    systemd.enable = true;
  };
  # should enable the nightly using mozilla overlay on linux platform
  programs.firefox.enable = true;
  services.gpg-agent = {
    enable = false;
    enableScDaemon = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-curses;
    enableFishIntegration = true;
    extraConfig = ''
      allow-emacs-pinentry
    '';
  };

  services.lorri = {
    enable = true;
    enableNotifications = true;
  };

  programs.ssh.enable = true;
  # nixGL.prefix = "${nixGLDefault}/bin/nixGLDefault";
  # programs.wezterm.package = (config.lib.nixGL.wrap pkgs.wezterm);
}

