{ pkgs, ... }: {
  xdg.configFile."yofi/yofi.config".source = (pkgs.formats.toml { }).generate "yofi config" {
    width = 400;
    height = 512;
    font_size = 16;
  };
}
