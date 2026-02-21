_: {
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
