[
  {
    mode = "n";
    key = "\\\\w";
    action = "<cmd>HopWord<CR>";
    options = {
      silent = true;
      desc = "hop to a word";
    };
  }
  {
    mode = "n";
    key = "\\\\b";
    action = "<cmd>HopWordBC<CR>";
    options = {
      silent = true;
      desc = "hop word backwards";
    };
  }
  {
    mode = "n";
    key = "\\\\f";
    action = "<cmd>HopWordAC<CR>";
    options = {
      silent = true;
      desc = "hop word forwards";
    };
  }
  {
    mode = "n";
    key = "\\\\a";
    action = "<cmd>HopAnywhere<CR>";
    options = {
      silent = true;
      desc = "hop anywhere";
    };
  }
  {
    mode = "n";
    key = "\\\\p";
    options = {
      silent = true;
      desc = "toggle precognition";
    };
    action.__raw = ''
      function()
        if require("precognition").toggle() then
          vim.notify("precognition on")
        else
          vim.notify("precognition off")
        end
      end
    '';

  }
]
