# Retroism Session Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a "Retroism" entry to the lemurs login picker that boots the user's Hyprland base (hy3, keybinds, monitors) wearing the linux-retroism skin, with the noctalia session unchanged.

**Architecture:** Split the home-manager Hyprland config into a rice-agnostic base and per-rice layers; the fork's `programs.retroism` hm module renders and deploys `~/.config/hypr/retroism.conf`; per-session isolation rides on a `RICE` env var stamped by the lemurs session scripts and `ConditionEnvironment` gates, with GTK/dconf/ghostty theming scoped by session env only.

**Tech Stack:** NixOS + home-manager (flake), jj (colocated; NEVER git), hyprland 0.55 + hy3, lemurs, quickshell, swww, mako, dconf.

## Global Constraints

- VCS is **jj**, never git. Commits are gpg-signed via yubikey — if a jj mutation stalls/fails oddly, ask the user to warm the gpg cache, then retry.
- Spec: `docs/superpowers/specs/2026-08-07-retroism-session-design.md`. Contract options come from the fork's hm module (`programs.retroism.*`) — if an option name differs in the implemented fork, adapt here, not there, and report it.
- The noctalia session must be **byte-identical** in behavior. Task 1 has a render-diff gate; do not proceed past it with a non-empty diff you can't explain as pure reordering.
- The shared hyprland base must contain **no visual keys** (no `general.gaps_*`, `border_size`, `col.*`, `decoration.*`, `animations.*`). Visuals live in each rice's layer.
- `nixos-rebuild switch` requires sudo — only the user runs it. Agents stop at `nixos-rebuild build`.
- Machine/user under test: `nixosConfigurations.tanjiro`, hm user `insipx`.
- **Dependency:** Tasks 2–5 require the fork flake at `/home/insipx/code/insipx/linux-retroism` to be implemented (separate agent, in flight). Task 1 is independent — start there. If the fork isn't ready when Task 2 begins, pause and tell the user.

**Two deliberate deviations from the spec (report in the final summary, update spec after):**
1. §4 dconf: implemented entirely in home-manager using a `file-db:` line and an absolute `DCONF_PROFILE` path instead of NixOS `programs.dconf.profiles` — same semantics (writable `retroism-user` db, read-only defaults, fallback to normal user db), fewer moving parts, and theme names come straight from the fork module options instead of being re-hardcoded at the NixOS layer.
2. §5 ghostty: instead of a PATH shim (hyprland `env =` lines are literal — no `$PATH` expansion, so prepending is unreliable), the retro layer points `$terminal`, `$fileManager`, and the clipse bind at an explicit wrapper package. Same effect, no env expansion gamble.

---

### Task 1: Extract the shared hyprland base (no behavior change)

**Files:**
- Create: `home-manager/machine-specific/linux/rice/hypr-base.nix`
- Modify: `home-manager/machine-specific/linux/rice/hypr.nix`

**Interfaces:**
- Produces: `import ./hypr-base.nix` → `{ settings = <attrset>; resizeSubmap = <string>; }`. `settings` carries every rice-agnostic key; `resizeSubmap` is the verbatim submap block. Task 3 consumes both.

- [ ] **Step 1: Capture the baseline render**

```bash
nix build --out-link /tmp/claude-1000/-etc-nixos/3e4e3dde-0171-411f-b11c-85f2f0f788c9/scratchpad/hyprconf-before \
  '.#nixosConfigurations.tanjiro.config.home-manager.users.insipx.xdg.configFile."hypr/hyprland.conf".source'
```

Expected: builds successfully; the out-link points at the current rendered config.

- [ ] **Step 2: Create `hypr-base.nix`**

Move every rice-agnostic key out of `hypr.nix` verbatim. The file is a plain attrset (no module args):

