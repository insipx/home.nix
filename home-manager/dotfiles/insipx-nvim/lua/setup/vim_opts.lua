require("../utils")
vim.g.mapleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

local cmd = vim.cmd
local opt = vim.opt
local g = vim.g

------------------------ MAPPINGS ---------------------------------
Utils:map("i", "jk", "<esc>") -- remap esc
Utils:map("", "<leader>ic", '"+y') -- Copy to clipboard in normal, visual, select and operator modes

----------------------- Tabs and Spaces ---------------------------
opt.shiftwidth = 2
opt.tabstop = 2
opt.expandtab = true

------------------------ options/aliases ---------------------------
g.loaded_python_provider = 0
opt.number = true
opt.relativenumber = true
opt.hidden = true
opt.hlsearch = true
opt.backspace = { "indent", "eol", "start" }
-- opt.guifont = "Monaspace Neon:h14,NerdFontsSymbolsOnly"
opt.laststatus = 3
opt.encoding = "utf-8"
opt.showtabline = 1
opt.showmatch = true
opt.list = true
opt.signcolumn = "yes"
-- opt.listchars:append "eol:↴"
opt.listchars:append("space:⋅")

g.nocompatible = true
-- Disable some unused built-in Neovim plugins
g.loaded_man = false
g.loaded_gzip = false
g.loaded_tarPlugin = false
g.loaded_zipPlugin = false
g.loaded_2html_plugin = false
g.loaded_remote_plugins = false
