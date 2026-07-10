# Catppuccin Mocha Browsers Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Firefox + Google Chrome UI and website content themed Catppuccin Mocha (mauve), declaratively, per `docs/superpowers/specs/2026-07-10-catppuccin-browsers-design.md`.

**Architecture:** Firefox moves from the NixOS `programs.firefox` module to home-manager ownership (profiles adopt the existing on-disk profile dirs). Catppuccin Mocha Mauve AMO theme + Stylus are force-installed via HM `policies.ExtensionSettings`; textfox provides userChrome and inherits the theme's colors. Chrome gets the mocha web-store theme + Stylus via the NixOS `programs.chromium` policy module. Website content is catppuccin/userstyles in Stylus (one manual import, then self-updating).

**Tech Stack:** Nix flakes, home-manager (as NixOS module), textfox flake (`github:adriankarlen/textfox`), Firefox enterprise policies, Chrome managed policies.

## Global Constraints

- **VCS is jj (colocated). NEVER run `git` commands.** Follow the jujutsu skill: check `jj st`; start each task with `jj new -m "<message>"` (current `@` holds unrelated user WIP — stack on top, never modify it); edits auto-snapshot; verify with `jj st`.
- Scope: Linux (tanjiro) only. Do not touch `darwin-config.nix` or `home-manager/machine-specific/mac`.
- Flavor/accent constants: **mocha / mauve**. Theme slug `catppuccin-mocha-mauve-git`, theme GUID `{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}`, Stylus GUID `{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}`, Chrome theme ID `bkkmolkhemgaeaeggcmfbghljjjoofoh`, Chrome Stylus ID `clngdbkpkpeebahjckkjfobafhncgmne`.
- Verification: `nix eval` with the **`path:` prefix** (`path:/etc/nixos`) — new files live in jj's `@` commit, which colocated git does not yet track; plain `/etc/nixos` flake refs would silently omit them.
- Do NOT run `nixos-rebuild switch` — the final activation is the user's step (documented in Task 5).
- Existing profile dirs (do not rename/move): `~/.mozilla/firefox/agn3jjck.default` (default) and `~/.mozilla/firefox/5g7z94j2.dev-edition-default`.

## File Structure

| File | Responsibility |
|---|---|
| `flake.nix` | + `textfox` input |
| `flake.lock` | lock for new input (`nix flake lock`) |
| `systems.nix` | wire textfox HM module into `users.insipx`; set `home-manager.backupFileExtension` |
| `home-manager/machine-specific/linux/firefox.nix` | **new** — all Firefox config (package, profiles, policies, textfox) |
| `home-manager/machine-specific/linux/default.nix` | import `./firefox.nix` |
| `linux/default.nix` | remove `programs.firefox`; add `programs.chromium` policies |
| `home-manager/catppuccin.nix` | **delete** (dead — imported nowhere) |

---

### Task 1: textfox flake input + module wiring

**Files:**
- Modify: `flake.nix` (inputs attrset, after `noctalia` block ~line 94)
- Modify: `flake.lock` (via `nix flake lock`)
- Modify: `systems.nix:81-89` (insipx imports) and `systems.nix:72-91` (home-manager block)

**Interfaces:**
- Produces: HM options `textfox.enable`, `textfox.profiles`, `textfox.config.*` available to Task 2; `home-manager.backupFileExtension = "backup"` so first activation survives the profiles.ini clobber.

- [ ] **Step 1: Start the task commit**

```bash
jj st   # expect @ = user WIP or previous task; do not modify it
jj new -m "Add textfox flake input and wire HM module"
```

- [ ] **Step 2: Add input to `flake.nix`**

After the `noctalia = { ... };` block, add:

```nix
    textfox = {
      url = "github:adriankarlen/textfox";
      inputs.nixpkgs.follows = "nixpkgs";
    };
```

- [ ] **Step 3: Update the lock**

Run: `nix flake lock /etc/nixos`
Expected: adds a `textfox` node to `flake.lock`, no errors.

- [ ] **Step 4: Wire module + backup extension in `systems.nix`**

In the tanjiro `home-manager` block: add `backupFileExtension` next to `useGlobalPkgs`, and the module to insipx imports:

