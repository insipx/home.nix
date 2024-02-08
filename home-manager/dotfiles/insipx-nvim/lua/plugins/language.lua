return {
  -- Javascript
  "editorconfig/editorconfig-vim", --[[ Godot/GdScript --]] "habamax/vim-godot",
  "preservim/vim-markdown", -- syntax highlighting/matching

  {
    "andythigpen/nvim-coverage",
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("coverage").setup()
    end,
  }
}
