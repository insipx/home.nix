-- TODO: Check if this is applied?
local lint = require("lint")

-- "Linters by filetype"
local linters_by_ft = {
	nix = { "nix", "statix" },
	env = { "dotenv_linter" },
	git = { "gitlint" },
}
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function()
		require("lint").try_lint()
	end,
})
