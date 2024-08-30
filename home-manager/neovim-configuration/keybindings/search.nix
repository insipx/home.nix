[
  {
    mode = "n";
    key = "<leader>qo";
    action = "<cmd>copen<CR>";
    options = {
      silent = true;
      desc = "Open quickfix window";
    };
  }
  {
    mode = "n";
    key = "<leader>qc";
    action = "<cmd>ccl<CR>";
    options = {
      silent = true;
      desc = "Close quickfix window";
    };
  }
  {
    mode = "n";
    key = "<leader>qn";
    action = "<cmd>cn<CR>";
    options = {
      silent = true;
      desc = "go to next error in quickfix window";
    };
  }
  {
    mode = "n";
    key = "<leader>qp";
    action = "<cmd>cp<CR>";
    options = {
      silent = true;
      desc = "go to previous error in quickfix window";
    };
  }
  {
    mode = "n";
    key = "<leader>qs";
    action.__raw = ''
      function()
        require('spectre').open_visual({ select_word = true })
      end
    '';
    options = {
      silent = true;
      desc = "Open quickfix window";
    };
  }
]
