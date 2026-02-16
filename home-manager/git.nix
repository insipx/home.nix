_: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Andrew Plaza";
        email = "github@andrewplaza.dev";
      };
      signing = {
        key = "843D72A9EB79A8692C585B3AE7738A7A0F5CDB89";
        signByDefault = true;
      };
      rerere.enabled = true;
      pull = {
        rebase = true;
      };
      diff = {
        tool = "nvim_difftool";
      };
      difftool = {
        nvim_difftool.cmd = "nvim -c \"packadd nvim.difftool\" -c \"DiffTool $LOCAL $REMOTE\"";
      };
      url."https://github.com/" = {
        insteadOf = [
          "gh:"
          "github:"
        ];
      };
    };
  };
}
