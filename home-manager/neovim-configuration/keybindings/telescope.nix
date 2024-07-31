{ ... }: {
  config = [{
    group = "general";
    __unkeyed-1 = {
      group = "file";
      __unkeyed-1 = {
        __unkeyed-1 = "<leader>ff";
        __unkeyed-2 = {
          __raw =
            "function() require('telescope.builtin').find_files(require('telescope.themes').get_ivy({})) end";
        };
        desc = "find file";
      };
      __unkeyed-2 = {
        __unkeyed-1 = "<leader>fr";
        __unkeyed-2 = {
          __raw =
            "function() require('telescope.builtin').old_files(require('telescope.themes').get_ivy({})) end";
        };
        desc = "open recent file";
      };
      __unkeyed-3 = {
        __unkeyed-1 = "<leader>fb";
        __unkeyed-2 = {
          __raw =
            "function() require('telescope').extensions.file_browser.file_browser(require('telescope.themes').get_ivy({})) end";
        };
        desc = "browse files";
      };
      __unkeyed-4 = {
        __unkeyed-1 = "<leader>fm";
        __unkeyed-2 = {
          __raw =
            "function() require('telescope.builtin').marks(require('telescope.themes').get_ivy({})) end";
        };
        desc = "find marks";
      };
      __unkeyed-5 = {
        __unkeyed-1 = "<leader>fh";
        __unkeyed-2 = {
          __raw =
            "function() require('telescope.builtin').oldfiles(require('telescope.themes').get_ivy({})) end";
        };
        desc = "find history";
      };
    };
    __unkeyed-2 = {
      group = "buffer";
      __unkeyed-1 = {
        __unkeyed-1 = "<leader>bb";
        __unkeyed-2 = {
          __raw =
            "function() require('telescope.builtin').buffers(require('telescope.themes').get_ivy({})) end";
        };
        desc = "list buffers in current context";
      };
      __unkeyed-2 = {
        __unkeyed-1 = "<leader>bB";
        __unkeyed-2 = {
          __raw =
            "function() require('telescope').extensions.scope.buffers(require('telescope.themes').get_ivy({})) end";
        };
        desc = "list all buffers";
      };
      __unkeyed-3 = {
        __unkeyed-1 = "<leader>bt";
        __unkeyed-2 = {
          __raw =
            "function() require('telescope').extensions.tele_tabby.list(require('telescope.themes').get_ivy({})) end";
        };
        desc = "buffer search";
      };
    };
    __unkeyed-3 = {
      group = "search/quickfix";
      __unkeyed-1 = {
        __unkeyed-1 = "<leader>ql";
        __unkeyed-2 = {
          __raw =
            "function() require('telescope.builtin').quickfix(require('telescope.themes').get_ivy({})) end";
        };
        desc = "list items in the quickfix list";
      };
      __unkeyed-2 = {
        __unkeyed-1 = "<leader>qh";
        __unkeyed-2 = {
          __raw =
            "function() require('telescope.builtin').quickfixhistory(require('telescope.themes').get_ivy({})) end";
        };
        desc = "search through quick fix history";
      };
    };
    __unkeyed-4 = {
      group = "project";
      __unkeyed-1 = {
        __unkeyed-1 = "<leader>pf";
        __unkeyed-2 = {
          __raw =
            "function() require('telescope.builtin').git_files(require('telescope.themes').get_ivy({})) end";
        };
        desc = "find file in project";
      };
      __unkeyed-2 = {
        __unkeyed-1 = "<leader>pp";
        __unkeyed-2 = {
          __raw =
            "function() require('telescope').extensions.project.project({}) end";
        };
        desc = "Open Projects";
      };
    };
    __unkeyed-5 = {
      group = "LSP";
      __unkeyed-1 = {
        __unkeyed-1 = "<leader>lr";
        __unkeyed-2 = {
          __raw =
            "function() require('telescope.builtin').lsp_references(require('telescope.themes').get_ivy({})) end";
        };
        desc = "list references";
      };
    };
    __unkeyed-6 = {
      group = "diagnostics";
      __unkeyed-1 = {
        __unkeyed-1 = "<leader>Da";
        __unkeyed-2 = {
          __raw =
            "function() require('telescope.builtin').diagnostics(require('telescope.themes').get_ivy({})) end";
        };
        desc = "list diagnostics for all open buffers";
      };
      __unkeyed-2 = {
        __unkeyed-1 = "<leader>Dc";
        __unkeyed-2 = {
          __raw =
            "function() require('telescope.builtin').diagnostics({ theme = require('telescope.themes').get_ivy({}), bufnr = 0 }) end";
        };
        desc = "list diagnostics for currently open buffer";
      };
    };
    __unkeyed-7 = {
      group = "NeoVIM options";
      __unkeyed-1 = {
        __unkeyed-1 = "<leader>ec";
        __unkeyed-2 = {
          __raw =
            "function() require('telescope.builtin').commands(require('telescope.themes').get_ivy({})) end";
        };
        desc = "List available commands from vim/plugins";
      };
    };
    __unkeyed-8 = {
      __unkeyed-1 = "<leader>/";
      __unkeyed-2 = {
        __raw =
          "function() require('telescope.builtin').live_grep(require('telescope.themes').get_ivy({})) end";
      };
      desc = "search project";
    };
    __unkeyed-9 = {
      __unkeyed-1 = "<leader>H";
      __unkeyed-2 = {
        __raw =
          "function() require('telescope.builtin').search_history(require('telescope.themes').get_ivy({})) end";
      };
      desc = "telescope search history";
    };
  }];
}

