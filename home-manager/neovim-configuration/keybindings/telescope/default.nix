let
  modules = [
    ./general.nix
    ./buffer.nix
    ./diagnostics.nix
    ./project.nix
    ./search.nix
    ./lsp.nix
    ./nvim-commands.nix
  ];
  imports = map import modules;

  all = builtins.concatLists
    (map (m: if builtins.isAttrs m then m.all else m) imports);

in {
  inherit (import ./general.nix) general;
  inherit (import ./buffer.nix) buffer;
  inherit (import ./diagnostics.nix) diagnostics;
  inherit (import ./project.nix) project;
  inherit (import ./search.nix) search;
  inherit (import ./lsp.nix) lsp;
  inherit (import ./nvim-commands.nix) nvimCommands;

  inherit all;
}
