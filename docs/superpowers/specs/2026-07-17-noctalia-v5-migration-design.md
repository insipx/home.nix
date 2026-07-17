# Noctalia v4 → v5 migration (tanjiro)

**Date:** 2026-07-17
**Status:** Design approved
**Scope:** Linux (tanjiro) only. Stage 1 = minimal v5 boots stably; plugins + theming templates are Stage 2.

## Goal

Replace the frozen legacy-v4 noctalia shell with the v5 native-runtime rewrite. v4's
quickshell architecture creates a full-screen top-layer input scrim that intermittently
eats pointer clicks/hover across all apps (Steam install dialog unclickable, Datadog
hover menus don't pop, general "can't click sometimes"). Root-caused to
`noctalia-background-*` layer input region + stale-mask double-buffer bug; legacy-v4 is
frozen (bug reports auto-closed since 2026-05), upstream remedy is v5 which drops
quickshell/Qt entirely.

## Background / discovered facts (verified against beta.3 source + docs, 2026-07-17)

- **v5 is beta-only** — latest `v5.0.0-beta.3` (2026-07-16); no stable release. v4.7.7 is
  the last v4. v5 = "new generation with a native runtime," a fresh install, **not** an
  automatic upgrade; drops quickshell/Qt.
- **Flake:** same repo `github:noctalia-dev/noctalia`, pin ref `v5.0.0-beta.3`. HM module
  attr **unchanged** (`homeModules.default`). Verified: beta.3 ships `nix/home-module.nix`.
- **Option namespace changed:** `programs.noctalia-shell.*` (v4) → **`programs.noctalia.*`**
  (v5). Options present in beta.3 home-module: `enable`, `systemd.enable`, `package`,
  `validateConfig` (default **true**), `settings` (attrset | str | path), `customPalettes`.
  **No `plugins` / `pluginSettings` options** — v4's plugin block has no v5 equivalent in
  the module; plugins are out of scope for Stage 1.
- **Settings:** nix attrset → serialized by `pkgs.formats.toml` to
  `~/.config/noctalia/config.toml` (XDG). v4 JSON config is **not** auto-migrated.
- **Build-time validation:** with `validateConfig = true`, the module runs
  `noctalia config validate <config.toml>` inside a `runCommand` at build time — a wrong
  key **fails `nixos-rebuild`**, not the running session. This is the primary safety net:
  the "shell won't start" failure from the last v5 attempt becomes a catchable build error.
- **Launcher is tofi, not noctalia** (`rice/launcher.nix`); the `launcher`-namespace
  layerrules in `hypr.nix` are tofi's. Noctalia runs bar+widgets only, started by its
  systemd user service. **No noctalia IPC keybinds exist in hypr.nix** → hypr.nix needs no
  changes for this migration.
- v5 config shape (from docs, to be schema-locked by the validator during implementation):
  bar widgets under `[bar.left|center|right]` widget lists; theme via
  `[theme] mode/source/builtin`; exact widget-id casing and the bar array form
  (`[[bar]]` vs `[bar]`) must be confirmed by the validator, not assumed.
- **Known v5-beta risk:** noctalia #2196 (bar icons not clickable, NixOS regression) —
  a beta bug, milder and different from the v4 scrim; if it recurs it is upstream, not our
  config.

## Architecture — side-by-side files, one-line switch

Per user preference: **do not rewrite `rice/noctalia.nix`.** Add a new
`rice/noctalia-v5.nix` and change the import in `rice/default.nix`. The old file stays on
disk as the port reference.

Note: only one is importable at a time regardless — after the flake moves to beta.3, the
v4 `programs.noctalia-shell.*` options cease to exist, so `noctalia.nix` would fail to
evaluate. The `default.nix` import swap is mandatory, not cosmetic; keeping the old file is
purely for reference and easy visual diff.

```
flake.nix        noctalia ref legacy-v4 → v5.0.0-beta.3
rice/default.nix ./noctalia.nix → ./noctalia-v5.nix   (one line)
rice/noctalia-v5.nix  NEW — programs.noctalia (v5 schema), minimal bar, dark theme, systemd
rice/noctalia.nix     UNCHANGED on disk — reference only, no longer imported
```

## Components / changes

1. **`flake.nix`** — `noctalia.url` ref `legacy-v4` → `v5.0.0-beta.3`; then `nix flake lock`.
2. **`rice/noctalia-v5.nix`** (new):
   - `programs.noctalia.enable = true; systemd.enable = true;`
   - `settings` attrset: a bar (position top, density comfortable) with a minimal widget
     set (control-center, workspace, active-window, clock), `[theme]` dark + builtin
     `monochrome` (keeps current Monochrome look — zero visual surprise), any required
     shell defaults. Exact keys/casing locked by the validator (plan step 1).
   - `validateConfig` left at default `true`.
   - No plugins.
3. **`rice/default.nix`** — import `./noctalia.nix` → `./noctalia-v5.nix`.
4. **`rice/noctalia.nix`** — untouched.
5. **`hypr.nix`** — untouched (no noctalia keybinds; tofi owns the launcher namespace).

## Data flow

```
programs.noctalia.settings (nix attrset)
  → pkgs.formats.toml.generate → config.toml
  → noctalia config validate  (BUILD TIME; fails rebuild on bad key)
  → ~/.config/noctalia/config.toml
  → noctalia.service (systemd user) → bar renders, native runtime, no scrim layer
```

## Implementation-first safety step

The plan's first task builds a candidate `config.toml` and runs
`<beta.3-noctalia>/bin/noctalia config validate` on it directly (using a `nix run` / the
prefetched store path), iterating until it passes — locking the real schema before the nix
attrset is written. This front-loads the exact failure mode that broke the last attempt.

## Risks / mitigations

- **R1 — wrong v5 config key.** Mitigation: `validateConfig` catches it at build time;
  plan step 1 validates the raw TOML before translating to nix.
- **R2 — v5 bar-not-clickable beta regression (#2196).** Mitigation: it's isolated to a
  bare Stage-1 config, so diagnosable in minutes; it's a beta bug, not our config. If hit,
  report upstream / pin a different beta commit.
- **R3 — visual regression.** Mitigation: Stage 1 keeps Monochrome + top bar; widgets are a
  subset, so the bar looks sparser but not alien. Full parity is Stage 2.
- **R4 — losing the working v4 setup.** Mitigation: `rice/noctalia.nix` kept verbatim;
  revert = flip `default.nix` import back + flake ref back to `legacy-v4` + relock.
- No rollback ceremony beyond the above (per user).

## Out of scope (Stage 2, separate spec/plan)

- Re-adding plugins: catwalk, mini-docker, fancy-audiovisualizer, github-feed,
  update-count (need v5 `label_key` plugin API; some may not be ported).
- Porting the 2026-05-29 theming spec's noctalia template engine (app color source of
  truth) to the v5 template/palette schema.
- Full bar-widget parity with the current v4 layout.

## Success criteria

- `nixos-rebuild` completes (v5 config validator passes at build time).
- After switch: noctalia v5 bar renders; `systemctl --user status noctalia` active.
- Steam install dialog buttons and Datadog hover menus work — no cross-app click/hover
  loss (the v4 scrim is gone).
- `rice/noctalia.nix` still present on disk, unmodified.
- No changes to `hypr.nix`.
