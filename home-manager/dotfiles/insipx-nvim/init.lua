require("utils")
if vim.g.vscode then
	print("vscode")
else
	require("setup.vim_opts")
	-- bootstrap plugin manager
	-- require("setup.lazy_boostrap")()
	-- require("lazy").setup("plugins", require("setup.lazy_opts"))
	if Utils:isModuleAvailable("impatient") then
		require("impatient")
	end
--	require("setup.plugin_opts")
--	require("setup.plugin_config")

	vim.g.bufExplorerShowTabBuffer = 1
end

