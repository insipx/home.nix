_: {
  programs.doom-emacs = {
    enable = true;
    extraBinPackages = [ ];
    extraPackages = epkgs: [ epkgs.treesit-grammars.with-all-grammars ];
  };
}
