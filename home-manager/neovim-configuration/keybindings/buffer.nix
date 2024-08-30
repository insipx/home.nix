{ ... }: [
  {
    mode = "n";
    key = "<leader>bn";
    action = "<cmd>bnext<CR>";
    options = {
      silent = true;
      desc = "next buffer";
    };
  }
  {
    mode = "n";
    key = "<leader>bp";
    action = "<cmd>bprev<CR>";
    options = {
      silent = true;
      desc = "previous buffer";
    };
  }
  {
    mode = "n";
    key = "<leader>bP";
    action = "<cmd>BufferLineTogglePin<CR>";
    options = {
      silent = true;
      desc = "Pin buffer to start of bufferline";
    };
  }
  {
    mode = "n";
    key = "<leader>bk";
    action.__raw = "require('mini.bufremove').delete()";
    options = {
      silent = true;
      desc = "Pin buffer to start of bufferline";
    };
  }
  {
    mode = "n";
    key = "<leader>ba";
    action.__raw = ''
      for i, buf_hndl in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf_hndl) then
            require('mini.bufremove').delete(buf_hndl)
          end
      end
    '';
    options = {
      silent = true;
      desc = "Delete all open buffers";
    };
  }
]
