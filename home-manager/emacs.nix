{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  programs.doom-emacs = {
    enable = true;
    extraBinPackages =
      (with pkgs; [
        shellcheck
        coreutils
        nodejs
        gore
        haskellPackages.hoogle
        haskell-language-server
        cabal-cli
        pandoc # for markdown
        cmake
      ])
      ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
        # Doom's Dired module looks for GNU ls as gls on macOS.
        (pkgs.writeShellScriptBin "gls" ''
          exec ${pkgs.coreutils}/bin/ls "$@"
        '')
      ];
    extraPackages = epkgs: [ epkgs.treesit-grammars.with-all-grammars ];
    # this needs to be modified per machine
    doomDir = inputs.doom-config;
    doomLocalDir = "/Users/andrewplaza/code/insipx/doom-emacs";
  };
}
