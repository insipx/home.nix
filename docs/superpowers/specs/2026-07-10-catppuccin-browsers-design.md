# Catppuccin Mocha for Firefox + Google Chrome

**Date:** 2026-07-10
**Status:** Design approved
**Scope:** Linux (tanjiro) only. Darwin firefox@nightly untouched.

## Goal

Browser UI and website content in Catppuccin Mocha (mauve accent), declaratively,
fitting the existing nix config. Complements the noctalia-driven desktop theming
(2026-05-29 spec) — same locked Mocha, browsers are a layer noctalia doesn't cover.

## Background / discovered facts (July 2026)

- **catppuccin/nix firefox port rejected deliberately.** Its mechanism writes settings
  for the *Firefox Color* extension (`browser-extension-data/FirefoxColor@mozilla.com/storage.js`)
  without installing the extension, requires HM profiles anyway, evaluates via IFD
  (catppuccin/nix#392 lists firefox as unresolved), and its theme data is pinned to
  catppuccin/firefox rev 2023-07-18. Also no google-chrome port exists (blocked upstream
  on nix-community/home-manager#1383).
- **Official Catppuccin AMO static themes** exist per flavor×accent. Mocha Mauve:
  slug `catppuccin-mocha-mauve-git`, GUID `{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}`.
  Force-installable via Firefox `policies.ExtensionSettings` with the AMO
  `latest.xpi` URL. Static themes color browser chrome only.
- **Firefox content dark mode follows the browser theme** by default
  (`layout.css.prefers-color-scheme.content-override` default 3), so a dark Mocha
  theme flips sites to `prefers-color-scheme: dark` with no extra pref.
- **Website theming = catppuccin/userstyles** (134 usercss styles, Less, per-style
  `lightFlavor`/`darkFlavor`/`accentColor` vars) via the **Stylus** extension.
  Stylus has no managed-storage/policy seeding; bulk install is its Backup→Import
  JSON. The Catppuccin Userstyles Customizer
  (catppuccin-userstyles-customizer.uncenter.dev) generates an `import.json` with
  flavor/accent pre-applied. Styles auto-update via `@updateURL` every 24h.
- **userChrome theme:** Cascade is on life-support (moved to cascadefox org,
  "maintainer wanted" as of 2026-05-23). **textfox** chosen instead: active
  (contributors through Jun 2026), ships `flake.nix` + home-manager module upstream
  (`textfox.enable`, `textfox.profiles`, `textfox.config.*`), and deliberately
  hardcodes no colors — it inherits the active Firefox theme via
  `var(--lwt-accent-color)` etc., so the Mocha AMO theme propagates automatically.
- **Firefox module split:** the NixOS `programs.firefox` module is policies-only
  (no profiles/userChrome/extension settings). Home-manager `programs.firefox`
  has profiles, `userChrome`, `settings` (user.js), and its own `policies`
  (injected via the nixpkgs wrapper's `extraPolicies`). HM auto-sets
  `toolkit.legacyUserProfileCustomizations.stylesheets` when userChrome is set.
- **NixOS `programs.chromium`** writes managed policies to
  `/etc/opt/chrome/policies/managed/` (plus chromium + brave) — covers real Google
  Chrome; `extensions` becomes `ExtensionInstallForcelist`.
- Existing imperative profiles on tanjiro: `agn3jjck.default` (default) and
  `5g7z94j2.dev-edition-default`. `home.stateVersion = "23.05"` keeps HM's firefox
  configPath at `~/.mozilla/firefox` (the 26.05 XDG move doesn't apply).
- `home-manager/catppuccin.nix` is dead — imported nowhere (rice/catppuccin.nix is
  the live one).

## Architecture — color flow, one owner per layer

```
Catppuccin Mocha Mauve AMO theme (force-installed, static)
   ├─→ Firefox chrome colors (tabs/toolbars/frame)
   ├─→ textfox userChrome inherits them (no hardcoded palette)
   └─→ sites see prefers-color-scheme: dark (Fx default follows theme)
Catppuccin userstyles via Stylus   → website content (mocha dark / mauve accent)
Chrome web-store mocha theme       → Chrome UI
```

No two systems style the same surface. Flavor mocha / accent mauve matches
`rice/catppuccin.nix` and the global `catppuccin.accent` default.

## Changes

| File | Change |
|---|---|
| `flake.nix` | add input `textfox = { url = "github:adriankarlen/textfox"; inputs.nixpkgs.follows = "nixpkgs"; }` (confirm it exposes a nixpkgs input) |
| `systems.nix` | add textfox HM module to `users.insipx` imports (verify exact output attr, likely `homeManagerModules.default`) |
| `home-manager/machine-specific/linux/firefox.nix` | **new** — all Firefox config (below) |
| `home-manager/machine-specific/linux/default.nix` | import `./firefox.nix` |
| `linux/default.nix` | **remove** `programs.firefox` block; **add** `programs.chromium` policies block |
| `home-manager/catppuccin.nix` | **delete** (dead file) |

### firefox.nix

- `programs.firefox.enable = true; package = pkgs.firefox;` (wrapped → HM policies work).
- Profiles adopt existing dirs (zero data loss):
  - `default`: `id = 0`, `path = "agn3jjck.default"`, `isDefault = true`
  - `dev-edition-default`: `id = 1`, `path = "5g7z94j2.dev-edition-default"` —
    declared only so HM's generated profiles.ini doesn't orphan it.
- `policies.ExtensionSettings`:
  - `"{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}"` → catppuccin-mocha-mauve-git
    latest.xpi, `force_installed`
  - `"{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}"` → styl-us latest.xpi, `force_installed`
- `profiles.default.settings."extensions.activeThemeID" =
  "{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}"` — best-effort activation; may need one
  restart or one Add-ons click on first run.
- `textfox.enable = true; textfox.profiles = [ "default" ];`
  `textfox.config.font.family = "Berkeley Mono";` — accent/background/border stay
  at textfox defaults (theme-inherited).
- Header comment documents the one-time Stylus import (see Manual steps) and that
  slug/GUID are mocha+mauve constants tied to `rice/catppuccin.nix` flavor.

### linux/default.nix (Chrome)

```nix
programs.chromium = {
  enable = true; # policies only — installs no browser
  extensions = [
    "bkkmolkhemgaeaeggcmfbghljjjoofoh" # catppuccin mocha theme
    "clngdbkpkpeebahjckkjfobafhncgmne" # stylus
  ];
};
```

`google-chrome` stays in `environment.systemPackages`.

## Manual steps (once, documented in firefox.nix header)

1. Generate mocha/mauve `import.json` at
   https://catppuccin-userstyles-customizer.uncenter.dev/
2. Stylus → Manage → Backup → Import — in Firefox and Chrome. The bundle also sets
   CSP patching + 24h auto-update; styles self-maintain afterward.
3. First activation: `home-manager switch`/`nixos-rebuild` may refuse to clobber the
   imperative `profiles.ini` — use backup mode (`-b backup`).

## Risks / mitigations

- **profiles.ini clobber on first switch** → backup mode; profile *data* dirs are
  untouched, only the ini is regenerated (both profiles declared, so nothing is
  orphaned). Firefox's own profile manager can no longer create profiles — declare
  new ones in nix instead.
- **`extensions.activeThemeID` is best-effort** for third-party themes (activation
  state also lives in addonStartup.json.lz4) → theme is force-installed regardless;
  worst case one click in about:addons, once.
- **user.js re-asserts declared prefs on every start** — about:config edits to those
  prefs won't persist. Intended behavior.
- **Force-installed addons can't be removed in the UI** — switch
  `installation_mode` to `normal_installed` if it chafes.
- **AMO/webstore `latest` URLs are runtime fetches, not pinned** — accepted: themes
  are effectively frozen upstream, Stylus wants to self-update anyway. Reproducible
  alternative (NUR / `globalExtensions` with store-path XPIs) noted as future option.
- **Chrome theme force-install via policy is likely-works-unverified** (Google docs
  only promise apps/extensions) → fallback: install theme from web store, 2 clicks.
- **textfox is a big visual change** — layers are independent; `textfox.enable =
  false` leaves the Mocha theme + userstyles fully working.
- **Dark Reader** (if ever installed imperatively) fights userstyles → disable it on
  catppuccin-styled sites.

## Out of scope

- Darwin browsers (homebrew firefox@nightly).
- Fully-declarative Stylus styles (HM `extensions.settings` storage.js route) —
  rejected: read-only storage breaks runtime toggling + auto-update, and HM #9211
  state-loss bug.
- catppuccin/nix firefox/chromium ports (see Background).
- Other chromium-family browsers (brave/vivaldi — policies would already apply).

## Success criteria

- Firefox UI: Mocha colors + textfox layout; textfox boxes pick up mauve accent from
  the theme.
- Chrome UI: Mocha theme active.
- GitHub/YouTube/etc render Catppuccin Mocha in both browsers via Stylus.
- Exactly one Firefox package (HM-owned); NixOS `programs.firefox` gone;
  `/etc/firefox/policies` no longer generated.
- Existing profile data (logins, history) intact after switch.
- Rebuild is clean; only manual step performed is the Stylus import (+ at most one
  theme-activation click).
