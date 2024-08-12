{ config, pkgs, ... }: {
  imports = [
    (import ./neovim-configuration/which-key.nix { inherit config pkgs; })
    #     (import ./neovim-configuration/lualine.nix { inherit config pkgs; })
  ];

  programs.nixvim = {
    enable = true;
    package = pkgs.neovim;

    extraPackages = with pkgs; [
      ripgrep
      lua51Packages.luarocks
      lua51Packages.lua
      git

      # Formatters
      dprint
      stylua
      deno
      nixfmt
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
    ];
    extraPython3Packages = (ps: with ps; [ pynvim unidecode black isort ]);
    withNodeJs = true;
    withRuby = true;

    globals = {
      mapleader = " ";
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
      coq_settings = { auto_start = "shut-up"; };
    };

    opts = {
      relativenumber = true;
      number = true;
      hidden = true;
      hlsearch = true;
      backspace = [ "indent" "eol" "start" ];
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

    extraConfigLua = ''
      -- vim.opt.listchars:append "eol:↴"
      vim.opt.listchars:append "space:⋅"
    ''; # + builtins.readFile ./neovim-configuration/lua/lualine.lua;

    extraPlugins = with pkgs.vimPlugins; [
      telescope-project-nvim
      neoconf-nvim
    ];

    plugins = {
      lsp = {
        enable = true;
        preConfig = ''
          require('neoconf').setup()
        '';
      };
      lsp-format.enable = true;
      fidget = {
        enable = true;
        integration.nvim-tree.enable = true;
      };

      coq-nvim = {
        enable = true;
        settings.auto_start = "shut-up";
      };

      trouble.enable = true;
      lspsaga.enable = true;
      conform-nvim = {
        enable = true;
        formattersByFt = {
          toml = [ "dprint" ];
          lua = [ "stylua" ];
          javascript = [ "deno_fmt" ];
          nix = [ "nixfmt" ];
          yaml = [ "yamlfmt" ];
          html = [ "htmlbeautifier" ];
          markdown = [ "deno_fmt" ];
          "*" = [ "codespell" ];
        };
        formatOnSave = {
          lspFallback = true;
          timeoutMs = 500;
        };
      };

      lint = {
        enable = true; # nvim-lint
        lintersByFt = {
          nix = [ "nix" "statix" ];
          env = [ "dotenv_linter" ];
          git = [ "gitlint" ];
        };
      };

      nvim-tree = {
        enable = true;
        diagnostics.enable = true;
      };

      direnv.enable = true;

      rustaceanvim = {
        enable = true;
        settings.server = {
          load_vscode_settings = true;
          tools = { test_executor = "toggleterm"; };
          default_settings = {
            rust-analyzer = {
              cargo = {
                allTargets = true;
                buildScripts.enable = true;
                features = "all";
              };
              checkOnSave = true;
              check = {
                command = "clippy";
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
                  "async-stream" = [ "stream" "try_stream" ];
                };
              };
            };
          };
        };
      };

      crates-nvim = {
        enable = true;
        extraOptions = { src = { coq = { enabled = true; }; }; };
      };

      bufferline = {
        enable = true;
        mode = "buffers";
        numbers = "ordinal";
        indicator.style = "underline";
        diagnostics = "nvim_lsp";
      };
      alpha = {
        enable = true;
        theme = "startify";
      };
      lualine = { enable = true; };

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
      diffview.enable = true;
      octo.enable = true;

      telescope = {
        enable = true;
        enabledExtensions = [ "project" ];
        extensions = {
          file-browser.enable = true;
          ui-select.enable = true;
          fzy-native.enable = true;
          media-files.enable = true;
        };
      };

      neorg = {
        enable = true;
        lazyLoading = true;
        modules = {
          "core.defaults" = { __empty = null; };
          "core.concealer" = { config = { icon_preset = "diamond"; }; };
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
          "core.export" = { __empty = null; };
          "core.export.markdown" = { config = { extensions = "all"; }; };
        };
      };

      treesitter = {
        enable = true;
        grammarPackages = with pkgs.tree-sitter-grammars; [
          tree-sitter-rust
          tree-sitter-go
          tree-sitter-javascript
          tree-sitter-zig
          tree-sitter-json
          tree-sitter-yaml
          tree-sitter-toml
          tree-sitter-sql
          tree-sitter-nix
          tree-sitter-lua
          tree-sitter-fish
          tree-sitter-bash
          tree-sitter-norg-meta
          tree-sitter-org-nvim
          tree-sitter-markdown
          tree-sitter-dockerfile
          tree-sitter-proto
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.tree-sitter-norg
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.tree-sitter-norg-meta
          pkgs.vimPlugins.nvim-treesitter-parsers.jsonc
        ];
        nixGrammars = true;

        settings = {
          auto_install = true;
          highlight = { enable = true; };
          indent = { enable = true; };
          ensure_installed = [
            "rust"
            "toml"
            "go"
            "lua"
            "bash"
            "json"
            "yaml"
            "sql"
            "nix"
            "fish"
            "norg-meta"
            "markdown"
            "org-nvim"
            "dockerfile"
            "javascript"
            "zig"
            "proto"
          ];
        };
      };
      treesitter-textobjects.enable = true;
      indent-blankline = {
        enable = true;
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
        modules = { animate = { }; };
      };
      cursorline.enable = true;
      # like 'hop.nvim' but better featured and integrated with treesitter/nightfox
      # leap.enable = true;
      hop = {
        enable = true;
        settings.keys = "etovxqpdygfblzhckisuran";
      };

      bufdelete.enable = true;

      toggleterm.enable = true;

      #scope.nvim
      #stabilize
      #vim-rooter
      #vim-eunuch
      #vim easy-align
      #move.nvim

    };
    colorschemes.nightfox = {
      enable = true;
      flavor = "carbonfox";
    };
  };
}

