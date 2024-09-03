[
  {
    mode = "n";
    key = "gp";
    action = "<cmd>Lspsaga peek_definition<CR>";
    options = {
      silent = true;
      desc = "peek definition";
    };
  }
  {
    mode = "n";
    key = "gt";
    action = "<cmd>Lspsaga peek_type_definition<CR>";
    options = {
      silent = true;
      desc = "peek type definition";
    };
  }
  {
    mode = "n";
    key = "gh";
    action = "<cmd>Lspsaga lsp_finder<CR>";
    options = {
      silent = true;
      desc = "find symbols definition";
    };
  }
  {
    mode = "n";
    key = "gr";
    action = "<cmd>Lspsaga rename ++project<CR>";
    options = {
      silent = true;
      desc = "rename occurrences of hovered word for selected files";
    };
  }
]
