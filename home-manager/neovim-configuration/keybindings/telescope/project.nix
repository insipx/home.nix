[
  {
    mode = "n";
    key = "<leader>pf";
    action.__raw = ''
      function()
        require('fff').find_in_git_root()
      end
    '';
    options = {
      silent = true;
      desc = "find file in project";
    };
  }
]

