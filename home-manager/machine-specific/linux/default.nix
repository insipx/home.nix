# NixOS-specific home-manager configuration
{ pkgs, ... }:
{
  imports = [
    ./rice
    ../../emacs.nix
  ];
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

}
