# The Retroism login session: the linux-retroism skin (quickshell bar, GTK +
# icon themes, retro palette) over our shared hyprland base. Selected at the
# lemurs greeter; per-session isolation rides on RICE= in the systemd user
# environment. Spec: docs/superpowers/specs/2026-08-07-retroism-session-design.md
#
# Nothing here may touch wayland.windowManager.hyprland — that renders the
# noctalia session's ~/.config/hypr/hyprland.conf, which must stay untouched.
# The retro session is a *separate* rendered config at ~/.config/hypr/retroism.conf
# (programs.retroism.hyprland.deploy), execed by the session script.
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

  # Theme names/cursor come from the fork's read-only options, never hardcoded.
  retroDconfKeyfile = pkgs.writeText "00-retroism" ''
    [org/gnome/desktop/interface]
    icon-theme='${retro.themeNames.icon}'
    gtk-theme='${retro.themeNames.gtk}'
    cursor-theme='${retro.cursor.name}'
    cursor-size=${toString retro.cursor.size}
  '';

  retroDconfDefaults =
    pkgs.runCommand "retroism-dconf-db" { nativeBuildInputs = [ pkgs.dconf ]; }
      ''
        mkdir db.d
        cp ${retroDconfKeyfile} db.d/00-retroism
        dconf compile $out db.d
      '';

  # dconf: per-session profile. First line = writable db (in-session tweaks
  # land there, never in the shared user db). Second = read-only retro
  # defaults. Third = the normal user db as fallback for everything else.
  dconfProfilePath = "${config.xdg.configHome}/dconf-retroism-profile";

  # Fails eval loudly if the option doesn't exist in the implemented fork.
  wallpaper = "${retro.wallpapersPackage}/share/wallpapers/retroism/metropolis.png";

  # Same binary home-manager wires to the swww systemd unit (wallpaper.nix),
  # rather than trusting it to be on the session PATH. Read through the
  # current option name (`services.awww`); `services.swww` is a renamed alias
  # that traces a deprecation warning on every eval.
  swwwBin = "${config.services.awww.package}/bin/swww";

  # The daemon's unit is named after the home-manager *option*, not the binary
  # it runs: `services.awww` (wallpaper.nix) renders `awww.service`, whose
  # ExecStart is swww-daemon. Ordering against the obvious-looking
  # `swww.service` would name a unit that does not exist, and systemd treats
  # ordering on an absent unit as vacuously satisfied — no error, no ordering,
  # and the race below quietly restored. Verified against the running manager:
  # `systemctl --user show awww.service -p Id` => Id=awww.service.
  swwwUnit = "awww.service";

  # Retro-styled mako config as a store file. Deliberately NOT
  # `services.mako.enable`: that module writes ~/.config/mako/config and adds
  # mako to `dbus.packages`, both user-global — so a notification arriving in
  # the noctalia session before noctalia has claimed
  # org.freedesktop.Notifications would D-Bus-activate mako with the retro
  # palette and let it hold the name for that session's lifetime. Launching it
  # from the retro session's exec-once with an explicit --config is the only
  # form that is actually session-scoped.
  #
  # mako's format is `key=value` lines plus optional `[criteria]` sections.
  # The fork's mako.settings is flat today; nested attrsets are rendered as
  # sections anyway so a future criteria block can't silently vanish.
  makoValue = v: if builtins.isBool v then lib.boolToString v else toString v;
  makoKeyValues = lib.mapAttrsToList (k: v: "${k}=${makoValue v}");
  retroMakoConfig = pkgs.writeText "mako-retroism.conf" (
    lib.concatStringsSep "\n" (
      makoKeyValues (lib.filterAttrs (_: v: !lib.isAttrs v) retro.mako.settings)
      ++ lib.mapAttrsToList (
        name: attrs: "\n[${name}]\n" + lib.concatStringsSep "\n" (makoKeyValues attrs)
      ) (lib.filterAttrs (_: v: lib.isAttrs v) retro.mako.settings)
    )
    + "\n"
  );

  # By store path, like swwwBin: putting pkgs.mako on the user profile would
  # relink share/dbus-1/services/fr.emersion.mako.service and reopen the very
  # leak this avoids.
  makoBin = "${pkgs.mako}/bin/mako";

  # Same by-store-path rationale as swwwBin/makoBin, applied to the retry loops
  # below. The mako loop runs under Hyprland's `/bin/sh -c` with whatever PATH
  # the session inherited; the wallpaper loop runs under systemd, which gives a
  # service only the user manager's PATH. If `seq` were missing in either,
  # `$(seq 1 50)` would expand to nothing and the loop body would never run —
  # for mako, silently leaving the session with no notification daemon for its
  # entire life.
  seqBin = "${pkgs.coreutils}/bin/seq";
  sleepBin = "${pkgs.coreutils}/bin/sleep";

  # ExecStart for retroism-wallpaper.service. Retries the *effect* (`swww img`),
  # not a probe: only the image call succeeding proves the image is on the
  # daemon we were ordered after. The retry is still needed despite that
  # ordering, because systemd calls a Type=simple daemon "started" the moment it
  # forks, which says nothing about swww-daemon's socket accepting connections
  # yet. Capped at 50 * 0.2s = 10s, then `exit 1` so a genuinely dead daemon
  # fails the unit loudly in the journal rather than leaving a wallpaper-less
  # session behind a green unit.
  #
  # systemd is not a shell: it strips the outer single quotes and hands the rest
  # to sh as a single argument, but it substitutes `$VAR`/`${VAR}` on the way.
  # `$(` is not a variable reference and survives verbatim (checked against this
  # machine's systemd); a bare `$i` would not, so this loop never dereferences
  # its counter.
  setWallpaperCommand =
    "${pkgs.bash}/bin/sh -c 'for i in $(${seqBin} 1 50); do "
    + "${swwwBin} img ${wallpaper} && exit 0; ${sleepBin} 0.2; done; exit 1'";

  retroGhosttyBin = "${retroGhostty}/bin/ghostty";

  # The clipse bind names its binary directly rather than going through
  # $terminal (it needs --class). Rewrite only the binary token, so whatever
  # key and flags the base assigns survive and multiple clipse binds stay
  # distinct. Asserted below so a base that renames the token fails loudly
  # instead of silently launching the noctalia-themed ghostty.
  clipseBinds = lib.filter (lib.hasInfix "tanjiro.clipse") base.settings.bind;
  clipseGhosttyToken = "exec, ghostty ";

  # Session-only overlay merged onto the shared base. Non-visual keys only —
  # the fork's visualSettings supplies the retro look and wins for its keys.
  retroOverlay = {
    env = base.settings.env ++ [
      "GTK_THEME,${retro.themeNames.gtk}"
      "DCONF_PROFILE,${dconfProfilePath}"
    ];
    exec-once = [
      # The wallpaper is deliberately NOT here — it is retroism-wallpaper.service
      # below, so systemd orders it after the daemon this session restarts
      # instead of racing it. See the comment on that unit.
      #
      # Notifications. Launching mako from exec-once with an explicit --config
      # (rather than as a home-manager user service or via D-Bus activation) is
      # what keeps it session-scoped: it lives and dies with this Hyprland
      # instance and reads only the retro store config. That placement does not,
      # however, guarantee it can *start*. mako requests
      # org.freedesktop.Notifications with neither REPLACE_EXISTING nor QUEUE
      # and exits immediately on -EEXIST. Arriving from the noctalia session,
      # noctalia.service still holds that name until the bootstrap entry's
      # blocking `systemctl --user stop hyprland-session.target` finishes — and
      # Hyprland fires exec-once entries concurrently, so this one usually wins
      # the race and dies. mako blocks while healthy and only returns non-zero
      # on that collision, so retry on the same 10s bound as swww above. Without
      # the loop a single early failure leaves the session with no notification
      # daemon for its entire life, and with D-Bus activation deliberately
      # removed there is nothing to self-heal it.
      "for i in $(${seqBin} 1 50); do ${makoBin} --config ${retroMakoConfig} && break; ${sleepBin} 0.2; done"
    ];
    # Retro launcher on the same key (Super+R): the launcher is skin, the
    # key is not. Revert to the base tofi line if it grates.
    "$menu" = retro.quickshell.launcherCommand;
    "$terminal" = retroGhosttyBin;
    "$fileManager" = "${retroGhosttyBin} -e yazi";
    # Lists don't merge — recursiveUpdate takes this whole list.
    bind = map (
      b:
      if lib.hasInfix "tanjiro.clipse" b then
        lib.replaceStrings [ clipseGhosttyToken ] [ "exec, ${retroGhosttyBin} " ] b
      else
        b
    ) base.settings.bind;
  };
