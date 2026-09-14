{
  config,
  ...
}:
{
  sops = {
    defaultSopsFile = ./../secrets/env.yaml;
    secrets = {
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
