# Noctalia v4 → v5 Migration Implementation Plan (Stage 1)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the frozen legacy-v4 noctalia shell (quickshell scrim eats clicks) with a minimal, booting v5.0.0-beta.3 config, per `docs/superpowers/specs/2026-07-17-noctalia-v5-migration-design.md`.

**Architecture:** Bump the `noctalia` flake input to `v5.0.0-beta.3`, add a new `rice/noctalia-v5.nix` using the v5 `programs.noctalia` schema, and switch the import in `rice/default.nix`. The old `rice/noctalia.nix` stays on disk as a reference. No plugins, no theming templates (Stage 2).

**Tech Stack:** Nix flakes, home-manager (as NixOS module), noctalia v5 (native runtime, TOML config), Hyprland.

## Global Constraints

- **VCS is jj (colocated). NEVER run `git`.** Follow the jujutsu skill: `jj st`; start each task with `jj new -m "<msg>"` — the current `@` may hold an unrelated `nix flake update` change; stack on top, don't modify it. Edits auto-snapshot; verify with `jj st`. GPG signing is on; if a jj mutation times out, warm the cache (`gpg --batch --pinentry-mode loopback --passphrase '' -s -o /dev/null <(echo x)`) and retry.
- Scope: Linux (tanjiro), Stage 1 only. Do NOT re-add plugins or port theming templates.
- Verification uses the **`path:` prefix** (`path:/etc/nixos`) so jj-tracked-but-uncommitted new files are seen.
- Do NOT run `nixos-rebuild switch` — activation is the user's step (Task 5).
- **v5 config schema is VERIFIED against the beta.3 binary** (`config export full` + `config validate`), not the docs. Key facts, exact:
  - Bar is `[bar]` with `order = ["default"]` and a `[bar.default]` table. Widget slots are **`start` / `center` / `end`** (NOT left/right). Widget ids are **lowercase-hyphenated strings**: `launcher`, `workspaces`, `active-window`, `clock`, `control-center`, `session`, `media`, `tray`, `network`, `volume`, `battery`, `wallpaper`, `notifications`, `clipboard`, `bluetooth`, `brightness`.
  - Theme: `[theme]` with `mode` (`"dark"`/`"light"`), `source = "builtin"`, `builtin` (capitalized, e.g. `"Monochrome"`, `"Noctalia"`, `"Catppuccin"`).
  - Namespace is `programs.noctalia.*`; HM module attr `homeModules.default`; exe `noctalia`.
- **`validateConfig` only catches TOML SYNTAX errors (exit 1). Unknown keys and bad enum VALUES are warnings (exit 0) — they pass the build and are silently ignored at runtime.** So the real safety checks are (a) the export-diff in Task 2 to catch unknown keys, and (b) the live smoke test in Task 5. Do not rely on the build failing on a bad key.
- Prebuilt v5 store path available this session: `/nix/store/a37npzf6l1midrx7m7vq264xf6whwkp5-noctalia-5.0.0` (exe at `/bin/noctalia`). If absent, rebuild: `nix build "github:noctalia-dev/noctalia/v5.0.0-beta.3#default"`.

## File Structure

| File | Responsibility |
|---|---|
| `flake.nix` | `noctalia.url` ref `legacy-v4` → `v5.0.0-beta.3` |
| `flake.lock` | relock (`nix flake lock`) |
| `home-manager/machine-specific/linux/rice/noctalia-v5.nix` | **new** — v5 shell config (bar, theme, systemd) |
| `home-manager/machine-specific/linux/rice/default.nix` | import `./noctalia.nix` → `./noctalia-v5.nix` |
| `home-manager/machine-specific/linux/rice/noctalia.nix` | untouched (reference) |

---

### Task 1: Bump flake input to v5.0.0-beta.3

**Files:**
- Modify: `flake.nix:91-94` (`noctalia` input)
- Modify: `flake.lock` (via `nix flake lock`)

**Interfaces:**
- Produces: the v5 `programs.noctalia` HM options (namespace change from `programs.noctalia-shell`) available to Task 3; the old `programs.noctalia-shell` options cease to exist, which is why Task 4's import swap is mandatory.

- [ ] **Step 1: Start the task commit**

```bash
jj st
jj new -m "Bump noctalia flake input to v5.0.0-beta.3"
```

- [ ] **Step 2: Edit `flake.nix`**

Change:

```nix
    noctalia = {
      url = "github:noctalia-dev/noctalia/legacy-v4";
      inputs.nixpkgs.follows = "nixpkgs";
    };
```

to:

```nix
    noctalia = {
      url = "github:noctalia-dev/noctalia/v5.0.0-beta.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
```

- [ ] **Step 3: Relock**

Run: `nix flake lock /etc/nixos`
Expected: updates the `noctalia` (and `noctalia-qs`) nodes in `flake.lock`, no errors.

- [ ] **Step 4: Confirm the HM module exposes v5 options**

