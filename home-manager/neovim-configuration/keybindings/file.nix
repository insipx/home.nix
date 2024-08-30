{ ... }: [{
  mode = "n";
  key = "<leader>ft";
  action = "<cmd>NvimTreeToggle<CR>";
  options = {
    silent = true;
    desc = "Toggle tree file browser";
  };
}]
