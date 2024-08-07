Utils = {}

function Utils:map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- The function is called `t` for `termcodes`.
-- You don't have to call it that, but I find the terseness convenient
function Utils:termcode(str)
	-- Adjust boolean arguments as needed
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

function Utils:isModuleAvailable(name)
	if package.loaded[name] then
		return true
	else
		for _, searcher in ipairs(package.searchers or package.loaders) do
			local loader = searcher(name)
			if type(loader) == "function" then
				package.preload[name] = loader
				return true
			end
		end
		return false
	end
end

-- returns the require for use in `config` parameter of lazy's use
-- expects the name of the config file
function Utils:get_setup(name)
	return function()
		require("setup.plugins." .. name)
	end
end