```nix
# Rice-agnostic Hyprland config shared by every session (noctalia, retroism).
# HARD RULE: no visual keys here — no gaps/border/col.*, no decoration, no
# animations. Those belong to each rice's layer; the retro skin relies on it.
{
  settings = {
    monitor = "DP-1,highrr,0x0,1";
    misc = {
      vrr = 2;
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
    };
    ecosystem = {
      no_update_news = true;
      no_donation_nag = true;
    };
    render = {
      direct_scanout = 2;
    };
    # vfr moved out of misc into debug: in Hyprland 0.55 (debug-only var).
    debug = {
      vfr = true;
    };
    env = [
      "LIBVA_DRIVER_NAME,nvidia"
      "NVD_BACKEND,direct"
      "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      "GBM_BACKEND,nvidia-drm"
      "XDG_SESSION_TYPE,wayland"
      "NODE_EXTRA_CA_CERTS,/etc/volos.crt"
    ];
    "$mainMod" = "SUPER";
    "$terminal" = "ghostty";
    "$fileManager" = "ghostty -e yazi";
    "$menu" = "tofi-drun --drun-launch=true";
    "$run" = "tofi-run | xargs hyprctl dispatch exec";
    "$screenshotRegion" = "hyprshot -m region --raw | satty --filename - --copy-command wl-copy --early-exit";
    "$screenshotWindow" = "hyprshot -m window --raw | satty --filename - --copy-command wl-copy --early-exit";
    "$screenshotScreen" = "hyprshot -m output --raw | satty --filename - --copy-command wl-copy --early-exit";
    exec-once = [ ];
    bind = [
      # ... copy the ENTIRE bind list from hypr.nix:71-139 unchanged ...
    ];
    bindm = [
      "$mainMod, mouse:272, hy3:resizewindow"
      "$mainMod, mouse:273, hy3:movewindow"
    ];
    cursor = {
      no_hardware_cursors = 2;
      use_cpu_buffer = 2;
    };
    # Non-visual general keys ONLY (visual siblings stay in the rice layers)
    general = {
      resize_on_border = true;
      allow_tearing = true;
      layout = "hy3";
    };
    windowrule = [
      # ... copy the ENTIRE windowrule list from hypr.nix:217-237 unchanged ...
    ];
  };

  # Submaps can't be expressed in the settings attrset (stateful blocks).
  # Enter with SUPER+ALT+R, resize with hjkl, leave with ESC or return.
  resizeSubmap = ''
    submap = resize
    binde = , h, resizeactive, -40 0
    binde = , l, resizeactive, 40 0
    binde = , k, resizeactive, 0 -40
    binde = , j, resizeactive, 0 40
    bind = , escape, submap, reset
    bind = , return, submap, reset
    submap = reset
  '';
}
```

The two `# ... copy ...` markers above are instructions to move the existing lists verbatim — the executor copies them from `hypr.nix` (they are long but unchanged; do not retype, cut-and-paste).

- [ ] **Step 3: Rewrite `hypr.nix` as base + noctalia layer**

Keep everything else in the file (clipse systemd service, module options, plugins) unchanged. The `settings`/`extraConfig` become:

```nix
let
  base = import ./hypr-base.nix;
  # The noctalia rice's visual layer — exactly the keys removed from base.
  noctaliaVisuals = {
    general = {
      gaps_in = 5;
      gaps_out = 20;
      border_size = 2;
      # Catppuccin Mocha gradient border (mauve -> blue), dim surface0 when inactive.
      "col.active_border" = "rgba(cba6f7ee) rgba(89b4faee) 45deg";
      "col.inactive_border" = "rgba(313244aa)";
    };
    animations = {
      enabled = true;
      # Tuned for 4K@240 on an RTX 3070: noticeable but short so frames stay high.
      bezier = [
        "easeOutQuint, 0.23, 1, 0.32, 1"
        "snappy, 0.2, 1, 0.2, 1"
        "overshot, 0.05, 0.9, 0.1, 1.05"
      ];
      animation = [
        "windows, 1, 4, overshot, popin 60%"
        "windowsOut, 1, 4, snappy, popin 60%"
        "border, 1, 8, default"
        "borderangle, 1, 6, easeOutQuint"
        "fade, 1, 4, snappy"
        "workspaces, 1, 5, easeOutQuint, slide"
        "specialWorkspace, 1, 5, easeOutQuint, slidevert"
        "layers, 1, 4, snappy, fade"
      ];
    };
    decoration = {
      rounding = 20;
      rounding_power = 2;
      active_opacity = 1.0;
      inactive_opacity = 1.0;
      shadow = {
        enabled = true;
        range = 4;
        render_power = 3;
        color = "rgba(1a1a1aee)";
      };
      blur = {
        enabled = true;
        size = 3;
        passes = 1;
        vibrancy = 0.1696;
      };
    };
    layerrule = [
      "blur on, match:namespace launcher"
      "ignore_alpha 0.1, match:namespace launcher"
      "dim_around on, match:namespace launcher"
    ];
  };
in
{
  # ... unchanged parts of the module ...
  wayland.windowManager.hyprland = {
    # ... existing non-settings options unchanged (enable, configType, plugins, …) ...
    settings = lib.recursiveUpdate base.settings noctaliaVisuals;
    extraConfig = base.resizeSubmap;
  };
}
```