in
{
  programs.retroism = {
    enable = true;
    quickshell.enable = true;
    ghostty.enable = true;
    hyprland = {
      deploy = true;
      baseSettings = lib.recursiveUpdate base.settings retroOverlay;
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

  assertions = [
    # Pre-condition: every bind we *selected* is actually rewritable. Catches a
    # base that renames the binary token (`exec, ghostty ` -> something else)
    # while keeping the tanjiro.clipse class.
    {
      assertion = lib.all (lib.hasInfix clipseGhosttyToken) clipseBinds;
      message =
        "retroism.nix: a clipse bind in hypr-base.nix no longer contains "
        + "'${clipseGhosttyToken}', so the retro-ghostty rewrite is a no-op and the "
        + "retro session would launch the noctalia-themed ghostty. Binds: "
        + lib.concatStringsSep " | " clipseBinds;
    }
    # Post-condition over the *rewritten* list, because the pre-condition above
    # is vacuously true when the selector matches nothing: rename the class
    # instead of the binary and `clipseBinds` is [], `lib.all` over [] is true,
    # and the bare noctalia-themed ghostty ships silently. No base bind other
    # than clipse's names ghostty literally — the rest go through
    # $terminal/$fileManager/$menu — so any surviving literal token means a bind
    # escaped the rewrite.
    {
      assertion = !(lib.any (lib.hasInfix clipseGhosttyToken) retroOverlay.bind);
      message =
        "retroism.nix: a rewritten bind still contains the literal "
        + "'${clipseGhosttyToken}', so it escaped the retro-ghostty rewrite (most "
        + "likely hypr-base.nix renamed the 'tanjiro.clipse' class the selector "
        + "matches on) and the retro session would launch the noctalia-themed "
        + "ghostty. Offending binds: "
        + lib.concatStringsSep " | " (lib.filter (lib.hasInfix clipseGhosttyToken) retroOverlay.bind);
    }
  ];

  # Keep noctalia out of the retro session. Stamped by the lemurs scripts
  # (linux/services.nix) via `systemctl --user set-environment` and the
  # rendered config's bootstrap import.
  systemd.user.services.noctalia.Unit.ConditionEnvironment = "RICE=noctalia";

  # The wallpaper, as a unit systemd orders rather than an exec-once that races.
  # The `systemd --user` manager outlives logins, so at retro login the swww
  # daemon is typically already running from the previous session — and the
  # bootstrap exec-once (`systemctl --user stop hyprland-session.target &&
  # ... start`) tears down graphical-session.target and everything PartOf it,
  # awww.service included, then brings it back. As an exec-once fired
  # concurrently with that bootstrap, the wallpaper line would reach the
  # *outgoing* daemon, set the image on a process about to die, and the restarted
  # daemon would come up blank. Expressing it as a unit puts it in the same start
  # transaction as the restarted daemon, After= it, so there is nothing left to
  # race.
  systemd.user.services.retroism-wallpaper = {
    Unit = {
      Description = "Set the Retroism session wallpaper";
      # Same gate as noctalia.service above, and for the same reason: unit files
      # are user-global, so it is the condition — not the unit's absence — that
      # keeps this inert in the noctalia session. It evaluates correctly because
      # the bootstrap's `dbus-update-activation-environment --systemd RICE ...`
      # lands RICE in the systemd user environment *before* it restarts the
      # target that pulls this unit in.
      ConditionEnvironment = "RICE=retroism";
      # Requires, not Wants: with nothing to talk to there is no point burning
      # the 10s retry, and a cancelled job is a clearer journal entry than a
      # timed-out one.
      Requires = [ swwwUnit ];
      After = [ swwwUnit ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      # Keeps the result inspectable (`systemctl --user status
      # retroism-wallpaper` after login) instead of collapsing to inactive the
      # moment it succeeds; PartOf above still clears it when the session ends.
      RemainAfterExit = true;
      ExecStart = setWallpaperCommand;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
