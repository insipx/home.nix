return {
	-- Javascript
	"editorconfig/editorconfig-vim", --[[ Godot/GdScript --]]
	"habamax/vim-godot",
	"preservim/vim-markdown", -- syntax highlighting/matching

	{
		"andythigpen/nvim-coverage",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			opts = {
				auto_reload = true,
				load_coverage_cb = function()
					vim.notify("Loaded " .. fttype .. " coverage")
				end,
				lcov_file = "project.coverage",
			}
			require("coverage").setup()
		end,
	},
}
