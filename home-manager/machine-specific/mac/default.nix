{ ... }:
{
  # nix-darwin ships no services.ollama module, so darwin gets the server from
  # home-manager's instead, which runs it as a launchd agent (KeepAlive,
  # ProcessType = "Background"). Metal acceleration is automatic on macOS.
  # pull models on these hosts with `ollama pull <model>`.
  services.ollama.enable = true;

  home.file = {
    ".gnupg/gpg-agent.conf".text = ''
      # https://github.com/drduh/config/blob/master/gpg-agent.conf
      # https://www.gnupg.org/documentation/manuals/gnupg/Agent-Options.html
      enable-ssh-support
      ttyname $GPG_TTY
      default-cache-ttl 60
      max-cache-ttl 120
      pinentry-program /opt/homebrew/bin/pinentry-curses
    '';
  };
}
