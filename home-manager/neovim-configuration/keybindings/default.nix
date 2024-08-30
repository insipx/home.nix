let
  modules = [
    ./file.nix
    ./buffer.nix
    ./search.nix
    ./window.nix
    ./insert.nix
    ./terminal.nix
    ./lsp
    ./syntax-nav.nix
    ./workspaces.nix
    ./telescope
  ];

  imports = map import modules;

  all = builtins.concatLists
    (map (m: if builtins.isAttrs m then m.all else m) imports);
in {
  inherit (import ./file.nix) file;
  inherit (import ./buffer.nix) buffer;
  inherit (import ./search.nix) search;
  inherit (import ./window.nix) window;
  inherit (import ./insert.nix) insert;
  inherit (import ./terminal.nix) terminal;
  inherit (import ./lsp) lsp;
  inherit (import ./syntax-nav.nix) syntaxNav;
  inherit (import ./workspaces.nix) workspaces;
  inherit (import ./telescope) telescope;

  inherit all;
}
