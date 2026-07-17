# Noctalia v5 (native-runtime rewrite; replaces the quickshell v4 whose
# full-screen scrim layer intermittently ate clicks — Steam dialogs, Datadog
# menus). Stage 1: minimal bar + Monochrome dark theme, no plugins, no theming
# templates (those are Stage 2). See the 2026-07-17 migration spec.
#
# Namespace is programs.noctalia (v4 used programs.noctalia-shell). Settings are
# a nix attrset serialized to ~/.config/noctalia/config.toml. Schema verified
# against the beta.3 binary (`noctalia config export full` + `config validate`):
# bar is [bar] with order + a [bar.default] table; widget slots are
# start/center/end (not left/right); widget ids are lowercase-hyphenated;
# theme.builtin is capitalized. `density` is NOT a v5 bar key (v4-ism) and is
# omitted. rice/noctalia.nix is kept as the v4 reference, no longer imported.
{ ... }:
{
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings = {
      bar = {
        order = [ "default" ];
        default = {
          enabled = true;
          position = "top";
          start = [ "launcher" "workspaces" ];
          center = [ "active-window" ];
          end = [ "control-center" "clock" "session" ];
        };
      };
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Monochrome";
      };
    };
  };
}
