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
    # nixpkgs.useGlobalPackages = false;
    extraPackages = with pkgs; [
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
      nixfmt-rfc-style
      yamlfmt
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
      nodePackages_latest.jsonlint
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
      loaded_netrwPlugin = 1;
      loaded_python_provider = 0;
      nocompatible = true;
      loaded_man = false;
      loaded_gzip = false;
      loaded_zipPlugin = false;
      loaded_tarPlugin = false;
      loaded-2html_plugin = false;
      loaded_remote_plugins = false;
      coq_settings = {
        auto_start = "shut-up";
      };
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
    ] ++ keybindings.all ++ keybindings.desc;

    extraConfigLua = ''
      -- vim.opt.listchars:append "eol:↴"
      vim.opt.listchars:append "space:⋅"
    ''; # + builtins.readFile ./neovim-configuration/lua/lualine.lua;

    extraConfigVim = ''
      set exrc
    '';

    diagnostics = {
      severity_sort = true;
      virtual_lines = {
        only_current_line = true;
      };
      virtual_text = true;
    };
    plugins = {
      lsp = {
        enable = true;
        servers = {
          nixd = {
            enable = true;
            filetypes = [ "nix" ];
            settings.formatting.command = [ "nixpkgs-fmt" ];
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
      lspsaga.enable = true;
      #trouble = {
      #  enable = true;
      #  settings = {
      #    auto_refresh = true;
      #
      #  };
      #};
      coq-nvim = {
        enable = true;
        settings.auto_start = "shut-up";
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
            nix = [ "nixfmt-rfc-style" ];
            yaml = [ "yamlfmt" ];
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
          json = [ "jsonlint" ];
        };
      };

      direnv.enable = true;
      rustaceanvim = {
        enable = true;
        # Use fenix nightly rust-analalyzer
        rustAnalyzerPackage = pkgs.rust-analyzer-nightly;
        settings.server = {
          load_vscode_settings = true;
          standalone = false;
          default_settings = {
            rust-analyzer = {
              cargo = {
                allTargets = false;
                buildScripts.enable = true;
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
          enable_nextest = true;
          executor = "toggleterm";
          test_executor = "toggleterm";
        };
      };

      crates = {
        enable = true;
        settings = {
          src = {
            coq = {
              enabled = true;
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

      telescope = {
        enable = true;
        # enabledExtensions = [ "project" ];
        extensions = {
          file-browser.enable = true;
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
        #grammarPackages = pkgs.vimPlugins.nvim-treesitter.passthru.allGrammars;
        nixGrammars = true;
        languageRegister = { };

        settings = {
          auto_install = true;
          highlight = {
            enable = true;
          };
          indent = {
            enable = true;
          };
          #ensure_installed = [
          #  "rust"
          #  "javascript"
          #  "typescript"
          #  "sql"
          #  "c"
          #  "go"
          #  "protobuf"
          #];
        };
      };
      treesitter-textobjects.enable = true;
      treesitter-context = {
        enable = true;
        settings = {
          max_lines = 2;
        };
      };
      treesitter-refactor.enable = true; # TODO: can keymap bunch of cool stuff when want

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
      better-escape.enable = true;

      glow.enable = true;

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

      toggleterm.enable = true;
      scope.enable = true;

      #stabilize
      #vim-eunuch
    };
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
