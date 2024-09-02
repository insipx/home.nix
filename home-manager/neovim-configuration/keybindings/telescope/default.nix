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
  general = (import ./general.nix);
  buffer = (import ./buffer.nix);
  diagnostics = (import ./diagnostics.nix);
  project = (import ./project.nix);
  search = (import ./search.nix);
  lsp = (import ./lsp.nix);
  nvimCommands = (import ./nvim-commands.nix);

  inherit all;
}
