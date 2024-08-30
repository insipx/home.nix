{ ... }: [
  {
    mode = "n";
    key = "<leader>ff";
    action.__raw = ''
      function() 
        require('telescope.builtin')
          .find_files(require('telescope.themes').get_ivy({})) 
      end
    '';
    options = {
      silent = true;
      desc = "find files";
    };

  }

  {
    mode = "n";
    key = "<leader>fr";
    action.__raw = ''
      function() 
        require('telescope.builtin')
          .old_files(require('telescope.themes').get_ivy({})) 
      end
    '';
    options = {
      silent = true;
      desc = "open recent file";
    };
  }
  {
    mode = "n";
    key = "<leader>fb";
    action.__raw = ''
      function() 
        require('telescope')
          .extensions.file_browser
          .file_browser(require('telescope.themes').get_ivy({})) 
      end
    '';
    options = {
      silent = true;
      desc = "browse files";
    };
  }
  {
    mode = "n";
    key = "<leader>fm";
    action.__raw = ''
      function() 
        require('telescope.builtin')
          .marks(require('telescope.themes').get_ivy({})) 
      end
    '';
    options = {
      silent = true;
      desc = "find marks";
    };
  }
  {
    mode = "n";
    key = "<leader>fh";
    action.__raw = ''
      function() 
        require('telescope.builtin')
          .oldfiles(require('telescope.themes').get_ivy({})) 
      end
    '';
    options = {
      silent = true;
      desc = "find history";
    };
  }
  {
    mode = "n";
    key = "<leader>/";
    action.__raw = ''
      function() 
        require('telescope.builtin')
          .live_grep(require('telescope.themes').get_ivy({})) 
      end
    '';
    options = {
      silent = true;
      desc = "fuzzy search project";
    };
  }
  {
    mode = "n";
    key = "<leader>H";
    action.__raw = ''
      function() 
        require('telescope.builtin')
          .search_history(require('telescope.themes').get_ivy({})) 
      end
    '';
    options = {
      silent = true;
      desc = "search own history";
    };
  }
]
