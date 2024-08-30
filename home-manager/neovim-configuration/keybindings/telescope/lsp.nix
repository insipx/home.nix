{ ... }: [{
  mode = "n";
  key = "<leader>lr";
  action.__raw = ''
    function() 
      require('telescope.builtin')
        .lsp_references(require('telescope.themes').get_ivy({})) 
    end
  '';
  options = {
    silent = true;
    desc = "list references";
  };
}]
