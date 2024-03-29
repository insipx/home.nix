require("utils")
local wk = require("which-key")
local neogit = require("neogit")
local cmd = vim.cmd
local opts = { noremap = true, silent = true }
local telescope = require("telescope.builtin")
local tele_themes = require("telescope.themes")
local tele_ext = require("telescope").extensions
-- Normal Mode
wk.register({
	["<leader>"] = {
		name = "general",
		f = {
			name = "file",
			f = {
				function()
					telescope.find_files(tele_themes.get_ivy({}))
				end,
				"find file",
			},
			r = {
				function()
					telescope.old_files(tele_themes.get_ivy({}))
				end,
				"open recent file",
			},
			b = {
				function()
					tele_ext.file_browser.file_browser(tele_themes.get_ivy({}))
				end,
				"browse files",
			},
			m = {
				function()
					telescope.marks(tele_themes.get_ivy({}))
				end,
				"find marks",
			},
			h = {
				function()
					telescope.oldfiles(tele_themes.get_ivy({}))
				end,
				"find history",
			},
			-- c = { "<cmd> Telescope frecency<cr>", 	"use frecency to find frequently-used files" },
			-- p = { "<cmd> Telescope ports<cr>", 	"find open ports, kill process with <CTRL>-K" },
			t = { "<cmd>NvimTreeToggle<CR>", "Toggle tree file browser" },
		},
		b = {
			name = "buffer",
			b = {
				function()
					telescope.buffers(tele_themes.get_ivy({}))
				end,
				"list buffers in current context",
			},
			B = {
				function()
					tele_ext.scope.buffers(tele_themes.get_ivy({}))
				end,
				"list all buffers",
			},
			n = { "<cmd>bnext<cr>", "next buffer" },
			p = { "<cmd>bprev<cr>", "previous buffer" },
			P = { "<cmd>BufferLineTogglePin<CR>", "Pin buffer to start of bufferline" },
			k = { "<cmd>Bdelete<cr>", "close buffer" },
			a = { "<cmd>bufdo Bdelete<cr>", "delete all buffers" },
			t = {
				function()
					tele_ext.tele_tabby.list(tele_themes.get_ivy({}))
				end,
				"buffer search",
			},
		},
		q = {
			name = "search/quickfix",
			o = { "<cmd>copen<CR>", "open the quickfix window" },
			c = { "<cmd>ccl<CR>", "close the quickfix window" },
			n = { "<cmd>cn<CR>", "go to the next error in window" },
			p = { "<cmd>cp<CR>", "go to previous error in window" },
			l = {
				function()
					telescope.quickfix(tele_themes.get_ivy({}))
				end,
				"list items in the quickfix list",
			},
			h = {
				function()
					telescope.quickfixhistory(tele_themes.get_ivy({}))
				end,
				"search through quick fix history",
			},
			s = {
				function()
					require("spectre").open_visual({ select_word = true })
				end,
				"search and replace with Spectre. WARNING: COMMIT BEFOREHAND",
			},
		},
		c = {
			name = "commands (OS)",
			n = { "<cmd>enew<cr>", "new file" },
			r = {
				function()
					rename()
				end,
				"Rename file",
			},
		},
		--r = {
		--	name = "godot",
		--	r = { "<cmd>GodotRun<cr>", "run the main scene" },
		--	R = { "<cmd>GodotRun", "select a scene to run" },
		--	f = { "<cmd>GodotRunFZF<cr>", "select a scene with fzf" },
		--},
		p = {
			name = "project",
			f = {
				function()
					telescope.git_files(tele_themes.get_ivy({}))
				end,
				"find file in project",
			},
			t = {
				name = "Tree Explorer",
				t = { "<cmd>CHADopen<CR>", "open tree explorer" },
				k = { "<cmd>CHADhelp keybind<CR>", "open help dialogue for tree binds" },
			},
			s = {
				name = "Diagnostic Sidebar",
				r = { "<cmd>SidebarNvimUpdate<CR>", "update diagnostic sidebar" },
				t = { "<cmd>SidebarNvimToggle<CR>", "toggle diagnostic sidebar" },
			},
			d = { "<cmd>TroubleToggle<CR>", "toggle error quickfix" },
			p = {
				function()
					tele_ext.project.project({})
				end,
				"Open Projects",
			},
		},
		g = {
			name = "git",
			g = {
				function()
					neogit.open()
				end,
				"neogit status",
			},
			G = {
				function()
					neogit.open({ kind = "split" })
				end,
				"neogit status split",
			},
			c = {
				function()
					neogit.open({ "commit" })
				end,
				"neogit commit",
			},
			f = {
				name = "Git forge, octo",
				p = { "<cmd>Octo pr list<CR>", "List PR's from this repository" },
				i = { "<cmd>Octo issue list<CR>", "List issues from this repo" },
			},
		},
		w = {
			name = "window",
			h = { "<C-W>h", "left" },
			l = { "<C-W>l", "right" },
			j = { "<C-W>j", "down" },
			k = { "<C-W>k", "up" },
			v = { "<C-w>v", "vertical split" },
			s = { "<C-w>s", "horizontal split" },
			q = { "<cmd>q<cr>", "close" },
			["="] = { "<C-w>=", "balance windows" },
			L = { "<C-w>>2", "resize right" },
			H = { "<C-w><2", "resize left" },
			J = { "<C-w>+2", "resize down" },
			K = { "<C-w>-2", "resize up" },
		},
		t = {
			name = "terminal",
			t = { "<cmd>ToggleTerm size=20 dir=git_dir direction=horizontal<CR>", "toggle terminal" },
			f = { "<cmd>Telescope toggleterm<CR>", "find open terminal" },
		},
		i = {
			name = "insert",
			c = { "+y", "to clipboard" },
			y = { '"+p', "from clipboard" },
			r = { "<cmd>Telescope registers<CR>", "from register" },
			-- unicode
			-- emoji
		},
		l = {
			name = "LSP",
			--G = { Define in goModule ft like for rustaceanvim
			--	name = "Go",
			--	m = { "<CMD>GoMake<CR>", "async make, use with other commands" },
			--	t = { "<CMD>GoTest<CR>", "go test ./.." },
			--	r = { "<CMD>GoRun -F<CR>", "runs project in floatterm" },
			--},
			T = {
				name = "toggles",
				l = {
					function()
						require("lsp_lines").toggle()
					end,
					"toggle lsp_lines virtual text",
				},
			},
			a = { "<CMD>Lspsaga code_action<CR>", "select code action" },
			f = {
				function()
					vim.lsp.buf.format()
				end,
				"format buffer",
			},
			d = { "<CMD>Lspsaga hover_doc<CR>", "Show documentation" },
			o = { "<CMD>Lspsaga outline<CR>", "Show outline" },
			-- d = {"<CMD>Lspsaga peek_definition<CR>", "peek definition"},
			-- R = {"<CMD>Lspsaga rename ++project<CR>", "rename hovered word for selected files (project)"},
			-- D = {function() vim.lsp.buf.declaration() end, "go to declaration"},
			-- i = {function() vim.lsp.buf.implementation() end, "go to implementation"},
			-- t = {function() vim.lsp.buf.type_definition() end, "go to type definition"},
			r = {
				function()
					telescope.lsp_references(tele_themes.get_ivy({}))
				end,
				"list references",
			},
			D = {
				name = "diagnostics",
				a = {
					function()
						telescope.diagnostics(tele_themes.get_ivy({}))
					end,
					"list diagnostics for all open buffers",
				},
				c = {
					function()
						telescope.diagnostics({ theme = tele_themes.get_ivy({}), bufnr = 0 })
					end,
					"list diagnostics for currently open buffer",
				},
			},
			s = { "<CMD>SymbolsOutline<CR>", "toggle symbols outline" },
			c = {
				name = "GitHub Copilot",
				n = { "<Plug>(copilot-next)<CR>", "next suggestion" },
				p = { "<Plug>(copilot-prev)<CR>", "previous suggestion" },
				d = { "<Plug>(copilot-dismiss)<CR>", "dismiss suggestion" },
			},
		},
		e = {
			name = "neoVIM options",
			s = { "<CMD> source $MYVIMRC<CR>", "Source vim config" },
			c = {
				function()
					telescope.commands(tele_themes.get_ivy({}))
				end,
				"List available commands from vim/plugins",
			},
		},
		["<Tab>"] = {
			name = "workspace",
			n = { "<cmd>tabedit<cr>", "new workspace" },
			d = { "<cmd>tabclose<cr>", "close workspace" },
			["]"] = { "<cmd>tabn<cr>", "next workspace" },
			["["] = { "<cmd>tabp<cr>", "previous workspace" },
			["<Right>"] = { ":tabm +1<CR>", "move workspace to the right" },
			["<Left>"] = { ":tabm -1<CR>", "move workspace to the left" },
		},
		["/"] = {
			function()
				telescope.live_grep(tele_themes.get_ivy({}))
			end,
			"search project",
		},
		["H"] = {
			function()
				telescope.search_history(tele_themes.get_ivy({}))
			end,
			"telescope search history",
		},
		["?"] = { "<cmd>Cheatsheet<CR>", "time to CHEAT!!!" },
	},
	g = {
		name = "goto",
		p = { "<cmd>Lspsaga peek_definition<CR>", "peek definition" },
		r = {
			"<cmd>Lspsaga rename ++project<CR>",
			"rename occurrences of hovered word for selected files",
		},
		t = { "<cmd>Lspsaga peek_type_definition<CR>", "Peek type definition in floating window" },
		h = { "<cmd>Lspsaga lsp_finder<CR>", "find symbols definitino" },
	},
	["["] = {
		e = { "<cmd>Lspsaga diagnostic_jump_prev<CR>", "go to previous diagnostic" },
		E = {
			function()
				require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
			end,
			"Go to previous error",
		},
	},
	["]"] = {
		e = { "<cmd>Lspsaga diagnostic_jump_next<CR>", "go to next diagnostic" },
		E = {
			function()
				require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
			end,
			"Goto next error",
		},
	},
	["\\\\"] = {
		name = "word navigation",
		w = { ":HopWord<CR>", "hop to a word" },
		b = { ":HopWordBC<CR>", "hop word backwards" },
		f = { ":HopWordAC<CR>", "hop word forwards" },
		a = { ":HopAnywhere<CR>", "hop anywhere" },
	},
})

