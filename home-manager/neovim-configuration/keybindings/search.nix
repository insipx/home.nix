[
  {
    mode = "n";
    key = "<Leader>qo";
    action = "<cmd>copen<CR>";
    options = {
      silent = true;
      desc = "Open quickfix window";
    };
  }
  {
    mode = "n";
    key = "<Leader>qc";
    action = "<cmd>ccl<CR>";
    options = {
      silent = true;
      desc = "Close quickfix window";
    };
  }
  {
    mode = "n";
    key = "<Leader>qn";
    action = "<cmd>cn<CR>";
    options = {
      silent = true;
      desc = "go to next error in quickfix window";
    };
  }
  {
    mode = "n";
    key = "<Leader>qp";
    action = "<cmd>cp<CR>";
    options = {
      silent = true;
      desc = "go to previous error in quickfix window";
    };
  }
  {
    mode = "n";
    key = "<Leader>qs";
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
