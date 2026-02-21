{ pkgs, ... }:
let
  rust-analyzer-wrapped = pkgs.writeShellScriptBin "rust-analyzer" ''
    exec ${pkgs.direnv}/bin/direnv exec "$PWD" \
      ${pkgs.rust-analyzer-nightly}/bin/rust-analyzer "$@"
  '';
in
{
  systemd.user.startServices = "sd-switch";
  systemd.user.services.lspmux = {
    Unit = {
      Description = "Language server multiplexer";
    };
    Service = {
      Type = "simple";
      Environment = "PATH=${pkgs.lib.makeBinPath [
        rust-analyzer-wrapped
        pkgs.direnv
        pkgs.nix
        pkgs.coreutils
      ]}";
      ExecStart = "${pkgs.lspmux}/bin/lspmux server";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
