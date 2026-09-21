{ pkgs, ... }:
let
  # prebuilt darwin package
  ollama-darwin-bin = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "ollama-darwin-bin";
    version = "0.32.13";

    src = pkgs.fetchurl {
      url = "https://github.com/ollama/ollama/releases/download/v${finalAttrs.version}/ollama-darwin.tgz";
      hash = "sha256-ce/UTztfIBn0K64XrljrPei9Jc48o7yJrqWOU+XQkdE=";
    };

    # The tarball is flat (binary next to the runner payload). ollama probes
    # <exe>/../lib/ollama for runners, so split it into the nixpkgs layout.
    dontUnpack = true;
    # The Mach-O binaries are signed by upstream; stripping or otherwise
    # rewriting them would invalidate the signatures and macOS would kill
    # them on launch.
    dontFixup = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/lib/ollama
      tar -xzf $src -C $out/lib/ollama
      mv $out/lib/ollama/ollama $out/bin/ollama
      runHook postInstall
    '';

    meta = {
      description = "Ollama darwin release binary, with the MLX runners nixpkgs can't build";
      homepage = "https://github.com/ollama/ollama";
      license = pkgs.lib.licenses.mit;
      sourceProvenance = [ pkgs.lib.sourceTypes.binaryNativeCode ];
      platforms = pkgs.lib.platforms.darwin;
      mainProgram = "ollama";
    };
  });
in
{
  # nix-darwin ships no services.ollama module, so darwin gets the server from
  # home-manager's instead, which runs it as a launchd agent (KeepAlive,
  # ProcessType = "Background"). Metal acceleration is automatic on macOS.
  # pull models on these hosts with `ollama pull <model>`.
  services.ollama.enable = true;
  # NOTE: leave services.ollama.acceleration at null — any other value makes
  # the hm module call package.override { acceleration }, which this binary
  # derivation doesn't accept.
  services.ollama.package = ollama-darwin-bin;
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