Run: `nix eval "path:/etc/nixos#nixosConfigurations.tanjiro.config.home-manager.users.insipx.programs.noctalia.enable" 2>&1 | tail -3`
Expected: **an error** like `option ... does not exist` OR `false` — either way it must be the `programs.noctalia` (v5) namespace, not `noctalia-shell`. If it errors because `rice/noctalia.nix` still sets `programs.noctalia-shell` (now-undefined options), that is EXPECTED at this task boundary and is fixed in Task 4. Note it and proceed; do not "fix" noctalia.nix.

- [ ] **Step 5: Verify commit state**

```bash
jj st   # expect: M flake.nix, M flake.lock
```

---

### Task 2: Author + validate the v5 config TOML (schema lock)

**Files:**
- Create (scratch, not committed): `/tmp/claude-1000/-etc-nixos/64e2e19a-910f-4f5a-b59a-27f205577926/scratchpad/noctalia-v5.toml`

**Interfaces:**
- Produces: a validated TOML config whose exact tables/keys Task 3 translates verbatim into the nix attrset. This task is the safety step — it front-loads schema errors before nix wiring.

- [ ] **Step 1: Write the candidate config**

Write `/tmp/claude-1000/-etc-nixos/64e2e19a-910f-4f5a-b59a-27f205577926/scratchpad/noctalia-v5.toml`:

```toml
[bar]
order = ["default"]

[bar.default]
enabled = true
position = "top"
density = "comfortable"
start = ["launcher", "workspaces"]
center = ["active-window"]
end = ["control-center", "clock", "session"]

[theme]
mode = "dark"
source = "builtin"
builtin = "Monochrome"
```

- [ ] **Step 2: Validate TOML syntax (must exit 0)**

Run: `/nix/store/a37npzf6l1midrx7m7vq264xf6whwkp5-noctalia-5.0.0/bin/noctalia config validate /tmp/claude-1000/-etc-nixos/64e2e19a-910f-4f5a-b59a-27f205577926/scratchpad/noctalia-v5.toml`
Expected: `✓ Config is valid` (0 warnings ideally). Exit 0. If a `WARN ... unknown setting`/`unknown value` appears, a key or enum is wrong — fix it against the export in Step 3 and re-run. Syntax ERROR = exit 1, must be fixed.

- [ ] **Step 3: Diff every key against the authoritative schema (catches unknown keys `validate` only warns on)**

Run:
```bash
N=/nix/store/a37npzf6l1midrx7m7vq264xf6whwkp5-noctalia-5.0.0/bin/noctalia
XDG_CONFIG_HOME=/tmp/nv5e XDG_STATE_HOME=/tmp/nv5e $N config export full > /tmp/nv5-full.toml 2>/dev/null
# every table + key we use must appear in the full export
for tbl in '[bar]' '[bar.default]' '[theme]'; do grep -qF "$tbl" /tmp/nv5-full.toml && echo "OK table $tbl" || echo "MISSING table $tbl"; done
for key in 'order' 'enabled' 'position' 'density' 'start' 'center' 'end' 'mode' 'source' 'builtin'; do grep -qE "^[[:space:]]*$key = " /tmp/nv5-full.toml && echo "OK key $key" || echo "MISSING key $key"; done
```
Expected: all `OK`. Any `MISSING` = that key isn't real; remove it or find the correct name in `/tmp/nv5-full.toml` and update both the TOML and (later) the nix.

- [ ] **Step 4: No commit**

This task produces only a scratch file used as the source of truth for Task 3. Nothing to commit.

---

### Task 3: Create `rice/noctalia-v5.nix`

**Files:**
- Create: `home-manager/machine-specific/linux/rice/noctalia-v5.nix`

**Interfaces:**
- Consumes: the validated TOML from Task 2 (translated key-for-key), the v5 options from Task 1.
- Produces: `programs.noctalia` config that Task 4 activates by import.

- [ ] **Step 1: Start the task commit**

```bash
jj new -m "Add minimal noctalia v5 shell config"
```

- [ ] **Step 2: Create the file**

The `settings` attrset mirrors the Task-2 TOML exactly (nixpkgs `formats.toml` serializes `bar.default` → `[bar.default]`, lists → TOML arrays).

```nix
# Noctalia v5 (native-runtime rewrite; replaces the quickshell v4 whose
# full-screen scrim layer intermittently ate clicks — Steam dialogs, Datadog
# menus). Stage 1: minimal bar + Monochrome dark theme, no plugins, no theming
# templates (those are Stage 2). See the 2026-07-17 migration spec.
#
# Namespace is programs.noctalia (v4 used programs.noctalia-shell). Settings are
# a nix attrset serialized to ~/.config/noctalia/config.toml. Schema verified
# against the beta.3 binary (`noctalia config export full`): bar slots are
# start/center/end, widget ids are lowercase-hyphenated, theme.builtin is
# capitalized. rice/noctalia.nix is kept as the v4 reference, no longer imported.
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
          density = "comfortable";
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
```

- [ ] **Step 3: No eval yet**

The file isn't imported until Task 4, so it has no effect on eval here. Proceed.

- [ ] **Step 4: Verify commit state**

```bash
jj st   # expect: A .../rice/noctalia-v5.nix
```

---

### Task 4: Switch the import + verify serialized config

