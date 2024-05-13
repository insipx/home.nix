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
							vim.cmd.RustLsp({ "hover", "actions" })
						end,
						"trigger actions on hover",
					},
					r = {
						function()
							vim.cmd.RustLsp("runnables")
						end,
						"list runnables in buffer",
					},
					c = {
						function()
							vim.cmd.RustLsp("openCargo")
						end,
						"open the cargo.toml for the current buffer project",
					},
					p = {
						function()
							vim.cmd.RustLsp("parentModule")
						end,
						"go to the parent module",
					},
					s = {
						function()
							vim.cmd.RustLsp({ "ssr" })
						end,
						"structural search & replace",
					},
					d = {
						function()
							vim.cmd.RustLsp("renderDiagnostic")
						end,
						"render the diagnostic as in cargo build",
					},
					e = {
						function()
							vim.cmd.RustLsp("explainError")
						end,
						"explain the error at the cursor",
					},
					a = {
						function()
							vim.cmd.RustLsp("codeAction")
						end,
						"better rust-specific code actions",
					},
					t = {
						function()
							vim.cmd.RustLsp("testables")
						end,
						"run testables in background",
					},
				},
			},
		},
	})
end
