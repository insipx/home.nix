{
  config,
  ...
}:
{
  sops = {
    defaultSopsFile = ./../secrets/env.yaml;
    secrets = {
      languagetool_api_key = {
        owner = config.users.users.andrewplaza.name;
        mode = "0400";
        path = "${config.users.users.andrewplaza.home}/.config/neovim-secrets/languagetool";
      };
      nixAccessTokens = {
        mode = "0440";
        owner = "andrewplaza";
        group = "staff";
      };
      nixAccessTokensClassic = {
        mode = "0440";
        owner = config.users.users.andrewplaza.name;
      };
      nixGithubNetrc = {
        mode = "0440";
        owner = "root";
        group = "wheel";
      };
    };
  };

  nix.settings.netrc-file = config.sops.secrets.nixGithubNetrc.path;
}
