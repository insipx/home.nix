[
  {
    mode = "n";
    key = "[e";
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
    key = "]e";
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
  {
    mode = "n";
    key = "[w";
    action.__raw = ''
      function()
        require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.WARNING })
      end
    '';
    options = {
      silent = true;
      desc = "next warning";
    };
  }
  {
    mode = "n";
    key = "]w";
    action.__raw = ''
      function()
        require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.WARNING })
      end
    '';
    options = {
      silent = true;
      desc = "previous warning";
    };
  }

]
