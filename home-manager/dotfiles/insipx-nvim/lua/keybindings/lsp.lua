local wk = require("which-key")

-- this goes in to the "on_attach" function for the rust lsp
function Keybindings:rust_lsp()
	wk.register({
		["<leader>"] = {
			l = {
				r = {
					name = "rust",
					h = {
						function()
							vim.cmd.rustlsp({ "hover", "actions" })
						end,
						"trigger actions on hover",
					},
					r = {
						function()
							vim.cmd.rustlsp("runnables")
						end,
						"list runnables in buffer",
					},
					c = {
						function()
							vim.cmd.rustlsp("opencargo")
						end,
						"open the cargo.toml for the current buffer project",
					},
					p = {
						function()
							vim.cmd.rustlsp("parentmodule")
						end,
						"go to the parent module",
					},
					s = {
						function()
							vim.cmd.rustlsp({ "ssr" })
						end,
						"structural search & replace",
					},
					d = {
						function()
							vim.cmd.rustlsp("renderdiagnostic")
						end,
						"render the diagnostic as in cargo build",
					},
					e = {
						function()
							vim.cmd.rustlsp("explainerror")
						end,
						"explain the error at the cursor",
					},
					a = {
						function()
							vim.cmd.rustlsp("codeaction")
						end,
						"better rust-specific code actions",
					},
					t = {
						function()
							vim.cmd.rustlsp("testables")
						end,
						"run testables in background",
					},
				},
			},
		},
	})
end
