require("../utils")

-- Configuration for lua plugins plugins
-- Will only load if plugins have loaded
if isModuleAvailable("nightfox") then
	vim.cmd("colorscheme carbonfox")
end
if isModuleAvailable("which-key") then
	require("../keys")
end
if isModuleAvailable("dashboard") then
	require("../ui/dashboard_config")
end

local on_attach = function(client)
	require("lsp-format").on_attach(client)
end

-- Godot
vim.g.godot_executable = "/opt/homebrew/bin/godot"

if isModuleAvailable("coq") and isModuleAvailable("lspconfig") then
	local coq = require("coq")
	local lspconfig = require("lspconfig")
	-- local rust_opts = require("plugins.lsp.rust_opts")

	require("neoconf").setup()
	-- rust_tools.setup(require("coq").lsp_ensure_capabilities(rust_opts))
	lspconfig.gdscript.setup(coq.lsp_ensure_capabilities())
	lspconfig.tsserver.setup(coq.lsp_ensure_capabilities({ on_attach = on_attach }))
	lspconfig.gopls.setup(coq.lsp_ensure_capabilities({ on_attach = on_attach }))
	vim.diagnostic.config({ virtual_text = false, virtual_lines = { only_current_line = true } })
	-- Format on save
	local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
end

-- Code Formatters
if isModuleAvailable("lint") then
	local lint = require("lint")

	local linters_by_ft = {
		nix = { "nix", "statix" },
		env = { "dotenv_linter" },
		git = { "gitlint" },
	}
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		callback = function()
			require("lint").try_lint()
		end,
	})
end

-- TO ADD: cbfmt, deadnix, dotenv_linter, gitsigns, gdlint, gdformat, gitlint
