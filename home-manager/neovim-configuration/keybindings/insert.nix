[
  {
    mode = [ "n" "v" ];
    key = "<Leader>ic";
    action = ''"+y'';
    options = {
      silent = true;
      desc = "copy to clipboard";
    };
  }
  {
    mode = "n";
    key = "<Leader>iy";
    action = ''"+p'';
    options = {
      silent = true;
      desc = "from clipboard";
    };
  }
  {
    mode = "n";
    key = "<Leader>ir";
    action = "<cmd>Telescope registers<CR>";
    options = {
      silent = true;
      desc = "from register";
    };
  }
]