Note `lib` must be in the module's argument set (`{ lib, pkgs, ... }:` — check the existing header and add `lib` if absent).

- [ ] **Step 4: Render and diff against baseline**

```bash
nix build --out-link /tmp/claude-1000/-etc-nixos/3e4e3dde-0171-411f-b11c-85f2f0f788c9/scratchpad/hyprconf-after \
  '.#nixosConfigurations.tanjiro.config.home-manager.users.insipx.xdg.configFile."hypr/hyprland.conf".source'
diff /tmp/claude-1000/-etc-nixos/3e4e3dde-0171-411f-b11c-85f2f0f788c9/scratchpad/hyprconf-before \
     /tmp/claude-1000/-etc-nixos/3e4e3dde-0171-411f-b11c-85f2f0f788c9/scratchpad/hyprconf-after
```

Expected: **empty diff**. `toHyprconf` renders sorted attrsets, and `recursiveUpdate` reproduces the original merged set. If the diff shows anything beyond pure key reordering, stop and fix before committing.

- [ ] **Step 5: Commit**

```bash
jj st   # verify only hypr.nix + hypr-base.nix changed
jj desc -m "Split hyprland config into rice-agnostic base and noctalia layer"
jj new
```

---

### Task 2: Add the retroism flake input and hm module

**Files:**
- Modify: `flake.nix` (inputs block, near the other `github:insipx/*` inputs)
- Modify: `systems.nix:83-92` (tanjiro `home-manager.users.insipx.imports`)

**Interfaces:**
- Produces: `inputs.retroism` (flake input) and `programs.retroism.*` options available in hm modules. Task 3 consumes them.

- [ ] **Step 1: Add the input to `flake.nix`**

```nix
    retroism = {
      # Local path while iterating (picks up uncommitted files in the fork
      # working copy — a git+file: URL would only see committed state).
      # Switch to github:insipx/linux-retroism once the fork is pushed.
      url = "path:/home/insipx/code/insipx/linux-retroism";
      inputs.nixpkgs.follows = "nixpkgs";
    };
```

- [ ] **Step 2: Import the hm module in `systems.nix`**

In `nixosConfigurations.tanjiro` → `home-manager.users.insipx.imports`, add one line alongside the existing module imports:

```nix
                    inputs.retroism.homeManagerModules.retroism
```

- [ ] **Step 3: Lock and verify the module is wired**

```bash
nix flake lock
nix eval '.#nixosConfigurations.tanjiro.config.home-manager.users.insipx.programs.retroism.enable'
```

Expected: `nix flake lock` adds a `retroism` node; the eval prints `false` (module present, not enabled). If the eval errors with "attribute … not found", the fork's module output name differs — check `nix flake show path:/home/insipx/code/insipx/linux-retroism` and adapt the import.

Note: after any subsequent fork edit, refresh with `nix flake update retroism` (path inputs lock a narHash).

- [ ] **Step 4: Commit**

```bash
jj st   # verify only flake.nix, flake.lock, systems.nix changed
jj desc -m "Add retroism fork as flake input with hm module"
jj new
```

