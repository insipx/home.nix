-- Code Formatter. keywords: format, fmt, beautify

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
