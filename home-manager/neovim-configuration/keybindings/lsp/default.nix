let
  modules = [ ./goto.nix ./general.nix ];
  imports = map import modules;

  all = builtins.concatLists
    (map (m: if builtins.isAttrs m then m.all else m) imports);

in {
  goto = (import ./goto.nix);
  general = (import ./general.nix);

  inherit all;
}
