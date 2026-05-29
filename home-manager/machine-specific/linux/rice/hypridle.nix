_: {
  services = {
    hypridle = {
      enable = true;
      settings = {
        general = {
          ignore_dbus_inhibit = false;
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };
        # OLED protection ladder for the QD-OLED PG32UCDM. dpms off fully powers the
        # panel down while idle (zero burn-in), which matters far more than dimming —
        # and this is an external DP display, so there's no backlight to dim anyway.
        #
        # The dpms-off listener was previously removed on the theory it triggered an
        # xdph CCWlOutput segfault; the real cause was the seatd sd-notify regression
        # (see memory: seatd-notify-override), so dpms off is safe to run again.
        listener = [
          {
            # Lock after 8 min idle.
            timeout = 480;
            on-timeout = "loginctl lock-session";
          }
          {
            # Power the panel off after 10 min; restore on activity.
            timeout = 600;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            # Suspend after 30 min.
            timeout = 1800;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
  programs.hyprlock = {
    enable = true;
    settings.animations = {
      enable = true;
    };
  };
}