--  :FloatermNew --autoclose=0 gcc % -o %< && ./%<
-- Terminal Mode
wk.register({
	t = {
		name = "terminal",
		t = { t("<C-\\><C-N>:ToggleTerm<CR>"), "toggle floating terminal" },
		-- t = { t("<C-\\><C-N>:FloatermToggle<CR>"),		"toggle floating terminal" },
		-- n = { "<cmd>FloatermNext<cr>",		  	"next Terminal" 	   },
		-- p = { "<cmd>FloatermPrev<cr>",		  	"previous Terminal" 	   },
	},
}, { prefix = "<leader>", mode = "t", noremap = true, silent = true })

-- Vim move Keybindings
vim.keymap.set("n", "<A-j>", ":MoveLine(1)<CR>", opts)
vim.keymap.set("n", "<A-k>", ":MoveLine(-1)<CR>", opts)
vim.keymap.set("v", "<A-j>", ":MoveBlock(1)<CR>", opts)
vim.keymap.set("v", "<A-k>", ":MoveBlock(-1)<CR>", opts)

vim.keymap.set("n", "<A-h>", ":MoveHChar(-1)<CR>", opts)
vim.keymap.set("n", "<A-l>", ":MoveHChar(1)<CR>", opts)
vim.keymap.set("v", "<A-h>", ":MoveHBlock(-1)<CR>", opts)
vim.keymap.set("v", "<A-l>", ":MoveHBlock(1)<CR>", opts)

cmd([[
  let g:dashboard_custom_shortcut={
    \ 'last_session'       : 'SPC s l',
    \ 'find_history'       : 'SPC f h',
    \ 'find_file'          : 'SPC f f',
    \ 'new_file'           : 'SPC f n',
    \ 'change_colorscheme' : 'SPC t c',
    \ 'find_word'          : 'SPC f a',
    \ 'book_marks'         : 'SPC p c b',
  \ }
]])
