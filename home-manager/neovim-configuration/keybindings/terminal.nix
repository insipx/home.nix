{ ... }: [
  {
    mode = "n";
    key = "<leader>tt";
    action = "<cmd>ToggleTerm size=20 dir=git_dir direction=horizontal<CR>";
    options = {
      silent = true;
      desc = "toggle terminal";
    };
  }
  {
    mode = "n";
    key = "<leader>tf";
    action = "Telescope toggleterm<CR>";
    options = {
      silent = true;
      desc = "find open terminal";
    };
  }
]
