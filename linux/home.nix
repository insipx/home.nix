# NixOs-specific home-manager configuration
{ pkgs, ... }:
{
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
}
