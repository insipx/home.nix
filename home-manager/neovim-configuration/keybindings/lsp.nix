{ ... }: {
  goto = (import ./lsp/goto; );
  general = (import ./lsp/general; );
  all = builtins.concatLists [ goto general ];
}
