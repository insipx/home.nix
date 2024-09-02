[
  {
    mode = "n";
    key = "<Leader>bn";
    action = "<cmd>bnext<CR>";
    options = {
      silent = true;
      desc = "next buffer";
    };
  }
  {
    mode = "n";
    key = "<Leader>bp";
    action = "<cmd>bprev<CR>";
    options = {
      silent = true;
      desc = "previous buffer";
    };
  }
  {
    mode = "n";
    key = "<Leader>bP";
    action = "<cmd>BufferLineTogglePin<CR>";
    options = {
      silent = true;
      desc = "Pin buffer to start of bufferline";
    };
  }
  {
    mode = "n";
    key = "<Leader>bk";
    action.__raw = "require('mini.bufremove').delete";
    options = {
      silent = true;
      desc = "delete buffer";
    };
  }

  {
    mode = "n";
    key = "<Leader>ba";
    action.__raw = ''
       function()
         for i, buf_hndl in ipairs(vim.api.nvim_list_bufs()) do
             if vim.api.nvim_buf_is_loaded(buf_hndl) then
               require('mini.bufremove').delete(buf_hndl)
             end
         end
      end
    '';
    options = {
      silent = true;
      desc = "Delete all open buffers";
    };
  }
]
