{ ... }: [
  {
    mode = "n";
    key = "<leader>bb";
    action.__raw = ''
      function() 
        require('telescope.builtin')
          .buffers(require('telescope.themes').get_ivy({})) 
      end
    '';
    options = {
      silent = true;
      desc = "list buffers in current context";
    };
  }

  {
    mode = "n";
    key = "<leader>bB";
    action.__raw = ''
      function() 
        require('telescope')
          .extensions.scope.buffers(require('telescope.themes').get_ivy({})) 
      end
    '';
    options = {
      silent = true;
      desc = "list all buffers";
    };
  }

  {
    mode = "n";
    key = "<leader>bt";
    action.__raw = ''
      function() 
        require('telescope')
          .extensions.tele_tabby.list(require('telescope.themes').get_ivy({})) 
      end
    '';
    options = {
      silent = true;
      desc = "buffer search";
    };
  }
]
