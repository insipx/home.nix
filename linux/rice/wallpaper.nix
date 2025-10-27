{ inputs, pkgs, ... }: {
  services.swww = {
    enable = true;
    package = inputs.swww.packages.${pkgs.system}.swww;
  };
}