**Files:**
- Modify: `home-manager/machine-specific/linux/rice/default.nix:4-10` (imports)

**Interfaces:**
- Consumes: `noctalia-v5.nix` from Task 3.
- Produces: an evaluable NixOS config where `programs.noctalia` is active and `programs.noctalia-shell` is gone; the generated `config.toml` in the HM home-files.

- [ ] **Step 1: Start the task commit**

```bash
jj new -m "Switch rice to noctalia v5, retire v4 import"
```

- [ ] **Step 2: Edit `rice/default.nix`**

Change:

```nix
  imports = [
    ./hypr.nix
    ./hypridle.nix
    ./launcher.nix
    ./wallpaper.nix
    ./catppuccin.nix
    ./noctalia.nix
  ];
```

to (swap the last import; leave the others):

```nix
  imports = [
    ./hypr.nix
    ./hypridle.nix
    ./launcher.nix
    ./wallpaper.nix
    ./catppuccin.nix
    ./noctalia-v5.nix
  ];
```

- [ ] **Step 3: Eval the whole HM config (must succeed now)**

Run: `nix eval "path:/etc/nixos#nixosConfigurations.tanjiro.config.home-manager.users.insipx.programs.noctalia.enable" 2>&1 | tail -3`
Expected: `true`. (If it still errors about `programs.noctalia-shell`, the old import wasn't fully removed — recheck Step 2.)

- [ ] **Step 4: Verify the serialized config.toml content**

Run:
```bash
nix eval --raw "path:/etc/nixos#nixosConfigurations.tanjiro.config.home-manager.users.insipx.xdg.configFile.\"noctalia/config.toml\".source" 2>&1 | tail -1
```
Expected: a `/nix/store/...-config.toml` (or `noctalia-config`) path. Then:
```bash
cat "$(nix eval --raw "path:/etc/nixos#nixosConfigurations.tanjiro.config.home-manager.users.insipx.xdg.configFile.\"noctalia/config.toml\".source" 2>/dev/null)"
```
Expected: TOML containing `[bar.default]` with `start`/`center`/`end`, and `[theme]` `builtin = "Monochrome"`. Confirm no `[bar.default]` key is missing vs Task 2's TOML.

- [ ] **Step 5: Verify commit state**

```bash
jj st   # expect: M .../rice/default.nix
```

---

### Task 5: Full build + handoff

**Files:** none (verification only)

- [ ] **Step 1: Build the full system (no switch)**

Run: `nix build "path:/etc/nixos#nixosConfigurations.tanjiro.config.system.build.toplevel" -o /tmp/claude-1000/-etc-nixos/64e2e19a-910f-4f5a-b59a-27f205577926/scratchpad/result-noctalia-v5`
Expected: builds to completion. The v5 package + the build-time `noctalia config validate` (on our config.toml) both run here. Report any failure verbatim. Note: an unknown-key warning will NOT fail this build (validator warns, exit 0) — that is why Task 2's export-diff exists.

- [ ] **Step 2: Review the task stack**

```bash
jj log --limit 8 --no-pager
jj st
```
Expected: four task commits (Task 2 added none) stacked above the pre-existing changes; working copy clean of stray files.

- [ ] **Step 3: Hand off to user (do NOT run switch)**

Report to user, verbatim steps:

1. `sudo nixos-rebuild switch --flake /etc/nixos#tanjiro`
2. Restart the noctalia service (or re-login): `systemctl --user restart noctalia`
3. **Live smoke test — this is the real validation** (the build-time validator does not catch runtime issues):
   - Bar renders at top in Monochrome, with launcher/workspaces/active-window/clock/control-center/session widgets.
   - `systemctl --user status noctalia` → `active (running)`.
   - **The bug this migration targets:** open Steam → a game → Install → the Install button IN THE POPUP now responds; and Datadog hover menus pop out. Cross-app click/hover loss should be gone (v4 scrim removed).
4. If the bar renders but widgets aren't clickable, that's the known v5-beta regression (noctalia #2196), not our config — report back and we pin a different beta commit or file upstream.
5. Rollback if needed: flip `rice/default.nix` import back to `./noctalia.nix`, flake ref back to `legacy-v4`, `nix flake lock`, rebuild.

---

## Self-review notes

- Spec coverage: flake bump (T1), schema-locked config (T2), new v5 file (T3), import swap + serialized-config check (T4), build + smoke handoff (T5). noctalia.nix untouched (T3/T4 leave it), hypr.nix untouched (not in any task). All spec "Components / changes" rows covered.
- Correction vs spec: the spec claimed `validateConfig` fails the build on a bad key. VERIFIED FALSE against the binary — it warns (exit 0) on unknown keys/values, exit-1s only on TOML syntax. The plan compensates with the Task-2 export-diff and the Task-5 live smoke test, and says so in Global Constraints + T5 Step 1. This is a strengthening, not a scope change.
- Schema is verified real (bar start/center/end, lowercase-hyphen widget ids, capitalized theme.builtin), not doc-guessed.
- No placeholders; all code/commands complete; option names consistent across tasks (`programs.noctalia`, `bar.default`, `start/center/end`).
