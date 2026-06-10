# NixOS-specific home-manager configuration
{ pkgs, ... }:
{
  imports = [
    ./rice
    # ../../emacs.nix
  ];

  # Wayland/Hyprland desktop tooling — Linux-only, has no meaning on darwin.
  home.packages = with pkgs; [
    satty # screenshot annotation (piped from hyprshot)
    hyprpicker # color picker
  ];
  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-curses;
    enableFishIntegration = true;
    extraConfig = ''
      allow-loopback-pinentry
      allow-emacs-pinentry
    '';
  };
  # THIS DOES NOT SEEM TO WORK
  # NEED .gnupg/scdaemon.conf
  # disable-ccid
  programs.gpg.scdaemonSettings = {
    disable-ccid = true;
  };

}
