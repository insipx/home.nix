[
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
    action = "Telescope toggleterm<CR>";
    options = {
      silent = true;
      desc = "find open terminal";
    };
  }
]
