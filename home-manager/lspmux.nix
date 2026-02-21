{ pkgs, lib, ... }:
let
  rust-analyzer-wrapped = pkgs.writeShellScriptBin "rust-analyzer" ''
    exec ${pkgs.direnv}/bin/direnv exec "$PWD" \
      ${pkgs.rust-analyzer-nightly}/bin/rust-analyzer "$@"
  '';

  pathEnv = pkgs.lib.makeBinPath [
    rust-analyzer-wrapped
    pkgs.direnv
    pkgs.nix
    pkgs.coreutils
  ];
in
{
  # Linux systemd service
  systemd.user.startServices = lib.mkIf pkgs.stdenv.isLinux "sd-switch";
  systemd.user.services.lspmux = lib.mkIf pkgs.stdenv.isLinux {
    Unit = {
      Description = "Language server multiplexer";
    };
    Service = {
      Type = "simple";
      Environment = "PATH=${pathEnv}";
      ExecStart = "${pkgs.lspmux}/bin/lspmux server";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # macOS launchd agent
  launchd.agents.lspmux = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    config = {
      ProgramArguments = [ "${pkgs.lspmux}/bin/lspmux" "server" ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/lspmux.log";
      StandardErrorPath = "/tmp/lspmux.error.log";
      EnvironmentVariables = {
        PATH = pathEnv;
      };
    };
  };
}
