return {
	"tpope/vim-fugitive", -- git stuff, commit, etc
	{ -- magit, but for vim
		"NeogitOrg/neogit",
		branch = "nightly",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",
			"nvim-telescope/telescope.nvim",
			"ibhagwan/fzf-lua",
		},
		config = function()
			require("neogit").setup({
				config = true,
				integrations = { diffview = true, telescope = true },
				sections = {
					unstaged = { folded = true, hidden = false },
					unmerged_pushRemote = { folded = true, hidden = false },
				},
			})
		end,
	},
	{ "sindrets/diffview.nvim", dependencies = "nvim-lua/plenary.nvim" }, -- view diffs!
	{ -- 'tag = release' for stable neovim, main branch for nightly
		"lewis6991/gitsigns.nvim",
		branch = "main",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("gitsigns").setup()
		end,
	},
	{
		"pwntester/octo.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("octo").setup()
		end,
	},
}
