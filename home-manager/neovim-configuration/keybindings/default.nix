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
in
{
  file = import ./file.nix;
  buffer = import ./buffer.nix;
  search = import ./search.nix;
  window = import ./window.nix;
  insert = import ./insert.nix;
  terminal = import ./terminal.nix;
  lsp = import ./lsp;
  syntaxNav = import ./syntax-nav.nix;
  workspaces = import ./workspaces.nix;
  telescope = import ./telescope;
  desc = [
    {
      key = "<leader>b";
      action = "";
      options.desc = "buffers";
    }
    {
      key = "<leader>D";
      action = "";
      options.desc = "diagnostics";
    }
    {
      key = "<Leader>f";
      action = "";
      options.desc = "files";
    }
    {
      key = "g";
      action = "";
      options.desc = "lsp goto";
    }
    {
      key = "<Leader>i";
      action = "";
      options.desc = "clipboard insert";
    }
    {
      key = "<Leader>l";
      action = "";
      options.desc = "lsp";
    }
    {
      key = "<Leader>p";
      action = "";
      options.desc = "project";
    }
    {
      key = "<Leader>q";
      action = "";
      options.desc = "quickfix/search";
    }
    {
      key = "<Leader>t";
      action = "";
      options.desc = "terminal";
    }
    {
      key = "<Leader>w";
      action = "";
      options.desc = "window";
    }
    {
      key = "<Leader>u";
      action = "";
      options.desc = "ui elements";
    }
    {
      key = "<Leader><Tab>";
      action = "";
      options.desc = "workspace";
    }
  ];

  inherit all;
}
