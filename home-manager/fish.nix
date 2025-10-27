{
  pkgs,
  lib,
  ...
}: {
  programs.fish = {
    enable = true;
    shellAliases = {
      age = "${lib.getBin pkgs.rage}/bin/rage";
      vi = "nvim";
      vim = "nvim";
      ls = "${lib.getBin pkgs.eza}/bin/eza";
      du = "${lib.getBin pkgs.du-dust}/bin/dust";
      pretty = "prettybat";
      diff = "batdiff";
      # less = "batpipe";
      man = "batman";
      # rg = "batgrep";
      # grep = "batgrep";
      # ssh = "GPG_TTY=$(tty) ssh";
      cat = "${lib.getBin pkgs.bat}/bin/bat";
      jq = "${lib.getBin pkgs.xq}/bin/xq";
      nix = "nix --log-format bar";
    };
    interactiveShellInit = ''
      ${lib.getBin pkgs.macchina}/bin/macchina
      set fish_greeting # Disable greeting
      if test (uname) = Darwin
       fish_add_path /opt/homebrew/bin
      end
      set -x GPG_TTY (tty)
      set -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
      gpgconf --launch gpg-agent
      fish_vi_key_bindings
      set -x KEYID "843D72A9EB79A8692C585B3AE7738A7A0F5CDB89"
      # Batpipe setup
      set -x LESSOPEN "|${pkgs.bat-extras.batpipe}/bin/.batpipe-wrapped %s";
      set -e LESSCLOSE;

      # The following will enable colors when using batpipe with less:
      set -x LESS "$LESS -R";
      # set -x BATPIPE "color";

      set -gx PATH "$HOME/.scripts" $PATH
      set -gx PATH "$HOME/.cargo/bin" $PATH
      if test (uname) = Darwin
        fish_add_path --prepend --global "$HOME/.nix-profile/bin" /nix/var/nix/profiles/default/bin /run/current-system/sw/bin
        # fish_add_path --prepend --global "$HOME/.foundry/bin"
      end

      function ssh --wraps ssh
        set --function --export GPG_TTY $(tty)
        echo $GPG_TTY
        command ssh $argv
      end
    '';
    plugins = [
      {
        name = "grc";
        inherit (pkgs.fishPlugins.grc) src;
      }
      {
        name = "colored-man-pages";
        inherit (pkgs.fishPlugins.colored-man-pages) src;
      }
      {
        name = "done";
        inherit (pkgs.fishPlugins.done) src;
      }
      {
        name = "pure";
        inherit (pkgs.fishPlugins.pure) src;
      }
      {
        name = "forgit";
        inherit (pkgs.fishPlugins.forgit) src;
      }
    ];
  };
}
