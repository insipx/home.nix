{ ... }: {
  config = [{
    group = "lsp";
    __unkeyed-1 = {
      group = "goto";
      __unkeyed-1 = {
        __unkeyed-1 = "<leader>gp";
        __unkeyed-2 = "<cmd>Lspsaga peek_definition<CR>";
      };
    };
  }];
}

