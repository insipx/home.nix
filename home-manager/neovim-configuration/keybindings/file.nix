[{
  mode = "n";
  key = "<Leader>ft";
  action.__raw = ''
    function()
      require("oil").toggle_float()
    end
  '';
  options = {
    silent = true;
    desc = "toggle file browser";
  };
}
  {
    mode = "n";
    key = "<Leader>fth";
    action.__raw = ''
      function()
        require("oil").toggle_hidden()
      end
    '';
    options.desc = "toggle hidden files";
  }
]
