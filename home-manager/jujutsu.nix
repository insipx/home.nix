_: {
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Andrew Plaza";
        email = "github@andrewplaza.dev";
      };
      aliases.tug = ["bookmark" "move" "--from" "heads(::@- & bookmarks())" "--to" "@-"];
      signing = {
        behavior = "own";
        backend = "gpg"; # maybe use program option and link to exact nix binary
        key = "843D72A9EB79A8692C585B3AE7738A7A0F5CDB89";
      };
      ui = {
        # editor = ["nvim" "--cmd" "let g:flatten_wait=1"];
        # not sure how to get this  to work
        # diff-formatter = ["nvim" "-c" "\"packadd nvim.difftool\"" "-c" "\"DiffTool $left $right\""];
        # diff-editor = "nvim_difftool";
      };
      merge-tools.nvim_difftool = {
        program = "nvim";
        edit-args = ["-c" "\"packadd nvim.difftool\"" "-c" "\"DiffTool $left $right\""];
      };
      merge-tools.neovim = {
        program = "sh";
        # recommended nvim mergetool config according to https://github.com/jj-vcs/jj/wiki/Vim,-Neovim#using-neovim-as-a-diff-editor-with-existing-git-tooling
        edit-args = [
          "-c"
          ''
            set -eu
            rm -f "$right/JJ-INSTRUCTIONS"
            git -C "$left" init -q
            git -C "$left" add -A
            git -C "$left" commit -q -m baseline --allow-empty # create parent commit
            mv "$left/.git" "$right"
            git -C "$right" add --intent-to-add -A # create current working copy
            (cd "$right"; nvim)
            git -C "$right" diff-index --quiet --cached HEAD && { echo "No changes done, aborting split."; exit 1; }
            git -C "$right" commit -q -m split # create commit on top of parent including changes
            git -C "$right" restore . # undo changes in modified files
            git -C "$right" reset .   # undo --intent-to-add
            git -C "$right" clean -q -df # remove untracked files
          ''
        ];
      };
      fix = {
        tools = {
          rustfmt = {
            enabled = true;
            command = ["rustfmt" "--emit" "stdout"];
            patterns = ["glob:'**/*.rs'"];
          };
          taplo = {
            enabled = true;
            command = ["taplo fmt -"];
            patterns = ["glob:'**/*.toml'"];
          };
        };
      };
    };
  };
}
