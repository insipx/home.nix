{ config, pkgs, ... }:
let telescope = (import ./keybindings/telescope.nix { });
in {
  programs.nixvim.plugins.which-key = {
    enable = true;
    settings.spec = [
      {
        group = "file";
        __unkeyed-1 = {
          __unkeyed-1 = "<leader>ft";
          __unkeyed-2 = "<cmd>NvimTreeToggle<CR>";
          desc = "Toggle tree file browser";
        };
      }
      {
        group = "buffer";
        __unkeyed-1 = {
          __unkeyed-1 = "<leader>bn";
          __unkeyed-2 = "<cmd>bnext<CR>";
          desc = "next buffer";
        };
        __unkeyed-2 = {
          __unkeyed-1 = "<leader>bp";
          __unkeyed-2 = "<cmd>bprev<CR>";
          desc = "previous buffer";
        };
        __unkeyed-3 = {
          __unkeyed-1 = "<leader>bP";
          __unkeyed-2 = "<cmd>BufferLineTogglePin<CR>";
          desc = "Pin buffer to start of bufferline";
        };
        __unkeyed-4 = {
          __unkeyed-1 = "<leader>bk";
          __unkeyed-2 = "<cmd>Bdelete<CR>";
          desc = "close buffer";
        };
        __unkeyed-5 = {
          __unkeyed-1 = "<leader>ba";
          __unkeyed-2 = "<cmd>buffdo Bdelete<CR>";
          desc = "delete all buffers";
        };
      }
      {
        group = "search/quickfix";
        __unkeyed-1 = {
          __unkeyed-1 = "<leader>qo";
          __unkeyed-2 = "<cmd>copen<CR>";
          desc = "open the quickfix window";
        };
        __unkeyed-2 = {
          __unkeyed-1 = "<leader>qc";
          __unkeyed-2 = "<cmd>ccl<CR>";
          desc = "close the quickfix window";
        };
        __unkeyed-3 = {
          __unkeyed-1 = "<leader>qn";
          __unkeyed-2 = "<cmd>cn<CR>";
          desc = "go to next error in window";
        };
        __unkeyed-4 = {
          __unkeyed-1 = "<leader>qp";
          __unkeyed-2 = "<cmd>cp<CR>";
          desc = "go to previous error in window";
        };
        __unkeyed-5 = {
          __unkeyed-1 = "<leader>qs";
          __unkeyed-2 = {
            __raw = ''
              function()
                require('spectre').open_visual({ select_word = true })
              end'';
          };
          desc = "search and replace with Spectre. WARNING: COMMIT BEFOREHAND";
        };
      }
      {
        group = "commands (OS)";
        __unkeyed-1 = {
          __unkeyed-1 = "<leader>cn";
          __unkeyed-2 = "<cmd>enew<CR>";
          desc = "new file";
        };
        __unkeyed-2 = {
          __unkeyed-1 = "<leader>cr";
          __unkeyed-2 = { __raw = "function() rename() end"; };
          desc = "rename file";
        };
      }
      {
        group = "project";
        __unkeyed-1 = {
          group = "Tree Explorer";
          __unkeyed-1 = {
            __unkeyed-1 = "<leader>ptt";
            __unkeyed-2 = "<cmd>CHADopen<CR>";
            desc = "open Tree Explorer";
          };
          __unkeyed-2 = {
            __unkeyed-1 = "<leader>ptk";
            __unkeyed-2 = "<cmd>CHADhelp keybind<CR>";
            desc = "open help dialogue for tree binds";
          };
        };
        __unkeyed-2 = {
          group = "Diagnostic Sidebar";
          __unkeyed-1 = {
            __unkeyed-1 = "<leader>psr";
            __unkeyed-2 = "<cmd>SidebarNvimUpdate<CR>";
            desc = "update diagnostic sidebar";
          };
          __unkeyed-2 = {
            __unkeyed-1 = "<leader>pst";
            __unkeyed-2 = "<cmd>SidebarNvimToggle<CR>";
            desc = "toggle diagnostic sidebar";
          };
        };
        __unkeyed-3 = {
          __unkeyed-1 = "<leader>pd";
          __unkeyed-2 = "<cmd>TroubleToggle<CR>";
          desc = "toggle error quickfix";
        };
      }
      {
        group = "window";
        __unkeyed-1 = {
          __unkeyed-1 = "<leader>wh";
          __unkeyed-2 = "<C-W>h";
          desc = "left";
        };
        __unkeyed-2 = {
          __unkeyed-1 = "<leader>wl";
          __unkeyed-2 = "<C-W>l";
          desc = "right";
        };
        __unkeyed-3 = {
          __unkeyed-1 = "<leader>wj";
          __unkeyed-2 = "<C-W>j";
          desc = "down";
        };
        __unkeyed-4 = {
          __unkeyed-1 = "<leader>wk";
          __unkeyed-2 = "<C-W>k";
          desc = "up";
        };
        __unkeyed-5 = {
          __unkeyed-1 = "<leader>wv";
          __unkeyed-2 = "<C-w>v";
          desc = "vertical split";
        };
        __unkeyed-6 = {
          __unkeyed-1 = "<leader>ws";
          __unkeyed-2 = "<C-w>s";
          desc = "horizontal split";
        };
        __unkeyed-7 = {
          __unkeyed-1 = "<leader>wq";
          __unkeyed-2 = "<cmd>q<cr>";
          desc = "close";
        };
        __unkeyed-8 = {
          __unkeyed-1 = "<leader>w=";
          __unkeyed-2 = "<C-w>=";
          desc = "balance windows";
        };
        __unkeyed-9 = {
          __unkeyed-1 = "<leader>wL";
          __unkeyed-2 = "<C-w>>2";
          desc = "resize right";
        };
        __unkeyed-10 = {
          __unkeyed-1 = "<leader>wH";
          __unkeyed-2 = "<C-w><2";
          desc = "resize left";
        };
        __unkeyed-11 = {
          __unkeyed-1 = "<leader>wJ";
          __unkeyed-2 = "<C-w>+2";
          desc = "resize down";
        };
        __unkeyed-12 = {
          __unkeyed-1 = "<leader>wK";
          __unkeyed-2 = "<C-w>-2";
          desc = "resize up";
        };
      }
      {
        group = "terminal";
        __unkeyed-1 = {
          __unkeyed-1 = "<leader>tt";
          __unkeyed-2 =
            "<cmd>ToggleTerm size=20 dir=git_dir direction=horizontal<CR>";
          desc = "toggle terminal";
        };
        __unkeyed-2 = {
          __unkeyed-1 = "<leader>tf";
          __unkeyed-2 = "<cmd>Telescope toggleterm<CR>";
          desc = "find open terminal";
        };
      }
      {
        group = "insert";
        __unkeyed-1 = {
          __unkeyed-1 = "<leader>ic";
          __unkeyed-2 = "+y";
          desc = "to clipboard";
        };
        __unkeyed-2 = {
          __unkeyed-1 = "<leader>iy";
          __unkeyed-2 = ''"+p'';
          desc = "from clipboard";
        };
        __unkeyed-3 = {
          __unkeyed-1 = "<leader>ir";
          __unkeyed-2 = "<cmd>Telescope registers<CR>";
          desc = "from register";
        };
      }
      {
        group = "LSP";
        __unkeyed-1 = {
          group = "toggles";
          __unkeyed-1 = {
            __unkeyed-1 = "<leader>lTl";
            __unkeyed-2 = {
              __raw = "function() require('lsp_lines').toggle() end";
            };
            desc = "toggle lsp_lines virtual text";
          };
        };
        __unkeyed-2 = {
          __unkeyed-1 = "<leader>la";
          __unkeyed-2 = "<CMD>Lspsaga code_action<CR>";
          desc = "select code action";
        };
        __unkeyed-3 = {
          __unkeyed-1 = "<leader>lf";
          __unkeyed-2 = { __raw = "function() vim.lsp.buf.format() end"; };
          desc = "format buffer";
        };
        __unkeyed-4 = {
          __unkeyed-1 = "<leader>ld";
          __unkeyed-2 = "<CMD>Lspsaga hover_doc<CR>";
          desc = "Show documentation";
        };
        __unkeyed-5 = {
          __unkeyed-1 = "<leader>lo";
          __unkeyed-2 = "<CMD>Lspsaga outline<CR>";
          desc = "Show outline";
        };
        __unkeyed-6 = {
          __unkeyed-1 = "<leader>ls";
          __unkeyed-2 = "<CMD>SymbolsOutline<CR>";
          desc = "toggle symbols outline";
        };
        __unkeyed-7 = {
          group = "GitHub Copilot";
          __unkeyed-1 = {
            __unkeyed-1 = "<leader>lcn";
            __unkeyed-2 = "<Plug>(copilot-next)<CR>";
            desc = "next suggestion";
          };
          __unkeyed-2 = {
            __unkeyed-1 = "<leader>lcp";
            __unkeyed-2 = "<Plug>(copilot-prev)<CR>";
            desc = "previous suggestion";
          };
          __unkeyed-3 = {
            __unkeyed-1 = "<leader>lcd";
            __unkeyed-2 = "<Plug>(copilot-dismiss)<CR>";
            desc = "dismiss suggestion";
          };
        };
      }
      {
        group = "NeoVIM options";
        __unkeyed-1 = {
          __unkeyed-1 = "<leader>es";
          __unkeyed-2 = "<CMD> source $MYVIMRC<CR>";
          desc = "Source vim config";
        };
      }
      {
        group = "workspace";
        __unkeyed-1 = {
          __unkeyed-1 = "<leader><Tab>n";
          __unkeyed-2 = "<cmd>tabedit<cr>";
          desc = "new workspace";
        };
        __unkeyed-2 = {
          __unkeyed-1 = "<leader><Tab>d";
          __unkeyed-2 = "<cmd>tabclose<cr>";
          desc = "close workspace";
        };
        __unkeyed-3 = {
          __unkeyed-1 = "<leader><Tab>]";
          __unkeyed-2 = "<cmd>tabn<cr>";
          desc = "next workspace";
        };
        __unkeyed-4 = {
          __unkeyed-1 = "<leader><Tab>[";
          __unkeyed-2 = "<cmd>tabp<cr>";
          desc = "previous workspace";
        };
        __unkeyed-5 = {
          __unkeyed-1 = "<leader><Tab><Right>";
          __unkeyed-2 = ":tabm +1<CR>";
          desc = "move workspace to the right";
        };
        __unkeyed-6 = {
          __unkeyed-1 = "<leader><Tab><Left>";
          __unkeyed-2 = ":tabm -1<CR>";
          desc = "move workspace to the left";
        };
      }
      {
        __unkeyed-1 = "<leader>?";
        __unkeyed-2 = "<cmd>Cheatsheet<CR>";
        desc = "time to CHEAT!!!";
      }
      {
        __unkeyed-1 = "<leader>ic";
        __unkeyed-2 = ''"+y'';
        desc = "copy to clipboard";
        mode = {
          __unkeyed-1 = "n";
          __unkeyed-2 = "v";
        };
      }
      {
        group = "goto";
        __unkeyed-1 = {
          __unkeyed-1 = "<leader>gp";
          __unkeyed-2 = "<cmd>Lspsaga peek_definition<CR>";
          desc = "peek definition";
        };
        __unkeyed-2 = {
          __unkeyed-1 = "<leader>gr";
          __unkeyed-2 = "<cmd>Lspsaga rename ++project<CR>";
          desc = "rename occurrences of hovered word for selected files";
        };
        __unkeyed-3 = {
          __unkeyed-1 = "<leader>gt";
          __unkeyed-2 = "<cmd>Lspsaga peek_type_definition<CR>";
          desc = "Peek type definition in floating window";
        };
        __unkeyed-4 = {
          __unkeyed-1 = "<leader>gh";
          __unkeyed-2 = "<cmd>Lspsaga lsp_finder<CR>";
          desc = "find symbols definition";
        };
      }
    ] ++ telescope.config;
  };
}
