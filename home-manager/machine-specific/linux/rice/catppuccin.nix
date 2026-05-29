{ ... }: {

  catppuccin = {
    flavor = "mocha";
    # catppuccin's hyprland module injects a `colors._var` lua-inline theme that only
    # parses in Hyprland 0.55 Lua-config mode; our config is plaintext .conf, so it
    # errors (colors:_var:_type does not exist). Disable until we move to Lua config.
    hyprland.enable = false;
    spotify-player.enable = true;
    eza.enable = true;
    fish.enable = true;
  };
}
