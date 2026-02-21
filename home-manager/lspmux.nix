{ pkgs, ... }:
{

  systemd.user.services.lspmux =
    # let
    #   rust-analyzer-wrapped = pkgs.writeShellScriptBin "rust-analyzer" ''
    #     exec ${pkgs.direnv}/bin/direnv exec "$PWD" \
    #       ${pkgs.rust-analyzer-nightly}/bin/rust-analyzer "$@"
    #   '';
    # in
    {
      enable = true;
      # after = [ "network.target" ];
      # wantedBy = [ "default.target" ];
      #path = with pkgs; [
      #  rust-analyzer-wrapped
      #  gcc
      #  mold
      #  direnv
      #  inputs.fenix.packages.${pkgs.system}.minimal.toolchain
      #  nix
      #];
      Unit = {
        Description = "Language server multiplexer";
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.lspmux}/bin/lspmux server";
      };
    };
}
