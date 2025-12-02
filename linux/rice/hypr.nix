{ pkgs, ... }: {
  wayland.windowManager.hyprland = {
    enable = true;
    # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
    plugins = [ pkgs.hyprlandPlugins.hy3 ];
    settings = {
      monitor = "DP-1,highrr,0x0,1";
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "GBM_BACKEND,nvidia-drm"
        "XDG_SESSION_TYPE,wayland"
      ];
      "$mainMod" = "SUPER";
      "$terminal" = "ghostty";
      "$menu" = "tofi-drun --drun-launch=true";
      "$run" = "tofi-run | xargs hyprctl dispatch exec";
      # "$run" = "tofi-run --prompt-text 'Run: ' | xargs -I {} hyprctl dispatch exec 'ghostty -e {}; sleep infinity'";
      exec-once = [
        "clipse -listen"
      ];
      bind = [
        "$mainMod, return, exec, $terminal"
        "$mainMod, Q, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, R, exec, $menu"
        "$mainMod, D, exec, $run"
        "$mainMod, J, togglesplit, # dwindle"
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
        allow_tearing = false;
        layout = "hy3";
      };

      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      decoration = {
        rounding = 20;

        # Change transparency of focused and unfocused windows
        active_opacity = 1.0;
        inactive_opacity = 1.0;

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
        "blur, launcher"
        "ignorealpha 0.1, launcher"
        "dimaround, launcher"
      ];
      windowrule = [
        "float,class:(tanjiro.clipse)"
        "size 622 652,class:(tanjiro.clipse)"
      ];
    };
  };
}