```nix
            home-manager = {
              sharedModules = [
                inputs.sops-nix.homeModules.sops
              ];
              useGlobalPkgs = true;
              useUserPackages = true;
              # first firefox activation clobbers the imperative profiles.ini;
              # back up instead of failing
              backupFileExtension = "backup";
              users.insipx =
                { ... }:
                {
                  imports = [
                    inputs.noctalia.homeModules.default
                    inputs.catppuccin.homeModules.catppuccin
                    inputs.hyprland.homeManagerModules.default
                    inputs.textfox.homeManagerModules.default
                    # inputs.doom-emacs.homeModule
                    ./home-manager
                    ./home-manager/machine-specific/linux
                  ];
                };
```

- [ ] **Step 5: Verify eval**

Run: `nix eval "path:/etc/nixos#nixosConfigurations.tanjiro.config.home-manager.users.insipx.textfox.enable"`
Expected: `false` (module wired, not yet enabled).

- [ ] **Step 6: Verify commit state**

```bash
jj st   # expect: M flake.nix, M flake.lock, M systems.nix under the task commit
```

---

### Task 2: `firefox.nix` — HM-owned Firefox with theme, Stylus, textfox

**Files:**
- Create: `home-manager/machine-specific/linux/firefox.nix`
- Modify: `home-manager/machine-specific/linux/default.nix:4-7` (imports)

**Interfaces:**
- Consumes: `textfox.*` options from Task 1.
- Produces: HM `programs.firefox` fully configured; Task 3 may then remove the NixOS-level `programs.firefox` without losing the browser.
- **Profile-key constraint:** profile attr names MUST equal the on-disk dir names (`agn3jjck.default`, `5g7z94j2.dev-edition-default`). HM derives `path` from the attr name, and textfox writes its `chrome/` payload to `~/.mozilla/firefox/<attr>/chrome` — a pretty attr name like `default` would split userChrome.css and its imports across two dirs. `name = "..."` is only the cosmetic `Name=` field in profiles.ini.

- [ ] **Step 1: Start the task commit**

```bash
jj new -m "Theme firefox with catppuccin mocha via HM, textfox, stylus"
```

- [ ] **Step 2: Create `home-manager/machine-specific/linux/firefox.nix`**

```nix
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
```

- [ ] **Step 3: Import it in `home-manager/machine-specific/linux/default.nix`**

```nix
  imports = [
    ./rice
    ./firefox.nix
    # ../../emacs.nix
  ];
```

- [ ] **Step 4: Verify eval (assertions + policy wiring)**

Run: `nix eval "path:/etc/nixos#nixosConfigurations.tanjiro.config.home-manager.users.insipx.programs.firefox.finalPackage.name"`
Expected: a `firefox-<version>` name, no assertion failures (HM policy-wrapper and profile assertions run during this eval).

Run: `nix eval "path:/etc/nixos#nixosConfigurations.tanjiro.config.home-manager.users.insipx.programs.firefox.profiles.\"agn3jjck.default\".path"`
Expected: `"agn3jjck.default"`.

- [ ] **Step 5: Verify commit state**

```bash
jj st   # expect: A .../firefox.nix, M .../linux/default.nix
```

---

### Task 3: NixOS layer — drop `programs.firefox`, add Chrome policies

**Files:**
- Modify: `linux/default.nix:179-182` (remove firefox block), same `programs = { ... }` attrset (add chromium block)

**Interfaces:**
- Consumes: Task 2's HM firefox (so removing the system one leaves exactly one firefox).
- Produces: `/etc/opt/chrome/policies/managed/default.json` with `ExtensionInstallForcelist`; `/etc/firefox/policies` no longer generated.

- [ ] **Step 1: Start the task commit**

```bash
jj new -m "Theme chrome with catppuccin, move firefox ownership to HM"
```

- [ ] **Step 2: Edit `linux/default.nix`**

Remove:

```nix
    firefox = {
      enable = true;
      package = pkgs.firefox;
    };
```

In its place add:

```nix
    # policies only — installs no browser; applies to google-chrome via
    # /etc/opt/chrome/policies. firefox is home-manager-owned (machine-specific/linux/firefox.nix)
    chromium = {
      enable = true;
      extensions = [
        "bkkmolkhemgaeaeggcmfbghljjjoofoh" # catppuccin mocha theme
        "clngdbkpkpeebahjckkjfobafhncgmne" # stylus
      ];
    };
```

