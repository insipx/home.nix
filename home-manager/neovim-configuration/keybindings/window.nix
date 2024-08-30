[
  {
    mode = "n";
    key = "<leader>wh";
    action = "<C-W>h";
    options = {
      silent = true;
      desc = "move to window on left";
    };
  }
  {
    mode = "n";
    key = "<leader>wl";
    action = "<C-W>l";
    options = {
      silent = true;
      desc = "move to window on right";
    };
  }
  {
    mode = "n";
    key = "<leader>wj";
    action = "<C-W>j";
    options = {
      silent = true;
      desc = "move to window below";
    };
  }

  {
    mode = "n";
    key = "<leader>wk";
    action = "<C-W>k";
    options = {
      silent = true;
      desc = "move to window above";
    };
  }
  {
    mode = "n";
    key = "<leader>wv";
    action = "<C-w>v";
    options = {
      silent = true;
      desc = "vertical split window";
    };
  }
  {
    mode = "n";
    key = "<leader>ws";
    action = "<C-w>s";
    options = {
      silent = true;
      desc = "horizontal split window";
    };
  }
  {
    mode = "n";
    key = "<leader>wq";
    action.__raw = ''
      -- possibly make this :q
           require('mini.bufremove').unshow()
    '';
    options = {
      silent = true;
      desc = "move to window on left";
    };
  }

  {
    mode = "n";
    key = "<leader>w=";
    action = "<C-w>=";
    options = {
      silent = true;
      desc = "balance windows";
    };
  }

  {
    mode = "n";
    key = "<leader>wL";
    action = "<C-w>>2";
    options = {
      silent = true;
      desc = "resize right";
    };
  }
  {
    mode = "n";
    key = "<leader>wH";
    action = "<C-w><2";
    options = {
      silent = true;
      desc = "resize left";
    };
  }
  {
    mode = "n";
    key = "<leader>wJ";
    action = "<C-w>+2";
    options = {
      silent = true;
      desc = "resize down";
    };
  }
  {
    mode = "n";
    key = "<leader>wK";
    action = "<C-w>-2";
    options = {
      silent = true;
      desc = "resize up";
    };
  }
]
