[
  {
    mode = "n";
    key = "<leader>pf";
    action.__raw = ''
      function() 
        require('telescope.builtin')
          .git_files(require('telescope.themes').get_ivy({})) 
      end
    '';
    options = {
      silent = true;
      desc = "find file in project";
    };
  }

  {
    mode = "n";
    key = "<leader>pp";
    action.__raw = ''
      function() 
        require('telescope')
          .extensions.project.project({}) 
      end
    '';
    options = {
      silent = true;
      desc = "Open Projects";
    };
  }
]
