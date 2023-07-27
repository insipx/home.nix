{ pkgs, config, ... }:

let
  # Allows aliasing of apps for Finder
  # mkalias = builtins.fetchGit {
  #   url = "git@github.com:reckenrode/mkalias.git";
  #   ref = "main";
  #   rev = "8a5478cdb646f137ebc53cb9d235f8e5892ea00a";
  # };
  # frameworks = pkgs.darwin.apple_sdk.frameworks;
  test = "test";
in {
  home.packages = with pkgs;
    [
      # (pkgs.callPackage mkalias { CoreFoundation = frameworks.CoreFoundation; })
    ];

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
