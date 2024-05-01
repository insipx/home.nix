require("neogit").setup({
	config = true,
	integrations = { diffview = true, telescope = true },
	sections = {
		unstaged = { folded = true, hidden = false },
		unmerged_pushRemote = { folded = true, hidden = false },
	},
})
