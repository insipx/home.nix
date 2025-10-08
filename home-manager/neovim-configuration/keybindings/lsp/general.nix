[
  {
    mode = "n";
    key = "<leader>la";
    action = "<CMD>Lspsaga code_action<CR>";
    options = {
      silent = true;
      desc = "select code action";
    };
  }
  {
    mode = "n";
    key = "<leader>lf";
    action.__raw = ''
      function() vim.lsp.buf.format() end
    '';
    options = {
      silent = true;
      desc = "format buffer";
    };
  }
  {
    mode = "n";
    key = "<leader>ld";
    action = "<cmd>Lspsaga hover_doc<CR>";
    options = {
      silent = true;
      desc = "Show documentation";
    };
  }
  {
    mode = "n";
    key = "<leader>ld";
    action = "<cmd>Lspsaga hover_doc<CR>";
    options = {
      silent = true;
      desc = "Show documentation";
    };
  }
  {
    mode = "n";
    key = "<leader>lo";
    action = "<cmd>Lspsaga outline<CR>";
    options = {
      silent = true;
      desc = "Show outline";
    };
  }

  {
    mode = "n";
    key = "<leader>ls";
    action = "<cmd>SymbolsOutline<CR>";
    options = {
      silent = true;
      desc = "toggle symbols outline";
    };
  }
  {
    mode = "n";
    key = "<leader>lg";
    action = "<cmd>Lspsaga show_workspace_diagnostics ++normal<CR>";
    options = {
      silent = true;
      desc = "show workspace diagnostics";
    };
  }
  {
    mode = "n";
    key = "<leader>l[E";
    action.__raw = ''
      function()
        require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
      end
    '';
    options = {
      silent = true;
      desc = "next error";
    };
  }
  {
    mode = "n";
    key = "<leader>l]E";
    action.__raw = ''
      function()
        require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
      end
    '';
    options = {
      silent = true;
      desc = "previous error";
    };
  }

]
