{ inputs, pkgs, ... }:
{
  programs.doom-emacs = {
    enable = true;
    doomDir = inputs.doom-config;
    extraBinPackages = [];
    extraPackages = epkgs: [ epkgs.treesit-grammars.with-all-grammars ];
  };
}
