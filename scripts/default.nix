_: {
  perSystem = { pkgs, self', ... }: {
    packages = {
      sccache_wrapper = pkgs.callPackage ./sccache_wrapper { };
    };
    overlays = {
      scripts_overlay = _: prev: {
        inherit (self'.pkgs) sccache_wrapper;
      };
    };
  };
}
