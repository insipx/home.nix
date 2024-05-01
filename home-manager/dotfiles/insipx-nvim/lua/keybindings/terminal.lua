require("../utils")

local wk = require("which-key")

--  :FloatermNew --autoclose=0 gcc % -o %< && ./%<
-- Terminal Mode
wk.register({
	t = {
		name = "terminal",
		t = { Utils:termcode("<C-\\><C-N>:ToggleTerm<CR>"), "toggle floating terminal" },
		-- t = { t("<C-\\><C-N>:FloatermToggle<CR>"),		"toggle floating terminal" },
		-- n = { "<cmd>FloatermNext<cr>",		  	"next Terminal" 	   },
		-- p = { "<cmd>FloatermPrev<cr>",		  	"previous Terminal" 	   },
	},
}, { prefix = "<leader>", mode = "t", noremap = true, silent = true })
