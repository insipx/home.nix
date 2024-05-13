require("../utils")

local opts = {
	tools = {
		inlay_hints = { only_current_line = true, show_variable_name = true },
		hover_actions = { auto_focus = true },
	},
	server = {
		on_attach = function(client, bufnr)
			Keybindings:rust_lsp()
		end,
		default_settings = {
			["rust-analyzer"] = {
				cargo = {
					allFeatures = true,
					loadOutDirsFromCheck = true,
					runBuildScripts = true,
				},
				checkOnSave = true,
				check = {
					command = "clippy",
					extraArgs = { "--no-deps" },
					features = "all",
				},
				procMacro = {
					enable = true,
					attributes = { enable = true },
					ignored = {
						["async-trait"] = { "async_trait" },
						["napi-derive"] = { "napi" },
						["async-recursion"] = { "async_recursion" },
						["ctor"] = { "ctor" },
						["tokio"] = { "test" },
					},
				},
			},
		},
	},
}
vim.g.rustaceanvim = vim.tbl_deep_extend("force", {}, opts or {})
