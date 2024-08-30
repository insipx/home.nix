let
  modules = [ ./goto.nix ./general.nix ];
  imports = map import modules;

  all = builtins.concatLists
    (map (m: if builtins.isAttrs m then m.all else m) imports);

in {
  inherit (import ./goto.nix) goto;
  inherit (import ./buffer.nix) buffer;

  inherit all;
}
