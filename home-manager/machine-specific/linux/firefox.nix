# Firefox, home-manager-owned (moved here from the NixOS programs.firefox
# module so profiles/userChrome/extension policies are declarative).
#
# Catppuccin Mocha Mauve, three independent layers:
#   1. UI colors: official Catppuccin AMO static theme (force-installed below)
#   2. UI layout: textfox userChrome (no hardcoded colors — inherits the theme)
#   3. Website content: catppuccin/userstyles via Stylus.
#      ONE-TIME manual step per browser: generate a mocha/mauve import.json at
#      https://catppuccin-userstyles-customizer.uncenter.dev/ then
#      Stylus icon -> Manage -> Backup -> Import. Styles self-update every 24h.
#
# Slug/GUID are mocha+mauve constants; flavor source of truth is
# rice/catppuccin.nix — change both together.
{ pkgs, ... }:
let
  # https://addons.mozilla.org/en-US/firefox/addon/catppuccin-mocha-mauve-git/
  catppuccinTheme = "{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}";
  # https://addons.mozilla.org/en-US/firefox/addon/styl-us/
  stylus = "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}";
in
{
  # catppuccin/nix's firefox port would auto-enroll via catppuccin.autoEnable,
  # but it only writes settings for the (uninstalled) Firefox Color extension,
  # evaluates via IFD, and its theme data is pinned to 2023 — the AMO static
  # theme below replaces it. See the 2026-07-10 browser theming spec.
  catppuccin.firefox.enable = false;

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    policies.ExtensionSettings = {
      ${catppuccinTheme} = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/catppuccin-mocha-mauve-git/latest.xpi";
        installation_mode = "force_installed";
      };
      ${stylus} = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/styl-us/latest.xpi";
        installation_mode = "force_installed";
      };
    };

    # Attr names must match the existing on-disk profile dirs: HM uses the attr
    # name as the profile path, and textfox drops its chrome/ files by the same
    # key. `name` is just the cosmetic Name= field in profiles.ini.
    profiles = {
      "agn3jjck.default" = {
        id = 0;
        name = "default";
        isDefault = true;
        settings = {
          # best-effort activation of the force-installed theme; worst case one
          # click in about:addons on first run
          "extensions.activeThemeID" = catppuccinTheme;
        };
      };
      # declared only so the HM-generated profiles.ini keeps this profile listed
      "5g7z94j2.dev-edition-default" = {
        id = 1;
        name = "dev-edition-default";
      };
    };
  };

  textfox = {
    enable = true;
    profiles = [ "agn3jjck.default" ];
    config.font.family = ''"Berkeley Mono", monospace'';
  };
}
