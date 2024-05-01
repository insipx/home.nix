local telescope = require("telescope.builtin")
local tele_themes = require("telescope.themes")
local tele_ext = require("telescope").extensions
local wk = require("which-key")

wk.register({
	["<leader>"] = {
		name = "general",
		f = {
			name = "file",
			f = {
				function()
					telescope.find_files(tele_themes.get_ivy({}))
				end,
				"find file",
			},
			r = {
				function()
					telescope.old_files(tele_themes.get_ivy({}))
				end,
				"open recent file",
			},
			b = {
				function()
					tele_ext.file_browser.file_browser(tele_themes.get_ivy({}))
				end,
				"browse files",
			},
			m = {
				function()
					telescope.marks(tele_themes.get_ivy({}))
				end,
				"find marks",
			},
			h = {
				function()
					telescope.oldfiles(tele_themes.get_ivy({}))
				end,
				"find history",
			},
			-- c = { "<cmd> Telescope frecency<cr>", 	"use frecency to find frequently-used files" },
			-- p = { "<cmd> Telescope ports<cr>", 	"find open ports, kill process with <CTRL>-K" },
		},
		b = {
			name = "buffer",
			b = {
				function()
					telescope.buffers(tele_themes.get_ivy({}))
				end,
				"list buffers in current context",
			},
			B = {
				function()
					tele_ext.scope.buffers(tele_themes.get_ivy({}))
				end,
				"list all buffers",
			},
			t = {
				function()
					tele_ext.tele_tabby.list(tele_themes.get_ivy({}))
				end,
				"buffer search",
			},
		},
		q = {
			name = "search/quickfix",
			l = {
				function()
					telescope.quickfix(tele_themes.get_ivy({}))
				end,
				"list items in the quickfix list",
			},
			h = {
				function()
					telescope.quickfixhistory(tele_themes.get_ivy({}))
				end,
				"search through quick fix history",
			},
		},
		p = {
			name = "project",
			f = {
				function()
					telescope.git_files(tele_themes.get_ivy({}))
				end,
				"find file in project",
			},
			p = {
				function()
					tele_ext.project.project({})
				end,
				"Open Projects",
			},
		},
		l = {
			name = "LSP",
			r = {
				function()
					telescope.lsp_references(tele_themes.get_ivy({}))
				end,
				"list references",
			},
		},
		D = {
			name = "diagnostics",
			a = {
				function()
					telescope.diagnostics(tele_themes.get_ivy({}))
				end,
				"list diagnostics for all open buffers",
			},
			c = {
				function()
					telescope.diagnostics({ theme = tele_themes.get_ivy({}), bufnr = 0 })
				end,
				"list diagnostics for currently open buffer",
			},
		},
		e = {
			name = "NeoVIM options",
			c = {
				function()
					telescope.commands(tele_themes.get_ivy({}))
				end,
				"List available commands from vim/plugins",
			},
		},
		["/"] = {
			function()
				telescope.live_grep(tele_themes.get_ivy({}))
			end,
			"search project",
		},
		["H"] = {
			function()
				telescope.search_history(tele_themes.get_ivy({}))
			end,
			"telescope search history",
		},
	},
})
