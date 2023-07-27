`git submodule init`
`git submodule update --recursive`


### Setup

Machine requires defining `profile.nix` with a small amount of config variables:

```nix
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "user";
  home.homeDirectory = "/Users/machine/specific";
  home.sessionVariables = { MACHINE = "machine name"; };
```
#### External Deps
`Symbols Nerd Font`



