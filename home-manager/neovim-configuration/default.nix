{ pkgs, ... }:
let
  keybindings = import ./keybindings;
in
{
  imports = [
    #     (import ./neovim-configuration/lualine.nix { inherit config pkgs; })
  ];

  programs.nixvim = {
    enable = true;
    # package = pkgs.neovim;
    nixpkgs.useGlobalPackages = true;
    # nixpkgs.config.allowUnfree = true;
    extraPackages = with pkgs; [
      gcc
      ripgrep
      lua51Packages.luarocks
      lua51Packages.lua
      lua51Packages.cjson
      git

      # Formatters
      taplo
      stylua
      deno
      nodePackages.prettier
      # alejandra
      nixfmt
      rubyPackages.htmlbeautifier
      # codespell

      # Linters
      dotenv-linter
      gitlint
      html-tidy
      statix
      deadnix
      markdownlint-cli
      shellcheck
      golangci-lint
      # Other
      htop
      vscode-extensions.vadimcn.vscode-lldb
      viu # for FFF Picker
    ];
    extraPlugins = [ ];
    extraPython3Packages =
      ps: with ps; [
        pynvim
        unidecode
        black
        isort
      ];
    withNodeJs = true;
    withRuby = true;

    globals = {
      mapleader = " ";
      maplocalleader = ",";
      loaded_netrw = 1;
      loaded_matchparen = 1;
      loaded_netrwPlugin = 1;
      loaded_python_provider = 0;
      nocompatible = true;
      loaded_man = false;
      loaded_gzip = false;
      loaded_zipPlugin = false;
      loaded_tarPlugin = false;
      loaded-2html_plugin = false;
      loaded_remote_plugins = false;
    };

    opts = {
      relativenumber = true;
      number = true;
      hidden = true;
      hlsearch = true;
      backspace = [
        "indent"
        "eol"
        "start"
      ];
      laststatus = 3; # laststatus = 3 means a statusline per-window in neovim
      encoding = "utf-8";
      showtabline = 1;
      showmatch = true;
      list = true;
      signcolumn = "yes";
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
    };

    keymaps = [
      {
        key = "<Space>";
        action = "<Nop>";
        options.silent = true;
      }
    ]
    ++ keybindings.all
    ++ keybindings.desc;

    extraConfigLua = ''
      -- vim.opt.listchars:append "eol:↴"
      vim.opt.listchars:append "space:⋅"
    ''
    + builtins.readFile ./lua/conform.lua; # + builtins.readFile ./neovim-configuration/lua/lualine.lua;
    extraConfigVim = ''
      set exrc
    '';

    diagnostic.settings = {
      severity_sort = true;
      virtual_lines = {
        only_current_line = false;
      };
      virtual_text = false;
    };
    dependencies = {
      tree-sitter.enable = true;
      rust-analyzer = {
        enable = true;
        package = pkgs.rust-analyzer-nightly;
      };
      direnv.enable = true;
    };
    plugins = {
      lsp = {
        enable = true;
        servers = {
          nixd = {
            enable = true;
            filetypes = [ "nix" ];
            settings.formatting.command = [ "nixfmt" ];
          };
          gopls = {
            enable = true;
            filetypes = [ "go" ];
          };
          taplo = {
            enable = true;
            filetypes = [ "toml" ];
          };
        };
      };
      lsp-format.enable = true;
      #notify = {
      #  enable = true;
      #  fps = 60;
      #  render = "compact";
      #};
      fidget = {
        enable = true;
        settings = {
          notification = {
            override_vim_notify = true;
          };
        };
      };
      tiny-inline-diagnostic = {
        enable = false;
      };
      lspsaga.enable = true;
      blink-cmp = {
        enable = true;
      };
      blink-cmp-copilot = {
        enable = true;
      };
      coq-nvim = {
        enable = false;
        settings.auto_start = "shut-up";
        installArtifacts = true;
      };
      coq-thirdparty = {
        enable = false;
        settings = [
          {
            src = "copilot";
            short_name = "COP";
          }
        ];
      };
      dap = {
        enable = true;
      };
      dap-rr = {
        enable = true;
        settings.mappings = {
          continue = "<leader>rc";
          step_over = "<leader>rs";
          step_out = "<leader>rS";
          step_into = "<leader>ri";
          reverse_continue = "<leader>Rc";
          reverse_step_over = "<leader>Rs";
          reverse_step_out = "<leader>RS";
          reverse_step_into = "<leader>Ri";
          step_over_i = "<leader>ris";
          step_out_i = "<leader>riS";
          step_into_i = "<leader>rii";
          reverse_step_over_i = "<leader>Ris";
          reverse_step_out_i = "<leader>RiS";
          reverse_step_into_i = "<leader>Rii";
        };
      };
      dap-ui = {
        enable = true;
      };

      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = {
            lspFallback = true;
            timeoutMs = 350;
          };
          formatters_by_ft = {
            toml = [ "taplo" ];
            lua = [ "stylua" ];
            javascript = [ "prettier" ];
            typescript = [ "prettier" ];
            nix = [ "nixfmt" ];
            yaml = [ "prettier" ];
            html = [ "htmlbeautifier" ];
            markdown = [ "deno_fmt" ];
            json = [ "deno_fmt" ];
            "*" = [ "codespell" ];
          };
        };
      };

      lint = {
        enable = true;
        lintersByFt = {
          nix = [
            "nix"
            "statix"
          ];
          env = [ "dotenv_linter" ];
          git = [ "gitlint" ];
          json = [ "deno_fmt" ];
        };
      };

      direnv.enable = true;
      rustaceanvim = {
        enable = true;
        # Use fenix nightly rust-analalyzer
        settings.server = {
          load_vscode_settings = true;
          standalone = false;
          default_settings = {
            rust-analyzer = {
              cargo = {
                allTargets = false;
                buildScripts.enable = false;
                # features = "all";
              };
              checkOnSave = true;
              check = {
                command = "check";
                extraArgs = [ "--no-deps" ];
                features = "all";
              };
              procMacro = {
                enable = true;
                attributes.enable = true;
                ignored = {
                  "async-trait" = [ "async_trait" ];
                  "napi-derive" = [ "napi" ];
                  "async-recursion" = [ "async_recursion" ];
                  "ctor" = [ "ctor" ];
                  "tokio" = [ "test" ];
                };
              };
              diagnostics.disabled = [
                "unlinked-file"
                "unresolved-macro-call"
                "unresolved-proc-macro"
                "proc-macro-disabled"
                "proc-macro-expansion-error"
              ];
            };
          };
        };
        settings.tools = {
          enable_clippy = true;
          enable_nextest = false;
          executor = "toggleterm";
          test_executor = "toggleterm";
          reload_workspace_from_cargo_toml = true;
        };
      };
      vim-matchup = {
        enable = true;
        settings = {
          matchparen_defered = 1;
        };
      };
      crates = {
        enable = true;
        settings = {
          src = {
            coq = {
              enabled = false;
            };
          };
        };
      };

      bufferline = {
        enable = true;
        settings = {
          options = {
            mode = "buffers";
            numbers = "ordinal";
            indicator.style = "underline";
            diagnostics = "nvim_lsp";
          };
        };
      };
      alpha = {
        enable = true;
        theme = "startify";
      };
      lualine = {
        enable = true;
      };
      spectre.enable = true;
      oil.enable = true;

      neogit = {
        enable = true;
        settings = {
          integrations = {
            diffview = true;
            telescope = true;
          };
        };
      };
      gitsigns.enable = true;
      gitblame.enable = true;
      diffview.enable = true;
      octo.enable = true;
      fff = {
        enable = true;
      };
      telescope = {
        enable = true;
        extensions = {
          ui-select.enable = true;
          fzy-native.enable = true;
          media-files.enable = true;
        };
      };

      neorg = {
        enable = true;
        settings = {
          load = {
            "core.defaults" = {
              __empty = null;
            };
            "core.concealer" = {
              config = {
                icon_preset = "diamond";
              };
            };
            "core.dirman" = {
              config = {
                workspaces = {
                  work = "~/.notes/work";
                  home = "~/.notes/home";
                  xmtp = "~/.notes/xmtp";
                };
              };
            };
            "core.keybinds" = {
              config = {
                default_keybindings = true;
                neorg_leader = "<Space>";
              };
            };
            "core.export" = {
              __empty = null;
            };
            "core.export.markdown" = {
              config = {
                extensions = "all";
              };
            };
          };
        };
      };

      treesitter = {
        enable = true;
        grammarPackages = pkgs.vimPlugins.nvim-treesitter.passthru.allGrammars;
        nixGrammars = true;

        settings = {
          auto_install = true;
          highlight = {
            enable = true;
          };
          indent = {
            enable = true;
          };
          ensure_installed = [
            "rust"
            "javascript"
            "typescript"
            "sql"
            "c"
            "go"
            "protobuf"
            "nix"
            "toml"
          ];
        };
      };
      treesitter-textobjects.enable = true;
      treesitter-context = {
        enable = true;
        settings = {
          max_lines = 2;
        };
      };
      treesitter-refactor.enable = false; # TODO: can keymap bunch of cool stuff when want

      indent-blankline = {
        enable = false;
        settings = {
          scope = {
            enabled = true;
            show_start = true;
          };
          exclude.filetypes = [ "alpha" ];
        };
      };
      better-escape = {
        enable = true;
        settings.mappings = {
          # disable jj esc
          i.j.j = false;
        };
      };

      glow.enable = true;
      precognition = {
        enable = true;
      };
      mini = {
        enable = true;
        modules = {
          pairs = { };
          bracketed = { };
          bufremove = { };
          clue = {
            triggers = [
              {
                mode = "n";
                keys = "<Leader>";
              }
              {
                mode = "x";
                keys = "<Leader>";
              }
              {
                mode = "v";
                keys = "<Leader>";
              }
            ];
            clues = [
              "miniclue.gen_clues.builtin_completion()"
              "miniclue.gen_clues.g()"
              "miniclue.gen_clues.marks()"
              "miniclue.gen_clues.registers()"
              "miniclue.gen_clues.windows()"
              "miniclue.gen_clues.z()"
            ];
            window.delay = 500;
          };
          trailspace = { };
          basics = { };
          align = { };
          indentscope = { };
          hipatterns = {
            highlighters = {
              fixme = {
                pattern = "FIXME";
                group = "MiniHipatternsFixme";
              };
              hack = {
                pattern = "HACK";
                group = "MiniHipatternsHack";
              };
              todo = {
                pattern = "TODO";
                group = "MiniHipatternsTodo";
              };
              note = {
                pattern = "NOTE";
                group = "MiniHipatternsNote";
              };
            };
          };
          map = { };
          misc = { };
          icons = { };
        };
        mockDevIcons = true;
      };

      cursorline.enable = true;
      hop = {
        enable = true;
        settings.keys = "etovxqpdygfblzhckisuran";
      };

      toggleterm = {
        enable = true;
        settings = {
          shade_terminals = false;
          auto_scroll = true;
          autochdir = true;
          shade_filetypes = [
            "none"
          ];
          shade_terminal = false;
          start_in_insert = true;
        };
        luaConfig.post = ''
          local Terminal = require('toggleterm.terminal').Terminal
          local float_general = Terminal:new({
            hidden = true,
            name = "general",
            auto_scroll = true,
            direction = "float",
            dir = git_dir
          })
          local htop = Terminal:new({
            cmd = "htop",
            hidden = true,
            name = "htop",
            auto_scroll = false,
            direction = "float",
            dir = git_dir
          })
          function _toggle_float_general()
            float_general:toggle()
          end
          function _toggle_htop()
            htop:toggle()
          end
        '';
      };
      scope.enable = true;
    };
    #stabilize
    #vim-eunuch
    #colorschemes.nightfox = {
    #  enable = true;
    #  flavor = "carbonfox";
    #};
    colorschemes.catppuccin = {
      enable = true;
      autoLoad = true;
      settings = {
        flavour = "mocha";
        integrations = {
          treesitter = true;
          notify = true;
        };
      };
    };

    performance = {
      byteCompileLua = {
        enable = true;
        configs = true;
        initLua = true;
        nvimRuntime = true;
        plugins = true;
      };
    };
  };
}
