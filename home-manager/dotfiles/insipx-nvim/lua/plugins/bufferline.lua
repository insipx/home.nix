require("bufferline").setup({
	options = {
		mode = "buffers",
		numbers = "ordinal",
		indicator = { style = "underline" },
		diagnostics = "nvim_lsp",
	},
	-- highlights = {indicator_selected = {fg = '', bg = '', bold = true}}
})
