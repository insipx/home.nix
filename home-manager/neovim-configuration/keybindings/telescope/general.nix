[
  {
    mode = "n";
    key = "<Leader>ff";
    action.__raw = ''
      function()
        require('fff').find_files()
      end
    '';
    options = {
      desc = "find files";
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
  # TIP: USE <Shift-TAB> to cycle between live grep modes
  {
    mode = "n";
    key = "<leader>/";
    action.__raw = ''
      function()
        require('fff').live_grep({
          grep = {
            modes = { 'fuzzy', 'plain' }
          }
        })
      end
    '';
    options = {
      silent = true;
      desc = "fuzzy search";
    };
  }
  {
    mode = "n";
    key = "<leader>fg";
    action.__raw = ''
      function()
        require('fff').live_grep({
          grep = {
            modes = { 'regex', 'plain' }
          }
        })
      end
    '';
    options = {
      silent = true;
      desc = "regex search";
    };
  }
  # {
  #   mode = "n";
  #   key = "<leader>/";
  #   action.__raw = ''
  #     function()
  #       require('telescope.builtin')
  #         .live_grep(require('telescope.themes').get_ivy({}))
  #     end
  #   '';
  #   options = {
  #     silent = true;
  #     desc = "fuzzy search project";
  #   };
  # }
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
