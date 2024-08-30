[
  {
    mode = [ "n" "v" ];
    key = "<leader>ic";
    action = ''"+y'';
    options = {
      silent = true;
      desc = "copy to clipboard";
    };
  }
  {
    mode = "n";
    key = "<leader>iy";
    action = ''"+p'';
    options = {
      silent = true;
      desc = "from clipboard";
    };
  }
  {
    mode = "n";
    key = "<leader>ir";
    action = "<cmd>Telescope registers<CR>";
    options = {
      silent = true;
      desc = "from register";
    };
  }
]
