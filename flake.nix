{
  description = "Insi Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/68ed3354133f549b9cb8e5231a126625dca4e724";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Other Sources
    doom-emacs = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "";
    };
    doom-config = {
      url = "git+file:/home/insipx/code/insipx/doom-emacs";
      # url = "github:insipx/doom-emacs";
      flake = false;
    };
    shadow-nvim = {
      # url = "github:insipx/neovim";
      url = "git+file:/home/insipx/code/insipx/neovim";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jujutsu = {
      url = "github:jj-vcs/jj/v0.38.0";
      # url = "github:jj-vcs/jj";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sccache = {
      url = "github:mozilla/sccache";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    unfree = {
      # url = "git+file:/home/insipx/code/insipx/unfree";
      url = "github:insipx/unfree/main";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    # tidal.url = "github:mitchmindtree/tidalcycles.nix";
    # rustowl = {
    #   url = "github:nix-community/rustowl-flake";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    swww.url = "github:LGFae/swww";
    # determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    environments = {
      url = "github:insipx/environments";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    jj-spr.url = "github:LucioFranco/jj-spr";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # `...` allows defining additional inputs to the outputs
  # without changing the fn signature. It makes the flake more flexible.
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      imports = [
        ./systems.nix
        inputs.flake-parts.flakeModules.modules
      ];
    };
}
