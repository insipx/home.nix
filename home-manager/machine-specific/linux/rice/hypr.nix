{
  lib,
  pkgs,
  ...
}:
let
  base = import ./hypr-base.nix;
  # The noctalia rice's visual layer — exactly the keys removed from base.
  noctaliaVisuals = {
    general = {
      gaps_in = 5;
      gaps_out = 20;
      border_size = 2;
      # Catppuccin Mocha gradient border (mauve -> blue), dim surface0 when inactive.
      # Replaces the catppuccin lua theme we disabled; plaintext so it parses fine.
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

      # Change transparency of focused and unfocused windows
      active_opacity = 1.0;
      inactive_opacity = 1.0;

      shadow = {
        enabled = true;
        range = 4;
        render_power = 3;
        color = "rgba(1a1a1aee)";
      };

      # drop_shadow = true;
      # shadow_range = 4;
      # shadow_render_power = 3;
      # col.shadow = "rgba(1a1a1aee)";

      # https://wiki.hyprland.org/Configuring/Variables/#blur
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
  # clipse clipboard listener as a proper user service instead of Hyprland exec-once
  # (exec-once died and never recovered, so V opened the picker but the daemon wasn't
  # capturing/serving). Restart=always keeps it alive across compositor restarts.
  systemd.user.services.clipse = {
    Unit = {
      Description = "clipse clipboard manager listener";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      # -listen self-daemonizes (parent exits immediately), which made systemd think
      # the service died and respawn it forever, each fork killing the previous and
      # racing any open TUI. -listen-shell runs the monitor in the foreground so
      # systemd can supervise it as one stable process.
      ExecStartPre = "-${pkgs.clipse}/bin/clipse -kill";
      ExecStart = "${pkgs.clipse}/bin/clipse -listen-shell";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    # Stay on plaintext hyprlang config. HM's default flips to "lua" at stateVersion
    # 26.05; we pin it explicitly so the migration stays opt-in (lua would require
    # rewriting every bind/rule into _args/hl.dsp form for no gain without scripting).
    configType = "hyprlang";
    # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
    plugins = [ pkgs.hy3 ];
    settings = lib.recursiveUpdate base.settings noctaliaVisuals;
    extraConfig = base.resizeSubmap;
  };
}
