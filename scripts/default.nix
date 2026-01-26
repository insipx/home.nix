_: {
  perSystem = { pkgs, ... }:
    let
      writeFishScriptBin = pkgs.lib.callPackage ./write_fish_script { };
    in
    {
      packages = {
        sccache_wrapper = pkgs.lib.callPackage ./sccache_wrapper { inherit writeFishScriptBin; };
      };
    };
}
