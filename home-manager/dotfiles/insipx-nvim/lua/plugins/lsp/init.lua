return {
	{ "folke/neoconf.nvim" },
	{ "ms-jpq/coq_nvim", branch = "coq" },
	{ "ms-jpq/coq.artifacts", branch = "artifacts" },
	{ "ms-jpq/coq.thirdparty", branch = "3p" },
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				rust_analyzer = {},
			},
		},
		setup = {
			rust_analyzer = function()
				return true
			end,
		},
		config = function()
			return true
		end,
	},
	{ "stevearc/conform.nvim", opts = {} },
	{ "mfussenegger/nvim-lint" },
	{
		"j-hui/fidget.nvim",
		event = "LspAttach",
		config = function()
			require("fidget").setup()
		end,
	}, -- nvim lsp progress
	{
		"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
		config = function()
			require("lsp_lines").setup()
		end,
	},
	"folke/lsp-colors.nvim",
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("trouble").setup()
		end,
	},
	{
		"https://gitlab.com/yorickpeterse/nvim-dd",
		config = function()
			require("dd").setup({
				-- time to wait to defer diagnostics
				timeout = 1000,
			})
		end,
	}, -- defers diagnostics
	{
		"mrcjkb/rustaceanvim",
		version = "^4",
		ft = { "rust" },
		opts = {
			tools = {
				inlay_hints = { only_current_line = true, show_variable_name = true },
				hover_actions = { auto_focus = true },
			},
			server = {

				on_attach = function(client, bufnr)
					local wk = require("which-key")
					wk.register({
						["<leader>"] = {
							l = {
								R = {
									name = "Rust",
									h = {
										function()
											vim.cmd.RustLsp({ "hover", "actions" })
										end,
										"Trigger actions on hover",
									},
									r = {
										function()
											vim.cmd.RustLsp("runnables")
										end,
										"List runnables in buffer",
									},
									c = {
										function()
											vim.cmd.RustLsp("openCargo")
										end,
										"Open the Cargo.toml for the current buffer project",
									},
									p = {
										function()
											vim.cmd.RustLsp("parentModule")
										end,
										"Go to the parent module",
									},
									s = {
										function()
											vim.cmd.RustLsp({ "ssr" })
										end,
										"Structural Search & Replace",
									},
									d = {
										function()
											vim.cmd.RustLsp("renderDiagnostic")
										end,
										"Render the diagnostic as in Cargo Build",
									},
									e = {
										function()
											vim.cmd.RustLsp("explainError")
										end,
										"Explain the error at the cursor",
									},
									a = {
										function()
											vim.cmd.RustLsp("codeAction")
										end,
										"Better Rust-Specific code actions",
									},
									t = {
										function()
											vim.cmd.RustLsp("testables")
										end,
										"Run testables in background",
									},
								},
							},
						},
					})
				end,
				default_settings = {
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true,
							loadOutDirsFromCheck = true,
							runBuildScripts = true,
						},
						checkOnSave = {
							allFeatures = true,
							command = "clippy",
							extraArgs = { "--no-deps" },
						},
						procMacro = {
							enable = true,
							ignored = {
								["async-trait"] = { "async_trait" },
								["napi-derive"] = { "napi" },
								["async-recursion"] = { "async_recursion" },
								["ctor"] = { "ctor" },
							},
						},
					},
				},
			},
		},
		config = function(_, opts)
			vim.g.rustaceanvim = vim.tbl_deep_extend("force", {}, opts or {})
		end,
	},
	{
		"nvim-neotest/neotest",
		optional = true,
		opts = function(_, opts)
			opts.adapters = opts.adapters or {}
			vim.list_extend(opts.adapters, {
				require("rustaceanvim.neotest"),
			})
		end,
	},
	{ -- view create versions in virtual text
		"saecki/crates.nvim",
		tag = "v0.3.0",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("crates").setup({ src = { coq = { enabled = true } } })
		end,
	},
	-- view symbols (functions, structs, etc.) from LSP for a buffer. A useful outline for jumping in long files.
	{
		"simrat39/symbols-outline.nvim",
		config = function()
			require("symbols-outline").setup()
		end,
	},
	{
		"lukas-reineke/lsp-format.nvim",
		config = function()
			require("lsp-format").setup({})
		end,
	},
	"github/copilot.vim",
	{
		"glepnir/lspsaga.nvim",
		event = "LspAttach",
		config = function()
			require("lspsaga").setup({})
		end,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			-- Please make sure you install markdown and markdown_inline parser
			"nvim-treesitter/nvim-treesitter",
		},
	},
	{
		"ray-x/go.nvim",
		dependencies = { -- optional packages
			"ray-x/guihua.lua",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("go").setup({
				lsp_codelens = false,
			})
		end,
		event = { "CmdlineEnter" },
		ft = { "go", "gomod" },
		build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
	},
}

-- Servers
