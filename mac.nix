{ pkgs, ... }:

let
  # Allows aliasing of apps for Finder
  mkalias = builtins.fetchGit {
    url = "git@github.com:reckenrode/mkalias.git";
    ref = "main";
    rev = "8a5478cdb646f137ebc53cb9d235f8e5892ea00a";
  };
  frameworks = pkgs.darwin.apple_sdk.frameworks;

in {
  home.packages = with pkgs;
    [
      (pkgs.callPackage mkalias { CoreFoundation = frameworks.CoreFoundation; })
    ];
}