---

### Task 3: The retroism rice module

**Files:**
- Create: `home-manager/machine-specific/linux/rice/retroism.nix`
- Modify: `home-manager/machine-specific/linux/rice/default.nix` (imports list)

**Interfaces:**
- Consumes: `import ./hypr-base.nix` → `{ settings, resizeSubmap }` (Task 1); `programs.retroism.*` (Task 2).
- Produces: deployed `~/.config/hypr/retroism.conf`; `RICE`-gated noctalia unit; mako config. Task 4's session script execs the deployed path.

- [ ] **Step 1: Discover the wallpaper filename**

```bash
nix build --out-link /tmp/claude-1000/-etc-nixos/3e4e3dde-0171-411f-b11c-85f2f0f788c9/scratchpad/retro-wallpapers \
  'path:/home/insipx/code/insipx/linux-retroism#wallpapers'
ls /tmp/claude-1000/-etc-nixos/3e4e3dde-0171-411f-b11c-85f2f0f788c9/scratchpad/retro-wallpapers/
```

Expected: a listing of wallpaper files (possibly under a `share/` prefix — note the exact relative path). Pick one (prefer a plain retro desktop image; ask the user if several look plausible) and substitute its path for `<WALLPAPER-REL-PATH>` in Step 2.

- [ ] **Step 2: Write `retroism.nix`**

```nix
# The Retroism login session: the linux-retroism skin (quickshell bar, GTK +
# icon themes, retro palette) over our shared hyprland base. Selected at the
# lemurs greeter; per-session isolation rides on RICE= in the systemd user
# environment. Spec: docs/superpowers/specs/2026-08-07-retroism-session-design.md
{
  config,
  lib,
  pkgs,
  ...
}:
let
  base = import ./hypr-base.nix;
  retro = config.programs.retroism;

  # Ghostty wearing the retro palette. Explicit wrapper instead of a PATH
  # shim: hyprland `env =` lines are literal (no $PATH expansion), so a
  # prepend can't be expressed reliably there.
  retroGhostty = pkgs.writeShellScriptBin "ghostty" ''
    exec ${lib.getExe config.programs.ghostty.package} \
      --config-file=${config.xdg.configHome}/ghostty/retroism.conf "$@"
  '';

  # dconf: per-session profile. First line = writable db (in-session tweaks
  # land there, never in the shared user db). Second = read-only retro
  # defaults. Third = the normal user db as fallback for everything else.
  retroDconfDefaults = pkgs.runCommand "retroism-dconf-db" {
    nativeBuildInputs = [ pkgs.dconf ];
  } ''
    mkdir db.d
    cat > db.d/00-retroism <<EOF
    [org/gnome/desktop/interface]
    icon-theme='${retro.themeNames.icon}'
    gtk-theme='${retro.themeNames.gtk}'
    cursor-theme='${retro.cursor.name}'
    cursor-size=${toString retro.cursor.size}
    EOF
    dconf compile $out db.d
  '';
  dconfProfilePath = "${config.xdg.configHome}/dconf-retroism-profile";

  # Fails eval loudly if the option doesn't exist in the implemented fork —
  # see the contract-adaptation note below Step 2.
  wallpaper = "${retro.wallpapersPackage}/<WALLPAPER-REL-PATH>";

  # Session-only overlay merged onto the shared base. Non-visual keys only —
  # the fork's visualSettings supplies the retro look and wins for its keys.
  retroOverlay = {
    env = base.settings.env ++ [
      "GTK_THEME,${retro.themeNames.gtk}"
      "DCONF_PROFILE,${dconfProfilePath}"
    ];
    exec-once = [
      # swww daemon is global (wallpaper.nix); just set this session's image.
      "swww img ${wallpaper}"
    ];
    # Retro launcher on the same key (Super+R): the launcher is skin, the
    # key is not. Revert to the base tofi line if it grates.
    "$menu" = retro.quickshell.launcherCommand;
    "$terminal" = "${retroGhostty}/bin/ghostty";
    "$fileManager" = "${retroGhostty}/bin/ghostty -e yazi";
  };
in
{
  imports = [ ];

  programs.retroism = {
    enable = true;
    quickshell.enable = true;
    ghostty.enable = true;
    hyprland = {
      deploy = true;
      baseSettings = lib.recursiveUpdate base.settings retroOverlay // {
        # bind list needs the clipse entry re-pointed at the retro ghostty;
        # lists don't merge, so rebuild it with one line substituted.
        bind = map (
          b:
          if lib.hasInfix "tanjiro.clipse" b then
            "$mainMod, V, exec, ${retroGhostty}/bin/ghostty --class=\"tanjiro.clipse\" -e 'clipse'"
          else
            b
        ) base.settings.bind;
      };
      extraConfig = base.resizeSubmap;
      plugins = [ "${pkgs.hy3}/lib/libhy3.so" ];
      systemd.extraVariables = [
        "RICE"
        "DCONF_PROFILE"
      ];
    };
  };

  # dconf profile file (absolute DCONF_PROFILE path; dconf uses it directly).
  xdg.configFile."dconf-retroism-profile".text = ''
    user-db:retroism-user
    file-db:${retroDconfDefaults}
    user-db:user
  '';

  # Notifications in the retro session. No ConditionEnvironment needed: mako
  # is dbus-activated on org.freedesktop.Notifications, which noctalia owns
  # in its own session — so mako can only ever win in the retro session.
  services.mako = {
    enable = true;
    settings = retro.mako.settings;
  };

  # Keep noctalia out of the retro session. Stamped by the lemurs scripts
  # (linux/services.nix) via `systemctl --user set-environment` and the
  # rendered config's bootstrap import.
  systemd.user.services.noctalia.Unit.ConditionEnvironment = "RICE=noctalia";
}
```

