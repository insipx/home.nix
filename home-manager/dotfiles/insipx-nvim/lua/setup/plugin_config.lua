require("../utils")

-- Configuration for lua plugins plugins
-- Will only load if plugins have loaded
if isModuleAvailable("neon") then
	vim.cmd("colorscheme neon")
end
if isModuleAvailable("which-key") then
	require("../keys/keybinds")
end
if isModuleAvailable("dashboard_config") then
	require("../ui/dashboard_config")
end

local on_attach = function(client)
	require("lsp-format").on_attach(client)

	-- ... anything else ...
end

-- Godot
vim.g.godot_executable = "/opt/homebrew/bin/godot"

if isModuleAvailable("coq") and isModuleAvailable("lspconfig") and isModuleAvailable("rust-tools") then
	local coq = require("coq")
	local lspconfig = require("lspconfig")
	local rust_tools = require("rust-tools")
	local rust_opts = require("plugins.lsp.rust_opts")

	require("neoconf").setup()
	rust_tools.setup(require("coq").lsp_ensure_capabilities(rust_opts))
	lspconfig.gdscript.setup(coq.lsp_ensure_capabilities())
	lspconfig.tsserver.setup(coq.lsp_ensure_capabilities({ on_attach = on_attach }))
	lspconfig.gopls.setup(coq.lsp_ensure_capabilities({ on_attach = on_attach }))
	vim.diagnostic.config({ virtual_text = false, virtual_lines = { only_current_line = true } })
	-- Format on save
	local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
end

-- Code Formatters
if isModuleAvailable("conform") then
	local conform = require("conform")

	local formatters_by_ft = {
		toml = { "dprint" }, -- bin: dprint
		lua = { "stylua" }, --bin: stylua
		javascript = { "deno_fmt" }, -- bin: deno
		nix = { "nixfmt" }, -- nixfmt
		yaml = { "yamlfmt" },
		html = { "htmlbeautifier" }, --bin: htmlbeautifier
		markdown = { "deno_fmt" },
		["*"] = { "codespell" }, --bin: codespell

		-- null_ls.builtins.formatting.cbfmt, -- bin: cbfmt (for formatting codeblocks in markdown)
		-- null_ls.builtins.formatting.dotenv_linter, -- bin: dotenv-linter
		-- null_ls.builtins.code_actions.gitsigns, -- bin: git
		-- null_ls.builtins.diagnostics.gdlint, -- bin: gdlint
		-- null_ls.builtins.formatting.gdformat, -- bin: gdformat
		-- null_ls.builtins.diagnostics.gitlint, -- bin: gitlint
		-- null_ls.builtins.diagnostics.tidy, -- bin: tidy-html5
		-- null_ls.builtins.diagnostics.tsc, -- bin: tsc
	}
	conform.formatters.codespell = {
		prepend_args = { "--config", "~/.config/codespellrc" },
	}
	conform.setup({
		formatters_by_ft = formatters_by_ft,
		format_on_save = {
			timeout_ms = 500,
			lsp_fallback = true,
		},
	})
end

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
