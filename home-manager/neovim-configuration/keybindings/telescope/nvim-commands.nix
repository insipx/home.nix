[{
  mode = "n";
  key = "<leader>ec";
  action.__raw = ''
    function() 
      require('telescope.builtin')
        .commands(require('telescope.themes').get_ivy({})) 
    end
  '';
  options = {
    silent = true;
    desc = "List available commands from vim/plugins";
  };
}]
