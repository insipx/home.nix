require("telescope").setup({
	defaults = { selection_caret = "" },
	pickers = { find_files = { theme = "ivy" } },
	extensions = {
		fzy_native = { override_generic_sorter = true, override_file_sorter = true },
		glyph = {
			action = function(glyph)
				vim.fn.setreg("*", glyph.value)
				vim.api.nvim_put({ glyph.value }, "c", false, true)
			end,
		},
		project = {
			theme = "ivy",
			base_dirs = {
				"~/projects",
			},
		},
		file_browser = { theme = "ivy", hijack_netrw = true },
	},
})
