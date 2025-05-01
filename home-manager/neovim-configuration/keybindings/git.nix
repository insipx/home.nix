[
  {
    mode = "n";
    key = "<Leader>gg";
    action.__raw = ''
      require('neogit').open
    '';
    options.desc = "open neogit";
  }
  {
    mode = "n";
    key = "<Leader>gd";
    action = "<cmd>DiffviewOpen<CR>";
    options = {
      silent = true;
      desc = "open diffview";
    };
  }
]
