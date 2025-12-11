[
  {
    mode = "n";
    key = "<leader>Da";
    action.__raw = ''
      function()
        require('telescope.builtin')
          .diagnostics(require('telescope.themes').get_ivy({}))
      end
    '';
    options = {
      silent = true;
      desc = "list diagnostics for all open buffers";
    };
  }

  {
    mode = "n";
    key = "<leader>Dc";
    action.__raw = ''
      function()
        require('telescope.builtin')
          .diagnostics({ theme = require('telescope.themes').get_ivy({}), bufnr = 0 }) 
      end
    '';
    options = {
      silent = true;
      desc = "list diagnostics for currently open buffer";
    };
  }
]
