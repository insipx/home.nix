{
  pkgs,
  config,
  ...
}:
{
  sops = {
    defaultSopsFile = ./../secrets/env.yaml;
    secrets.nixAccessTokens = {
      mode = "0440";
      owner = "insipx";
      # if pkgs.stdenv.hostPlatform == "x86_64-linux" then
      # else
      # config.system.primaryUser;
      group = if pkgs.stdenv.hostPlatform.isLinux then config.users.users.insipx.group else "staff";
      # group = config.users.users.insipx.group;
    };
    secrets.nixAccessTokensClassic = {
      mode = "0440";
      owner =
        # if pkgs.stdenv.hostPlatform == "x86_64-linux" then
        config.users.users.insipx.name;
      #else
      #  config.system.primaryUser;
      # group = config.users.users.insipx.group;
    };
    # netrc-format GitHub credentials for private github: flake inputs. Must be
    # readable by the invoking user, not just root: flake fetches run in the
    # user's nix client process, not the daemon. Shared across all machines.
    secrets.nixGithubNetrc = {
      mode = "0440";
      owner = "insipx";
      group = if pkgs.stdenv.hostPlatform.isLinux then config.users.users.insipx.group else "staff";
    };
  };

  # Authenticate private github: flake inputs via netrc. This works on both
  # stock Nix (netrc-file below) and Determinate Nix (additionalNetrcSources,
  # wired per-host in systems.nix), so it is the single credential mechanism.
  nix.settings.netrc-file = config.sops.secrets.nixGithubNetrc.path;
}
