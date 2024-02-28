require("../utils")

local cmd = vim.cmd
local opt = vim.opt
local g = vim.g

-- BufExplorer
-- g.bufExplorerShowTabBuffer = 1
-- Coq
g.coq_settings = { auto_start = "shut-up" }

-- Dashboard
g.dashboard_default_executive = "telescope"

-- Colorscheme, neon
vim.g.neon_style = "dark"
vim.g.neon_italic_keyword = true
vim.g.neon_italic_function = true