Add `./retroism.nix` to `rice/default.nix`'s imports list.

Two contract points to adapt if the implemented fork differs (check `nix flake show` / the fork's module source, report any rename): `retro.wallpapersPackage` (the module may instead expose the package only via `packages.wallpapers` — then use `inputs.retroism.packages.${pkgs.system}.wallpapers` and add `inputs` to the module args) and the exact unit name `noctalia.service` (verify: `systemctl --user list-units 'noctalia*'`).

- [ ] **Step 3: Build the deployed render and inspect**

```bash
nix build --out-link /tmp/claude-1000/-etc-nixos/3e4e3dde-0171-411f-b11c-85f2f0f788c9/scratchpad/retroconf \
  '.#nixosConfigurations.tanjiro.config.home-manager.users.insipx.xdg.configFile."hypr/retroism.conf".source'
head -5 /tmp/claude-1000/-etc-nixos/3e4e3dde-0171-411f-b11c-85f2f0f788c9/scratchpad/retroconf
grep -E "border_size|rounding|animations|plugin|dbus-update-activation-environment|RICE" \
  /tmp/claude-1000/-etc-nixos/3e4e3dde-0171-411f-b11c-85f2f0f788c9/scratchpad/retroconf
```

Expected: line 1 (or the first exec-once) is the systemd bootstrap containing `RICE` and `DCONF_PROFILE`; `border_size = 1`, `rounding = 0`, `animations` disabled (fork visuals won over the base); a `plugin = /nix/store/...libhy3.so` line; the submap block at the end.

- [ ] **Step 4: Commit**

```bash
jj st   # verify only retroism.nix + rice/default.nix changed
jj desc -m "Add retroism rice module consuming the fork hm module"
jj new
```

---

### Task 4: Lemurs session entries

**Files:**
- Modify: `linux/services.nix:74-120` (`environment.etc` block)

**Interfaces:**
- Consumes: the deployed `~/.config/hypr/retroism.conf` (Task 3).
- Produces: `/etc/lemurs/wayland/Retroism` and a RICE-stamping `Hypr`. lemurs lists `/etc/lemurs/wayland/*` automatically — no other registration.

- [ ] **Step 1: Stamp the existing Hypr entry**

Replace the `etc."lemurs/wayland/Hypr"` script text:

```nix
    etc."lemurs/wayland/Hypr" = {
      mode = "0755";
      enable = true;
      text = ''
        #! /bin/sh
        # Stamp the rice into the systemd user manager BEFORE the compositor
        # starts, so ConditionEnvironment gates see it and a stale value from
        # a previous session of the other rice is always overwritten.
        systemctl --user set-environment RICE=noctalia || true
        export RICE=noctalia
        exec ${lib.getExe pkgs.hyprland}
      '';
    };
```

- [ ] **Step 2: Add the Retroism entry**

```nix
    etc."lemurs/wayland/Retroism" = {
      mode = "0755";
      enable = true;
      text = ''
        #! /bin/sh
        systemctl --user set-environment RICE=retroism || true
        export RICE=retroism
        exec ${lib.getExe pkgs.hyprland} --config "$HOME/.config/hypr/retroism.conf"
      '';
    };
```

`Gamez` is untouched.

- [ ] **Step 3: Build the etc entries**

```bash
nix build --out-link /tmp/claude-1000/-etc-nixos/3e4e3dde-0171-411f-b11c-85f2f0f788c9/scratchpad/retro-session \
  '.#nixosConfigurations.tanjiro.config.environment.etc."lemurs/wayland/Retroism".source'
cat /tmp/claude-1000/-etc-nixos/3e4e3dde-0171-411f-b11c-85f2f0f788c9/scratchpad/retro-session
```

Expected: the script above with store paths substituted.

- [ ] **Step 4: Commit**

```bash
jj st   # verify only linux/services.nix changed
jj desc -m "Add Retroism lemurs session and stamp RICE in session scripts"
jj new
```

---

### Task 5: Full build and live verification

**Files:** none (verification only)

- [ ] **Step 1: Full system build**

```bash
nixos-rebuild build --flake .#tanjiro
```

Expected: builds clean. This is the agent's stopping point for system state.

- [ ] **Step 2: Hand to the user for switch + login tests**

Ask the user to run `sudo nixos-rebuild switch --flake .#tanjiro`, then walk the spec §7 checklist with them:

Retro session (pick `Retroism` in lemurs):
```bash
systemctl --user show-environment | grep RICE          # RICE=retroism
systemctl --user is-active graphical-session.target    # active
pgrep -a swww-daemon | wc -l                           # exactly 1
hyprctl getoption general:border_size                  # int: 1
notify-send test                                       # renders via mako (retro colors)
gsettings get org.gnome.desktop.interface icon-theme   # 'RetroismIcons' (via DCONF_PROFILE)
```
Plus by eye: quickshell bar, retro wallpaper, Super+R opens the retro launcher, ghostty retro palette, hy3/keybinds/resize submap work, cursor is the retro one, nemo shows retro GTK + icons, a GTK4/portal app themes correctly (known gap — if it misthemes, file it for the plan follow-up, not a blocker).

Noctalia session (log out, pick `Hypr`):
```bash
systemctl --user show-environment | grep RICE          # RICE=noctalia
systemctl --user is-active noctalia.service            # active
gsettings get org.gnome.desktop.interface icon-theme   # unchanged from before
```
Plus by eye: catppuccin borders/animations, normal ghostty palette, tofi on Super+R.

- [ ] **Step 3: Record outcomes**

Any check that fails: fix within the relevant task's file, rebuild, re-verify. When all pass, report the two spec deviations (plan header) and update the spec's §4/§5 mechanism wording to match reality.

---

## Self-review notes

- Spec coverage: §1→Task 4, §2→Tasks 1+3, §3→Task 3 (mako/noctalia/swww), §4→Task 3 (dconf/GTK env), §5→Task 3 (retroGhostty), §6→Task 2, §7→Task 5. No uncovered sections.
- The two spec deviations are declared in Global Constraints and re-reported at the end.
- Type/name consistency: `base.settings`/`base.resizeSubmap` (Tasks 1→3), `RICE=noctalia|retroism` strings (Tasks 3↔4), deployed path `~/.config/hypr/retroism.conf` (Tasks 3↔4) all match.
