{
  description = "Insi Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    # doom-emacs = {
    #   url = "github:marienz/nix-doom-emacs-unstraightened";
    #   inputs.nixpkgs.follows = "";
    # };
    # doom-config = {
    #   url = "github:insipx/doom-emacs";
    #   flake = false;
    # };
    hyprland.url = "github:hyprwm/Hyprland?ref=v0.55.4";
    claude-chill.url = "github:davidbeesley/claude-chill";
    hy3 = {
      url = "github:outfoxxed/hy3?ref=hl0.55.0"; # where {version} is the hyprland release version
      # or "github:outfoxxed/hy3" to follow the development branch.
      # (you may encounter issues if you dont do the same for hyprland)
      inputs.hyprland.follows = "hyprland";
    };
    shadow-nvim = {
      # url = "git+file:/Users/andrewplaza/code/insipx/shadow-nvim";
      url = "github:insipx/neovim";
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
      # url = "git+ssh://git@github.com/insipx/unfree.git";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
    mcp-servers = {
      url = "github:natsukium/mcp-servers-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # tidal.url = "github:mitchmindtree/tidalcycles.nix";
    # rustowl = {
    #   url = "github:nix-community/rustowl-flake";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    swww.url = "github:LGFae/swww";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    environments = {
      url = "github:insipx/environments";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    noctalia = {
      url = "github:noctalia-dev/noctalia/legacy-v4";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    textfox = {
      url = "github:adriankarlen/textfox";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jupiter-secrets = {
      url = "github:insipx/jupiter-secrets";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.sops-nix.follows = "sops-nix";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
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
