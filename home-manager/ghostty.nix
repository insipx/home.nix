{ pkgs, inputs, ... }: {
  programs.ghostty = {
    enable = true;
    package = inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default;
    enableFishIntegration = true;
    installVimSyntax = true;
    installBatSyntax = true;
    settings = {
      font-family = "Berkeley Mono";
      theme = "catppuccin-mocha";
      font-size = "17";
      keybind = [
        "ctrl+space>shift+-=new_split:down "
        "ctrl+space>shift+\=new_split:right"
        "ctrl+space>h=goto_split:left"
        "ctrl+space>j=goto_split:bottom"
        "ctrl+space>k=goto_split:top"
        "ctrl+space>l=goto_split:right"
      ];
      window-decoration = "none";
    };
  };
}
