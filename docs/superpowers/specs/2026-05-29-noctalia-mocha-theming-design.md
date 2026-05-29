# Locked Catppuccin Mocha — noctalia-driven desktop theming

**Date:** 2026-05-29
**Status:** Design approved, pending spec review

## Goal

Make the whole desktop consistently **Catppuccin Mocha**, with **noctalia as the single
source of truth** for colors. Today the theming is split-brain: noctalia uses the
`Monochrome` scheme, Hyprland borders are a hand-written catppuccin mauve→blue gradient,
catppuccin home-manager modules theme a few apps independently, and swww has no wallpaper
set. Replace that with one coherent system where noctalia's scheme drives every app it can.

## Background / discovered facts

- noctalia ships a **Catppuccin** predefined scheme (`Assets/ColorScheme/Catppuccin/Catppuccin.json`)
  that is already Mocha: `mSurface #1e1e2e`, `mPrimary #cba6f7` (mauve), terminal palette =
  mocha. These are the exact colors of the current Hyprland border gradient
  (`cba6f7` → `89b4fa`), so switching is visually seamless.
- noctalia has a **template-based app-theming engine** (`Services/Theming/`). For each enabled
  app it renders the active scheme through a template and writes a **dedicated color file**
  to `~/.config/<app>/...` (never the app's main config), then runs a post-hook to reload.
  Built-in targets include: hyprland, ghostty, btop, gtk3/4, yazi, fuzzel, cava, zathura,
  helix, emacs, discord, vscode, zed, spicetify, and more.
- App theming is **declarative** via the home-manager noctalia module:
  - `settings.templates.activeTemplates` = `[{ id = "<app>"; enabled = true; }]`
    (schema confirmed in `Commons/Migrations/Migration40.qml` and `TemplatesSubTab.qml`).
  - `settings.templates.enableUserTheming` = master toggle (bool).
  - `programs.noctalia-shell.user-templates` (HM option) writes
    `~/.config/noctalia/user-templates.toml` for any custom input→output mapping.
- noctalia writes color files to these paths (from `TemplateRegistry.qml`):
  - hyprland → `~/.config/hypr/noctalia/noctalia-colors.conf`
  - ghostty  → `~/.config/ghostty/themes/noctalia`
  - btop, gtk, yazi → their respective `~/.config` theme paths.
- ghostty supports `config-file = <path>` includes; Hyprland supports `source = <path>`.

## The core architectural tension

home-manager owns config files as **read-only nix-store symlinks**. noctalia writes theme
files **at runtime** and its post-hooks try to *append include lines* (sed/`>>`) to the
app's main config. On HM-managed read-only files that append fails. So "noctalia drives
everything" cannot mean noctalia edits HM-owned files.

### Resolution — the include-file pattern

- **noctalia owns the color files only** — it writes to dedicated theme files
  (`noctalia-colors.conf`, `themes/noctalia`, etc.), never the main config.
- **home-manager owns the main config + the single include directive** that points at
  noctalia's runtime color file.
- noctalia's append post-hooks become harmless no-ops (the include already exists, placed
  by HM); we never rely on them to mutate HM files.

Boundary: noctalia = colors. home-manager = structure + one `source`/`config-file` line per
themed app. No two systems write the same file.

## Components / changes

1. **`home-manager/machine-specific/linux/rice/noctalia.nix`**
   - `settings.colorSchemes.predefinedScheme`: `"Monochrome"` → `"Catppuccin"`.
   - Add `settings.templates.enableUserTheming = true;`
   - Add `settings.templates.activeTemplates` for: `hyprland`, `ghostty`, `btop`, `gtk`
     (gtk3 + gtk4 as the registry names them), `yazi`. (Confirm exact ids against
     `TemplateRegistry.qml` during implementation.)

