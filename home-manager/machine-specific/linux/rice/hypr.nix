{ pkgs, ... }:
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
      # "$run" = "tofi-run --prompt-text 'Run: ' | xargs -I {} hyprctl dispatch exec 'ghostty -e {}; sleep infinity'";
      # screenshot: grab region/window/screen -> annotate in satty -> copy to clipboard
      "$screenshotRegion" = "hyprshot -m region --raw | satty --filename - --copy-command wl-copy --early-exit";
      "$screenshotWindow" = "hyprshot -m window --raw | satty --filename - --copy-command wl-copy --early-exit";
      "$screenshotScreen" = "hyprshot -m output --raw | satty --filename - --copy-command wl-copy --early-exit";
      # clipse listener now runs as a systemd user service (see services.* below), not here.
      exec-once = [ ];
      bind = [
        "$mainMod, return, exec, $terminal"
        "$mainMod, Q, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, R, exec, $menu"
        "$mainMod, D, exec, $run"
        "$mainMod, J, hy3:makegroup, opposite, toggle"
        "$mainMod, V, exec, ghostty --class=\"tanjiro.clipse\" -e 'clipse'"

        "$mainMod, h, hy3:movefocus, l"
        "$mainMod, l, hy3:movefocus, r"
        "$mainMod, k, hy3:movefocus, u"
        "$mainMod, j, hy3:movefocus, d"
        # Workspaces switching
        "$mainMod, 1, workspace, 1 "
        "$mainMod, 2, workspace, 2 "
        "$mainMod, 3, workspace, 3 "
        "$mainMod, 4, workspace, 4 "
        "$mainMod, 5, workspace, 5 "
        "$mainMod, 6, workspace, 6 "
        "$mainMod, 7, workspace, 7 "
        "$mainMod, 8, workspace, 8 "
        "$mainMod, 9, workspace, 9 "
        "$mainMod, 0, workspace, 10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT, 1, hy3:movetoworkspace, 1 "
        "$mainMod SHIFT, 2, hy3:movetoworkspace, 2 "
        "$mainMod SHIFT, 3, hy3:movetoworkspace, 3 "
        "$mainMod SHIFT, 4, hy3:movetoworkspace, 4 "
        "$mainMod SHIFT, 5, hy3:movetoworkspace, 5 "
        "$mainMod SHIFT, 6, hy3:movetoworkspace, 6 "
        "$mainMod SHIFT, 7, hy3:movetoworkspace, 7 "
        "$mainMod SHIFT, 8, hy3:movetoworkspace, 8 "
        "$mainMod SHIFT, 9, hy3:movetoworkspace, 9 "
        "$mainMod SHIFT, 0, hy3:movetoworkspace, 10"

        "$mainMod SHIFT, h, hy3:movewindow, left"
        "$mainMod SHIFT, j, hy3:movewindow, down"
        "$mainMod SHIFT, k, hy3:movewindow, up"
        "$mainMod SHIFT, l, hy3:movewindow, right"

        # Tab Group
        "$mainMod, T, hy3:changegroup, toggletab"
        # Example special workspace (scratchpad)
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic "

        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1  "

        # Window state
        "$mainMod, F, fullscreen, 0"
        "$mainMod, SPACE, togglefloating,"
        "$mainMod, P, pin,"

        # Screenshots (annotate in satty, lands on clipboard)
        ", Print, exec, $screenshotRegion"
        "SHIFT, Print, exec, $screenshotWindow"
        "CTRL, Print, exec, $screenshotScreen"

        # Color picker -> hex on clipboard
        "$mainMod, C, exec, hyprpicker -a"

        # Enter resize submap (SUPER+ALT+R; SUPER+R is the app menu)
        "$mainMod ALT, R, submap, resize"
      ];
      bindm = [
        # Move/resize windows with mainMod + LMB/RMB and dragging
        "$mainMod, mouse:272, hy3:resizewindow"
        "$mainMod, mouse:273, hy3:movewindow"
      ];
      cursor = {
        no_hardware_cursors = 2;
        use_cpu_buffer = 2;
      };

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        resize_on_border = true;
        # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = true;
        layout = "hy3";
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
      windowrule = [
        "float true,match:class tanjiro.clipse"
        "size 622 652,match:class tanjiro.clipse"

        # Float + center common dialogs/pickers
        "float true,match:title ^(Open File|Save File|Save As|Choose Files)(.*)$"
        "center true,match:title ^(Open File|Save File|Save As|Choose Files)(.*)$"

        # Picture-in-Picture: float, pin, keep on top
        "float true,match:title ^(Picture-in-Picture)$"
        "pin true,match:title ^(Picture-in-Picture)$"
        "keep_aspect_ratio true,match:title ^(Picture-in-Picture)$"

        # Don't let the screen lock/idle while a fullscreen window is up (video, games)
        "idle_inhibit fullscreen,match:class .*"

        # Moonlight — verify class name with `hyprctl clients` while it's running
        "immediate true,match:class ^(com\\.moonlight_stream\\.Moonlight)$"
        "opaque true,match:class ^(com\\.moonlight_stream\\.Moonlight)$"
        "fullscreen true,match:class ^(com\\.moonlight_stream\\.Moonlight)$"
      ];
    };

    # Submaps can't be expressed in the settings attrset (stateful blocks), so use raw
    # config. Enter with SUPER+ALT+R, resize with hjkl, leave with ESC or return.
    extraConfig = ''
      submap = resize
      binde = , h, resizeactive, -40 0
      binde = , l, resizeactive, 40 0
      binde = , k, resizeactive, 0 -40
      binde = , j, resizeactive, 0 40
      bind = , escape, submap, reset
      bind = , return, submap, reset
      submap = reset
    '';
  };
}
