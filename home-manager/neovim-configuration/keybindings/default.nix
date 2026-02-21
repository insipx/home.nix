let
  lib = import ./lib.nix;
  discovered = lib.autoDiscover ./.;
in
discovered
// {
  desc = [
    {
      key = "<leader>b";
      action = "";
      options.desc = "+buffers";
    }
    {
      key = "<leader>c";
      action = "";
      options.desc = "+code";
    }
    {
      key = "<leader>r";
      action = "";
      options.desc = "+debugger";
    }
    {
      key = "<leader>f";
      action = "";
      options.desc = "+files";
    }
    {
      key = "g";
      action = "g";
      options.desc = "+goto";
    }
    {
      key = "<leader>i";
      action = "";
      options.desc = "+clipboard";
    }
    {
      key = "<leader>l";
      action = "";
      options.desc = "+lsp";
    }
    {
      key = "<leader>p";
      action = "";
      options.desc = "+project";
    }
    {
      key = "<leader>q";
      action = "";
      options.desc = "+quickfix";
    }
    {
      key = "<leader>t";
      action = "";
      options.desc = "+terminal";
    }
    {
      key = "<leader>w";
      action = "";
      options.desc = "+window";
    }
    {
      key = "<leader>u";
      action = "";
      options.desc = "+ui toggles";
    }
    {
      key = "<leader>g";
      action = "";
      options.desc = "+git";
    }
    {
      key = "<leader><Tab>";
      action = "";
      options.desc = "+workspace";
    }
  ];
}
