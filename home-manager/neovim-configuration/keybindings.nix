{ ... }: {
  file = (import ./keybindings/file; );
  buffer = (import ./keybindings/buffer; );
  search = (import ./keybindings/search; );
  window = (import ./keybindings/window; );
  insert = (import ./keybindings/insert; );
  terminal = (import ./keybindings/terminal; );
  lsp = (import ./keybindings/lsp; );
  syntax-nav = (import ./keybindings/syntax-nav; );
  workspaces = (import ./keybindings/workspaces; );
  telescope = (import ./keybindings/telescope; );
  
  all = builtins.concatLists [
    file 
    buffer 
    search 
    window 
    insert 
    terminal 
    lsp.all 
    syntax-nav 
    workspaces 
    telescope.all
  ];
}