- [ ] **Step 3: Verify chrome policy file renders**

Run: `nix eval --raw "path:/etc/nixos#nixosConfigurations.tanjiro.config.environment.etc.\"opt/chrome/policies/managed/default.json\".text"`
Expected: JSON containing `"ExtensionInstallForcelist":["bkkmolkhemgaeaeggcmfbghljjjoofoh","clngdbkpkpeebahjckkjfobafhncgmne"]`.

- [ ] **Step 4: Verify system firefox is gone**

Run: `nix eval "path:/etc/nixos#nixosConfigurations.tanjiro.config.programs.firefox.enable"`
Expected: `false`.

- [ ] **Step 5: Verify commit state**

```bash
jj st   # expect: M linux/default.nix
```

---

### Task 4: Delete dead `home-manager/catppuccin.nix`

**Files:**
- Delete: `home-manager/catppuccin.nix`

**Interfaces:**
- Consumes: nothing. File is imported nowhere (verified 2026-07-10; the live one is `home-manager/machine-specific/linux/rice/catppuccin.nix`).

- [ ] **Step 1: Start the task commit**

```bash
jj new -m "Remove dead home-manager/catppuccin.nix"
```

- [ ] **Step 2: Confirm it is still unreferenced, then delete**

Run: `grep -rn "catppuccin.nix" /etc/nixos --include="*.nix"`
Expected: only the `./catppuccin.nix` import inside `home-manager/machine-specific/linux/rice/default.nix` (which refers to `rice/catppuccin.nix`). If anything else references `home-manager/catppuccin.nix`, STOP and report.

```bash
rm /etc/nixos/home-manager/catppuccin.nix
```

- [ ] **Step 3: Verify eval still clean**

Run: `nix eval "path:/etc/nixos#nixosConfigurations.tanjiro.config.home-manager.users.insipx.catppuccin.flavor"`
Expected: `"mocha"` (from `rice/catppuccin.nix`).

- [ ] **Step 4: Verify commit state**

```bash
jj st   # expect: D home-manager/catppuccin.nix
```

---

### Task 5: Full build + handoff

**Files:** none (verification only)

- [ ] **Step 1: Build the full system (no switch)**

Run: `nix build "path:/etc/nixos#nixosConfigurations.tanjiro.config.system.build.toplevel" -o /tmp/claude-1000/-etc-nixos/64e2e19a-910f-4f5a-b59a-27f205577926/scratchpad/result-tanjiro`
Expected: builds to completion (textfox package + wrapped firefox build here). Report any failure verbatim.

- [ ] **Step 2: Review the task stack**

```bash
jj log --limit 8 --no-pager
jj st
```

Expected: four task commits stacked above the user's WIP commit, working copy clean of stray files.

- [ ] **Step 3: Hand off to user (do NOT run switch)**

Report to user:

1. `sudo nixos-rebuild switch --flake /etc/nixos#tanjiro` (their command; profiles.ini gets a `.backup` copy automatically).
2. Restart Firefox — Catppuccin theme + textfox load; if the theme didn't auto-activate, enable it once in about:addons → Themes.
3. Stylus userstyles, once per browser: generate mocha/mauve `import.json` at https://catppuccin-userstyles-customizer.uncenter.dev/, then Stylus icon → Manage → Backup → Import (Firefox and Chrome).
4. Chrome: verify the mocha theme applied after restart; if policy force-install didn't take for the theme, install it from the web store (2 clicks): https://chromewebstore.google.com/detail/bkkmolkhemgaeaeggcmfbghljjjoofoh

---

## Self-review notes

- Spec coverage: flake input (T1), systems.nix wiring + backup (T1), firefox.nix (T2), machine-specific import (T2), linux/default.nix remove+add (T3), dead-file delete (T4), build + manual steps (T5). All spec "Changes" rows covered.
- Deviation from spec (intentional, discovered during verification): profile attr names are the on-disk dir names, not `default`/`dev-edition-default`, because textfox keys its `chrome/` home.file payload by profile attr name while HM keys the profile dir by `path` (= attr name by default). Using pretty names would split textfox's CSS across two directories. Spec's "adopt existing dirs, zero data loss" intent is preserved via `name = "..."`.
- No placeholders; all code complete; GUIDs/IDs consistent across tasks and with the spec.
