{ ... }: [
  {
    mode = "n";
    key = "<leader><Tab>n";
    action = "<cmd>tabedit<CR>";
    options = {
      silent = true;
      desc = "new workspace";
    };
  }
  {
    mode = "n";
    key = "<leader><Tab>d";
    action = "<cmd>tabclose<CR>";
    options = {
      silent = true;
      desc = "close workspace";
    };
  }
  {
    mode = "n";
    key = "<leader><Tab>]";
    action = "<cmd>tabn<CR>";
    options = {
      silent = true;
      desc = "next workspace";
    };
  }
  {
    mode = "n";
    key = "<leader><Tab>[";
    action = "<cmd>tabp<CR>";
    options = {
      silent = true;
      desc = "previous workspace";
    };
  }
  {
    mode = "n";
    key = "<leader><Tab><Right>";
    action = "<cmd>tabm +1<CR>";
    options = {
      silent = true;
      desc = "move workspace to the right";
    };
  }
  {
    mode = "n";
    key = "<leader><Tab><Left>";
    action = "<cmd>tabm -1<CR>";
    options = {
      silent = true;
      desc = "move workspace to the left";
    };
  }
]
