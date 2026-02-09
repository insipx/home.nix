{ pkgs, ... }:
let
  writeFishScriptBin = pkgs.callPackage ./write_fish_script { };
in
{
  packages = {
    sccache_wrapper = pkgs.callPackage ./sccache_wrapper { inherit writeFishScriptBin; };
  };
}
