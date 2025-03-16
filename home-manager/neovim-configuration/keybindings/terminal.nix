[
  {
    mode = "t";
    key = "<esc>";
    action = "<C-\\><C-n>";
    options = {
      desc = "close terminal";
    };
  }
  {
    mode = "t";
    key = "jk";
    action = "<C-\\><C-n>";
    options = {
      desc = "close terminal";
    };
  }
  {
    mode = "n";
    key = "<Leader>tt";
    action = "<cmd>ToggleTerm size=20 dir=git_dir direction=horizontal<CR>";
    options = {
      silent = true;
      desc = "toggle terminal";
    };
  }
  {
    mode = "n";
    key = "<Leader>tf";
    action = "<CMD>lua _toggle_float_general()<CR>";
    options = {
      silent = true;
      desc = "toggle float terminal";
    };
  }
  {
    mode = "n";
    key = "<Leader>th";
    action = "<CMD>lua _toggle_htop()<CR>";
    options = {
      silent = true;
      desc = "toggle htop";
    };
  }
  {
    mode = "n";
    key = "<Leader>tF";
    action = "Telescope toggleterm<CR>";
    options = {
      silent = true;
      desc = "find open terminal";
    };
  }
]
