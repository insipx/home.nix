require("utils")
if vim.g.vscode then
	print("vscode")
else
	require("setup.vim_opts")
	if Utils:isModuleAvailable("impatient") then
		require("impatient")
	end
	require("setup.plugin_opts")
	require("setup.plugin_config")

	vim.g.bufExplorerShowTabBuffer = 1
end

