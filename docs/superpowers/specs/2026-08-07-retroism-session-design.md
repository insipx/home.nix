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

- `Hypr` script (modified): `systemctl --user set-environment RICE=noctalia`
  (plus `export RICE=noctalia`), then `exec hyprland` as today.
- `Retroism` script (new): `systemctl --user set-environment RICE=retroism`
  (plus export), then
  `exec hyprland --config $HOME/.config/hypr/retroism.conf`.
- `Gamez` is untouched; it never reaches a graphical-session shell rice.

`RICE` reaches user units through two deliberate channels, both verified in
the plan: the `systemctl --user set-environment` call above (before any
unit re-evaluation), and the rendered config's systemd bootstrap line (§2)
which lists `RICE` in its `dbus-update-activation-environment --systemd`
import. There is no other fallback — an earlier draft claimed hyprland's
default import would carry it, which the adversarial review correctly
called out as fiction (the import list is fixed).

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
- **swww**: stays globally enabled and un-gated (rice-agnostic daemon).
  Each session sets its own image: noctalia does its own wallpaper
  management; the retro session's `swww img` exec-once (§2) overrides the
  restored last wallpaper at startup.
- clipse and other existing user services: untouched, run in both sessions.

## 4. Per-session GTK / icon / cursor theming

No global gtk settings change. Mechanisms, all scoped by session env from §2:

- Widget theme: `GTK_THEME` env + themes package on `XDG_DATA_DIRS`.
- Icon + cursor theme: NixOS `programs.dconf.profiles.retroism` — profile
  order: writable `user-db:retroism-user`, then `system-db:retroism`
  (*defaults*, not locks — a lock would also override `retroism-user` and
  break in-session tweaking; review wording fix) carrying
  `org/gnome/desktop/interface` `icon-theme`/`gtk-theme`/`cursor-theme`
  from the fork's `themeNames` + `cursor.name`, then fallback to the normal
  user db. Writes inside the retro session land in `retroism-user`, so
  in-session tweaks never touch the noctalia session's dconf state.
- Known gap (accepted, medium): apps that read theming through the
  xdg-desktop-portal settings portal may see the portal's own environment,
  not the session's `DCONF_PROFILE`. Mitigation: `DCONF_PROFILE` is in the
  §2 bootstrap import list so portal restarts inside the session pick it
  up; test step 3 checks a GTK4/portal app, and if it misthemes, the plan
  adds a portal restart to the session bootstrap.
- Cursor package: `pkgs.hackneyed` (availability verified during planning;
  fallback: package it in the fork).
- nemo comes from `home.packages` (both sessions have it installed; it only
  *looks* retro in the retroism session).

## 5. Ghostty retro palette

- The fork writes `~/.config/ghostty/retroism.conf` (ported kitty palette:
  16 ANSI colors, bg `#101010`, fg `#d8d8d8`, cursor `#207874`,
  `background-opacity 0.985`, window padding 7×10).
- `rice/retroism.nix` builds a one-file shim package: `bin/ghostty` →
  `exec ${real ghostty} --config-file=<that file> "$@"`, prepended to PATH
  only inside the retroism session (§2 env). Ghostty loads the include on
  top of the user's normal config, so behavior/keybinds survive; only looks
  change. `$terminal = ghostty` in the shared base resolves to the shim
  automatically.

## 6. Flake wiring

`flake.nix`: input `retroism.url = "github:insipx/linux-retroism"` (or a
local path during iteration), `homeManagerModules.retroism` added to the
linux home-manager module list. The `themes` package is also referenced
directly for the §4 `XDG_DATA_DIRS` prepend.

## 7. Testing & rollout

1. Refactor-only commit first: base/layer split with no retroism session;
   assert the rendered hyprland.conf is unchanged, rebuild, log in — noctalia
   session works as before. This is the regression gate.
2. Add the retroism session; rebuild. lemurs lists `Retroism` automatically
   (it enumerates `/etc/lemurs/wayland/*`).
3. In-session checks: `~/.config/hypr/retroism.conf` exists and is what
   hyprland loaded; `systemctl --user show-environment | grep RICE` says
   `retroism`; `graphical-session.target` is active; exactly one wallpaper
   daemon (swww) running; quickshell bar up; Super+R opens the retro
   launcher; `hyprctl getoption general:border_size` = 1; GTK app (nemo)
   shows ClassicPlatinum + retro icons; a GTK4/portal app themes correctly
   (§4 gap check); `notify-send` renders through mako; ghostty opens with
   retro palette; keybinds/hy3/resize-submap behave; cursor per
   `cursor.name`.
4. Log out → `Hypr`: `RICE=noctalia` in the user-manager env, noctalia up,
   catppuccin theming intact, no retro leak (`gsettings get
   org.gnome.desktop.interface icon-theme` unchanged, ghostty normal
   palette).
5. Rollback: single jj commit revert + rebuild.

Known risks: retroism QML hardcoding paths or pinning a quickshell version
(fixed in the fork — that is what the fork is for); `systemctl --user
set-environment` reachability from the lemurs script pre-compositor
(verified first thing in the plan; the §2 bootstrap import is the second
channel); mako vs quickshell notification overlap (test step 3); portal
theming (§4 gap).
