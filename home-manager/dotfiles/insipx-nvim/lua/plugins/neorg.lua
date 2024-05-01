return {
	{
		"vhyrro/luarocks.nvim",
		priority = 1000, -- We'd like this plugin to load first out of the rest
		config = true, -- This automatically runs `require("luarocks-nvim").setup()`
	},
	{
		"nvim-neorg/neorg",
		build = ":Neorg sync-parsers",
		dependencies = { "luarocks.nvim" },
		config = function()
			require("neorg").setup({
				load = {
					["core.defaults"] = {}, -- Loads default behaviour
					["core.concealer"] = { config = { icon_preset = "diamond" } }, -- Adds pretty icons to your documents
					["core.dirman"] = { -- Manages Neorg workspaces
						config = {
							workspaces = { work = "~/.notes/work", home = "~/.notes/home", xmtp = "~/.notes/xmtp" },
						},
					},
					["core.integrations.telescope"] = {},
					-- required by core.export.markdown
					["core.integrations.treesitter"] = {},
					["core.keybinds"] = { config = { default_keybindings = true, neorg_leader = "<Space>" } },
					["core.export"] = {},
					["core.export.markdown"] = { config = { extensions = "all" } },
				},
			})
		end,
	},
}
