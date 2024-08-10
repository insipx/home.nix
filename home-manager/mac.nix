{ pkgs, config, nixvim, ... }: {
  imports = [ ./common.nix ];

  home.file = {
    ".gnupg/gpg-agent.conf".text = ''
      # https://github.com/drduh/config/blob/master/gpg-agent.conf
      # https://www.gnupg.org/documentation/manuals/gnupg/Agent-Options.html
      enable-ssh-support
      ttyname $GPG_TTY
      default-cache-ttl 60
      max-cache-ttl 120
      pinentry-program /opt/homebrew/bin/pinentry-mac
    '';
  };
}
