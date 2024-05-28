{ pkgs, ... }:

let
  # Path to the original init.lua in your source folder
  initLua = ./dotfiles/insipx-nvim/init.lua;

  luarocksConfig = ''
     local rocks_config = {
        rocks_path = vim.fn.stdpath("data") .. "/rocks",
        luarocks_binary = "${pkgs.lua51Packages.luarocks}/bin/luarocks", 
    }

    vim.g.rocks_nvim = rocks_config

    local luarocks_path = {
        vim.fs.joinpath(rocks_config.rocks_path, "share", "lua", "5.1", "?.lua"),
        vim.fs.joinpath(rocks_config.rocks_path, "share", "lua", "5.1", "?", "init.lua"),
    }
    package.path = package.path .. ";" .. table.concat(luarocks_path, ";")

    local luarocks_cpath = {
        vim.fs.joinpath(rocks_config.rocks_path, "lib", "lua", "5.1", "?.so"),
        vim.fs.joinpath(rocks_config.rocks_path, "lib64", "lua", "5.1", "?.so"),
    }
    package.cpath = package.cpath .. ";" .. table.concat(luarocks_cpath, ";")

    if not vim.uv.fs_stat(rocks_config.rocks_path) then
      vim.system({
        rocks_config.luarocks_binary,
        "install",
        "--tree",
        rocks_config.rocks_path, 
        "--server='https://nvim-neorocks.github.io/rocks-binaries/'",
        "--lua-version=5.1",
        "rocks.nvim",
        }):wait()
    end

    vim.opt.runtimepath:append(vim.fs.joinpath(rocks_config.rocks_path, "lib", "luarocks", "rocks-5.1", "rocks.nvim", "*"))
  '';

  # New content combining the prependContent with the original init.lua content
  newInitLuaContent = luarocksConfig + builtins.readFile initLua;

in {

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    withPython3 = true;
    withNodeJs = true;
    withRuby = true;
    defaultEditor = true;
    extraPython3Packages = (ps: with ps; [ pynvim unidecode black isort ]);
    plugins = with pkgs.vimPlugins; [ coq_nvim ];
    extraPackages = with pkgs; [
      ripgrep
      tree-sitter
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
  };

  xdg.configFile = {
    "nvim/init.lua" = {
      # Use writeText to create a new file with the combined content
      text = newInitLuaContent;
    };
    "nvim/lua" = {
      source = ./dotfiles/insipx-nvim/lua;
      recursive = true;
    };
    "nvim/static" = {
      source = ./dotfiles/insipx-nvim/static;
      recursive = true;
    };
  };
}

