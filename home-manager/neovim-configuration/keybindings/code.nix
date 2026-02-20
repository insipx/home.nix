[
  {
    mode = "n";
    key = "<Leader>cw";
    action.__raw = ''
      function()
        require("mini.trailspace").trim()
      end
    '';
    options.desc = "trim whitespace";
  }
  {
    mode = "n";
    key = "<leader>cD";
    action = "<cmd>Lspsaga show_workspace_diagnostics ++normal<CR>";
    options = {
      silent = true;
      desc = "show workspace diagnostics";
    };
  }
  {
    mode = "n";
    key = "<leader>cd";
    action = "<cmd>Lspsaga hover_doc<CR>";
    options = {
      silent = true;
      desc = "Show documentation";
    };
  }
  {
    mode = "n";
    key = "<leader>cf";
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
    key = "<leader>co";
    action = "<cmd>Lspsaga outline<CR>";
    options = {
      silent = true;
      desc = "Show outline";
    };
  }
  {
    mode = "n";
    key = "<leader>ca";
    action = "<CMD>Lspsaga code_action<CR>";
    options = {
      silent = true;
      desc = "select code action";
    };
  }

]
