require("neorg").setup({
	load = {
		["core.defaults"] = {}, -- Loads default behaviour
		["core.concealer"] = { config = { icon_preset = "diamond" } }, -- Adds pretty icons to your documents
		["core.dirman"] = { -- Manages Neorg workspaces
			config = { workspaces = { work = "~/.notes/work", home = "~/.notes/home", xmtp = "~/.notes/xmtp" } },
		},
		-- ["core.integrations.telescope"] = {},
		-- required by core.export.markdown
		-- ["core.integrations.treesitter"] = {},
		["core.keybinds"] = { config = { default_keybindings = true, neorg_leader = "<Space>" } },
		["core.export"] = {},
		["core.export.markdown"] = { config = { extensions = "all" } },
	},
})
