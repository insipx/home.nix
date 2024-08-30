[
  {
    mode = "n";
    key = "<leader>ql";
    action.__raw = ''
      function() 
        require('telescope.builtin')
          .quickfix(require('telescope.themes').get_ivy({})) 
      end
    '';
    options = {
      silent = true;
      desc = "list items in the quickfix list";
    };
  }

  {
    mode = "n";
    key = "<leader>qh";
    action.__raw = ''
      function() 
        require('telescope.builtin')
          .quickfixhistory(require('telescope.themes').get_ivy({})) 
      end
    '';
    options = {
      silent = true;
      desc = "search through quick fix history";
    };
  }
]
