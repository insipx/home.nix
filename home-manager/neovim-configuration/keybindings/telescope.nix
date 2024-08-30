{ ... }: {
  general = (import ./telescope/general; );
  buffer = (import ./telescope/buffer; );
  diagnostics = (import ./telescope/diagnostics; );
  project = (import ./telescope/project; );
  search = (import ./telescope/search; );
  lsp = (import ./telescope/lsp; );
  nvim-commands = (import ./telescope/nvim-commands; );
  all = builtins.concatLists [ general buffer diagnostics project search lsp nvim-commands ];
}  
