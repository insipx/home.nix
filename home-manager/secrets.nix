{
  config,
  pkgs,
  lib,
  osConfig ? { },
  ...
}:
# Use the host-managed secret when available; retain user provisioning elsewhere.
lib.mkIf (!(osConfig.sops.secrets ? languagetool_api_key)) {
  sops.age.plugins = [ pkgs.age-plugin-yubikey ];
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  sops.secrets.languagetool_api_key = {
    sopsFile = ./../secrets/env.yaml;
    path = "${config.home.homeDirectory}/.config/neovim-secrets/languagetool";
    mode = "0400";
  };
}
