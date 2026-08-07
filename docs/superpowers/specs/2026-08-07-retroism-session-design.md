# Retroism login session — design

2026-08-07 · status: approved pending spec review

## Goal

Add a third entry, **Retroism**, to the lemurs login picker alongside `Hypr` and
`Gamez`. Picking it boots a session that keeps the user's Hyprland base
(hy3 plugin, keybinds, monitors, input, nvidia env) but wears the
[linux-retroism](https://github.com/diinki/linux-retroism) skin: retroism's
Quickshell taskbar/launcher, GTK + icon themes, retro wallpaper, mako
notifications, Hackneyed cursor, and a retro ghostty palette. The existing
noctalia session must remain byte-for-byte identical in behavior, and no retro
theming may leak into it.

Non-goals: adopting retroism's kitty/keybinds/layout; theming outside the
retroism session; supporting display managers other than lemurs (the fork's
flake may do so independently).

## Dependency: the fork's flake (separate design)

The retroism assets and module come from the user's fork at
`~/code/insipx/linux-retroism`, whose flake is being designed in a separate
track. This design consumes only this contract from it (as flake input
`retroism`):

- packages: `themes` (share/themes + share/icons), `quickshell-config`,
  `wallpapers`
- `homeManagerModules.retroism` providing `programs.retroism` with:
  `enable`; `quickshell.enable` + read-only `quickshell.command` and
  `launcherCommand`; `ghostty.enable` (palette include file at
  `~/.config/ghostty/retroism.conf`); `hyprland.baseSettings` (attrset) +
  `hyprland.extraConfig` (verbatim hyprlang, carries the resize submap) +
  `hyprland.plugins` → rendered standalone session config **deployed to
  `~/.config/hypr/retroism.conf`** (the deployment step is part of the
  contract — a bare store-path output is not; adversarial-review finding);
  read-only `hyprland.visualSettings`, `palette`, `themeNames`
  (gtk/icon strings, so this repo never hardcodes them)
- The rendered config includes the systemd session bootstrap (see §2) with
  `RICE` and `DCONF_PROFILE` in its import list
- Explicitly NOT used here: `gtk.enable`, `hyprland.applyLayer` (global
  theming — this design themes per-session instead)

If the fork design changes option names, only the consuming module
(`rice/retroism.nix`) needs updating.

## 1. Lemurs session entry + rice stamping

`linux/services.nix` gains `environment.etc."lemurs/wayland/Retroism"`.
Both real desktop sessions stamp their identity into the systemd user
manager before launching the compositor, so per-session units can condition
on it and stale values from a previous login are always overwritten:

- `Hyprland` script (the existing `Hypr` entry, **renamed**):
  `systemctl --user set-environment RICE=noctalia` plus
  `systemctl --user unset-environment DCONF_PROFILE`, then `exec hyprland`.
  The name is load-bearing: lemurs re-selects by exact title match against
  `/var/cache/lemurs`, which holds `Hyprland` — leaving it as `Hypr` would
  miss, fall back to index 0 of an *unsorted* `read_dir` (empirically
  `Gamez`), and — because the greeter focuses the password field when a
  username is cached — silently launch Steam on the first login.
- `Retroism` script (new): `systemctl --user set-environment RICE=retroism`,
  then `exec hyprland --config "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/retroism.conf"`.
- `Gamez` is untouched and deliberately stamps nothing: `graphical-session.target`
  is never started in that session (nothing pins it — `hyprland-session.target`
  has no `[Install]` section), so both gated units are unreachable there.

**lemurs merges two session sources**, which this draft missed: the scripts in
`/etc/lemurs/wayland/` *and* `.desktop` files from `wayland_sessions_path`.
The packaged entries (`Hyprland`, `Hyprland (uwsm-managed)`, `Steam`) stamp
nothing, and the greeter was in fact pre-selecting one. Both
`wayland.wayland_sessions_path` and `x11.xsessions_path` are therefore
overridden to empty directories, so every graphical entry the greeter offers
goes through a stamping script.

`RICE` reaches user units through two channels: the `set-environment` call
above (before any unit re-evaluation), and the rendered config's systemd
bootstrap line (§2), which lists `RICE` in its
`dbus-update-activation-environment --systemd` import — *both* sessions
now have both channels (the noctalia one gained its second via
`wayland.windowManager.hyprland.systemd.variables`). There is no other
fallback: an earlier draft claimed hyprland's default import would carry it,
which the adversarial review correctly called fiction — the import list is
fixed. `DCONF_PROFILE` has only the one manager-level channel, because
`dbus-update-activation-environment` can set but never unset; the residual
risk is that if the user manager is unreachable at greeter time, `RICE`
still lands via the bootstrap while `DCONF_PROFILE` stays pointed at the
retro profile, giving a half-retro noctalia session.

## 2. Hyprland config: shared base + per-rice layers

`rice/hypr.nix` refactor:

- Extract the rice-agnostic config — monitor, nvidia/env vars, `$mainMod`,
  `$terminal`, all binds, input, misc, ecosystem, render/debug — into a
  shared attrset (`rice/hypr-base.nix`, exported via module arg or a small
  lib file). **The base must contain no visual keys** (general gaps/borders,
  decoration, animations, blur): the current `border_size = 2` /
  `rounding = 20` / animations / blur move into the noctalia layer. This is
  the enforcement for the precedence rule — base wins on conflicts, so
  visual keys simply may not live in the base (review finding: otherwise
  they silently defeat the retro skin). The shared resize submap moves to a
  shared `extraConfig` string consumed by both rices.
- Today's session: `wayland.windowManager.hyprland` consumes base + the
  noctalia layer (now explicitly carrying the visuals), exactly as now. No
  behavioral change; the rendered `~/.config/hypr/hyprland.conf` should be
  diffable-identical (whitespace aside) before/after the refactor.
- New `rice/retroism.nix`: passes base as
  `programs.retroism.hyprland.baseSettings` + the shared submap as
  `hyprland.extraConfig`, plus a session-only overlay:
  - **the systemd session bootstrap exec-once** (mirrors what home-manager
    injects at line 1 of the main config:
    `dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY
    HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP RICE DCONF_PROFILE &&
    systemctl --user stop hyprland-session.target && systemctl --user start
    hyprland-session.target`). Without it `graphical-session.target` never
    starts in the retro session — mako stays down and stale units are never
    re-evaluated (review finding, high). Rendered by the fork module
    (`hyprland.systemdIntegration`, extra import vars passed here).
  - retro visuals from the fork (`hyprland.visualSettings`)
  - `exec-once`: `${programs.retroism.quickshell.command}`,
    `swww img <fork wallpaper>` (reuses the already-running swww daemon —
    `wallpaper.nix` enables it globally, so adding hyprpaper would mean two
    wallpaper daemons; review finding), `hyprctl setcursor` derived from the
    fork's `cursor.{name,size}` option (no hardcoded `Hackneyed-24px`)
  - session env: `GTK_THEME=${themeNames.gtk}`, `DCONF_PROFILE=retroism`,
    `XDG_DATA_DIRS` prepend of the fork's `themes` package share dir,
    `PATH` prepend of the ghostty shim dir (§5)
  - `$menu` override → `programs.retroism.quickshell.launcherCommand`: same
    Super+R key, retro launcher UI (the launcher is skin, the key is not).
    Easy one-line revert to tofi if it grates.
  - the hy3 plugin line, same plugin package as the main session
  - no `nm-applet` (not part of the user's workflow)
- The rendered config is deployed by the fork module to
  `~/.config/hypr/retroism.conf` — the exact path the §1 session script
  execs (review finding: the draft contract left this file undeployed).

## 3. Per-session services

- **noctalia**: add `Unit.ConditionEnvironment=RICE=noctalia` to its user
  unit via home-manager `systemd.user.services` override (exact unit name
  verified in plan). In the retroism session the condition fails cleanly and
  noctalia stays down.
- **mako**: enabled via home-manager with retroism styling (palette from the
  fork: `#101010` background, `#d8d8d8` text, `#207874` accent border,
  square corners), gated `ConditionEnvironment=RICE=retroism`.
  Open item for testing: if retroism's Quickshell ships its own notification
  UI, drop mako.
- **swww**: the daemon stays globally enabled and un-gated (rice-agnostic).
  The retro image is set by `retroism-wallpaper.service`, not an exec-once:
  it is `After`/`Requires` the daemon unit (really named `awww.service`) and
  `PartOf`/`WantedBy` `graphical-session.target`, so systemd orders it after
  the session bootstrap restarts the daemon instead of racing it.
  This draft's original claim — that noctalia "does its own wallpaper
  management", so a shared daemon is harmless — **is false on this machine**:
  the noctalia session sets no wallpaper at all, and swww caches the last
  image per output and restores it at daemon start. The retro wallpaper
  would therefore follow the user back into the noctalia session. The unit
  now runs `swww clear-cache` in `ExecStopPost` (prefixed `-`, since it
  exits non-zero when no cache exists) so the retro image dies with its
  session.
- clipse and other existing user services: untouched, run in both sessions.

## 4. Per-session GTK / icon / cursor theming

No global gtk settings change. Mechanisms, all scoped by session env from §2:

- Widget theme: `GTK_THEME` env only. **As implemented, no `XDG_DATA_DIRS`
  prepend** — the fork puts `themesPackage` in `home.packages`, so the
  profile's share dir is already on `XDG_DATA_DIRS` and a prepend would be
  a no-op (verified in review).
- Icon + cursor theme: a **home-manager-generated dconf profile** (not NixOS
  `programs.dconf.profiles`) at an absolute `DCONF_PROFILE` path — profile
  order: writable `user-db:retroism_user`, then `file-db:` pointing at a
  compiled read-only db of *defaults* (not locks — a lock would also
  override `retroism_user` and break in-session tweaking), then the normal
  `user-db:user` as fallback. Keys are `org/gnome/desktop/interface`
  `icon-theme`/`gtk-theme`/`cursor-theme`/`cursor-size`, sourced from the
  fork's `themeNames` and `cursor.{name,size}`. Writes inside the retro
  session land in `retroism_user`, so in-session tweaks never touch the
  noctalia session's dconf state.
  The db name **must not contain a hyphen**: libdconf interpolates it into
  the D-Bus object path `/ca/desrt/dconf/Writer/%s` without validation, and
  a hyphen is illegal there — an earlier `retroism-user` made every write
  in the session abort with a `g_variant_is_object_path` assertion while
  reads kept working, so the session looked correct and silently persisted
  nothing.
- Known gap (accepted, medium): apps that read theming through the
  xdg-desktop-portal settings portal may see the portal's own environment,
  not the session's `DCONF_PROFILE`. Mitigation: `DCONF_PROFILE` is in the
  §2 bootstrap import list so portal restarts inside the session pick it
  up; test step 3 checks a GTK4/portal app, and if it misthemes, the plan
  adds a portal restart to the session bootstrap.
- Cursor package: `pkgs.hackneyed` (availability verified during planning;
  fallback: package it in the fork).
- GTK test apps: **nemo is not installed on this machine** (the original
  draft assumed it was). Use `thunar` or `pavucontrol` — both GTK3, both
  honour `GTK_THEME`. libadwaita apps will not look retro regardless; that
  is the portal/libadwaita gap above, not a defect.

## 5. Ghostty retro palette

- The fork writes `~/.config/ghostty/retroism.conf` (ported kitty palette:
  16 ANSI colors, bg `#101010`, fg `#d8d8d8`, cursor `#207874`,
  `background-opacity 0.985`, window padding 7×10).
- `rice/retroism.nix` builds a one-file wrapper package: `bin/ghostty` →
  `exec ${real ghostty} --config-file=<that file> "$@"`. **Not a PATH
  prepend** as this draft proposed — hyprland `env =` lines are literal and
  do not expand `$PATH`. The retro layer instead points `$terminal`,
  `$fileManager`, and the clipse bind at the wrapper's store path directly.
- Verified in review: `--config-file` layers *on top of* the user's normal
  ghostty config rather than replacing it, and because the retro file loads
  later, its colors win while font and keybinds survive.

## 6. Flake wiring

`flake.nix`: input `retroism.url = "path:/home/insipx/code/insipx/linux-retroism"`
while iterating (a `path:` URL, so uncommitted fork files are visible;
switch to `github:insipx/linux-retroism` once pushed), with
`homeManagerModules.retroism` added to the linux home-manager module list.
No direct package reference is needed — the module puts `themesPackage` in
`home.packages` itself. Note a `path:` input locks a narHash: after editing
the fork, run `nix flake update retroism` before rebuilding.

## 7. Testing & rollout

1. Refactor-only commit first: base/layer split with no retroism session;
   assert the rendered hyprland.conf is unchanged, rebuild, log in — noctalia
   session works as before. This is the regression gate.
2. Add the retroism session; rebuild. lemurs lists `Retroism` automatically
   (it enumerates `/etc/lemurs/wayland/*`).
3. In-session checks: `~/.config/hypr/retroism.conf` exists and is what
   hyprland loaded; `systemctl --user show-environment` has `RICE=retroism`
   and the retro `DCONF_PROFILE`; `graphical-session.target` active;
   `noctalia.service` inactive (condition failed) and
   `retroism-wallpaper.service` active (exited); exactly one `swww-daemon`,
   showing the retro image; quickshell bar up; Super+R opens the retro
   launcher; `hyprctl getoption general:border_size` = 1; `thunar`/
   `pavucontrol` show ClassicPlatinum + retro icons; `dconf read` returns
   `'RetroismIcons'` *and* a `dconf write` succeeds (the hyphen bug above);
   a notification renders through mako; ghostty retro palette;
   keybinds/hy3/resize-submap behave; cursor per `cursor.name`.
4. Log out → `Hyprland`: `RICE=noctalia`, `DCONF_PROFILE` gone from
   `show-environment`, noctalia up, catppuccin theming intact, normal
   ghostty palette, and **the wallpaper is not the retro one** (the swww
   cache leak this design originally missed).
5. Rollback: single jj commit revert + rebuild.

Known risks: `systemctl --user set-environment` reachability from the lemurs
script pre-compositor (each session has a second channel via the §2
bootstrap); mako losing the D-Bus name race on a session switch (it retries
for ~10s, then the session has no notification daemon for its life); portal
and libadwaita apps not honouring the session dconf profile (§4 gap).

Accepted, not fixed (cosmetic, noctalia→retro direction): `hypridle`/
`hyprlock` are un-gated, so the retro session's lock screen is Catppuccin,
and `$run` (Super+D) still opens tofi rather than a retro launcher.