2. **`home-manager/machine-specific/linux/rice/hypr.nix`**
   - Add to settings: `source = "~/.config/hypr/noctalia/noctalia-colors.conf"` (via the
     module's `source`/`importantPrefixes` handling, or `extraConfig` if needed so it loads
     after the generated block).
   - **Remove** the manual `general."col.active_border"` / `"col.inactive_border"` gradient
     — noctalia now owns border colors through the sourced file.

3. **ghostty (`home-manager/ghostty.nix`)**
   - Add `config-file = themes/noctalia` (relative include) to the HM-managed ghostty config.
   - **Remove** `catppuccin.ghostty.enable` so the two don't fight over palette.

4. **catppuccin HM modules (`home-manager/catppuccin.nix`, `rice/catppuccin.nix`)**
   - Remove per-app catppuccin toggles that noctalia now handles (`ghostty`; `hyprland`
     already disabled). Keep ones noctalia does **not** theme and that already work
     (`bat` uses a custom Mocha theme; `fish`, `eza` stay unless noctalia covers them).
   - Net intent: no app is themed by two systems at once.

5. **Wallpaper (`home-manager/machine-specific/linux/rice/wallpaper.nix`)**
   - swww daemon runs but no wallpaper is set. Set a Mocha-friendly wallpaper (declare a
     file + an `swww img` exec-once or a small systemd user service). Scheme stays the
     predefined Catppuccin (not wallpaper-derived), but a wallpaper still matters visually.

6. **Bar cleanup (`noctalia.nix`)**
   - `fancy-audiovisualizer` and `github-feed` plugins are enabled but **not placed** in any
     `bar.widgets.{left,center,right}` list. Either place them or drop the enable to avoid
     loading unused plugins.

## Data flow

```
predefinedScheme = "Catppuccin"  (noctalia, single source of truth)
        │  AppThemeService.generate() renders templates →
        ├─ ~/.config/hypr/noctalia/noctalia-colors.conf   ← hypr `source =`  (HM places line)
        ├─ ~/.config/ghostty/themes/noctalia              ← ghostty `config-file =` (HM places line)
        ├─ ~/.config/btop/themes/noctalia.theme           ← btop theme set to noctalia
        ├─ ~/.config/gtk-3.0 / gtk-4.0 colors             ← gtk
        └─ ~/.config/yazi/...                             ← yazi flavor
```

## Risks / mitigations

- **R1 — post-hook append to HM read-only files fails.** Mitigation: HM pre-places every
  include/`source` line; noctalia only writes color files. A failing append post-hook is a
  no-op, not a breakage.
- **R2 — declarative reach (RESOLVED).** Both built-in app templates
  (`settings.templates.activeTemplates`) and custom templates
  (`programs.noctalia-shell.user-templates`) are settable from HM. No GUI clicks required.
- **R3 — first-switch flash.** Until noctalia runs once and writes the color files, apps may
  show default/unstyled colors (Hyprland `source` of a missing file logs a warning). Resolves
  after noctalia starts. Acceptable; optionally seed initial files.
- **R4 — exact template ids / output paths.** Names like `gtk` vs `gtk3`/`gtk4` and the precise
  ghostty/yazi output paths must be confirmed against `TemplateRegistry.qml` in this exact
  noctalia version during implementation, not assumed.

## Out of scope

- Wallpaper-derived dynamic palettes (matugen/wallust). We chose the locked predefined
  Catppuccin scheme; dynamic colors are a future option, not this work.
- Migrating Hyprland config to lua mode (separately decided against; staying hyprlang).
- Theming apps noctalia doesn't have templates for.

## Success criteria

- noctalia bar renders in Catppuccin Mocha (not Monochrome).
- Hyprland active/inactive borders come from noctalia's color file; no hand-written gradient
  remains in `hypr.nix`.
- ghostty palette/bg/fg match the Mocha scheme via the noctalia include; `catppuccin.ghostty`
  is gone.
- No config file is written by both noctalia and home-manager.
- `hyprctl configerrors` is clean after switch.
- A wallpaper is visibly set.
- No enabled-but-unplaced noctalia widgets/plugins.
