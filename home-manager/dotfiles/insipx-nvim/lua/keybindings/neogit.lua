local wk = require("which-key")
local neogit = require("neogit")

wk.register({
	["<leader>"] = {
		g = {
			name = "git",
			g = {
				function()
					neogit.open()
				end,
				"neogit status",
			},
			G = {
				function()
					neogit.open({ kind = "split" })
				end,
				"neogit status split",
			},
			c = {
				function()
					neogit.open({ "commit" })
				end,
				"neogit commit",
			},
			f = {
				name = "Git forge, octo",
				p = { "<cmd>Octo pr list<CR>", "List PR's from this repository" },
				i = { "<cmd>Octo issue list<CR>", "List issues from this repo" },
			},
		},
	},
})
