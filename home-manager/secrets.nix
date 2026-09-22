{ config, ... }: {
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  sops.secrets.languagetool_api_key = {
    sopsFile = ./../secrets/env.yaml;
    path = "${config.home.homeDirectory}/.config/neovim-secrets/languagetool";
    mode = "0400";
  };
}
