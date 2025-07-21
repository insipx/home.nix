{ pkgs, ... }: {

  services = {
    # displayManager.lemurs = {
    #   enable = true;
    #   settings.environment_switcher.include_tty_shell = true;
    # };
    seatd.enable = true;
    printing.enable = true;
    udev = {
      extraRules = ''
        ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
        ACTION=="add", SUBSYSTEM=="usb", TEST=="power/autosuspend" ATTR{power/autosuspend}="0"
        ACTION=="add", SUBSYSTEM=="usb", TEST=="power/autosuspend_delay_ms" ATTR{power/autosuspend_delay_ms}="0"
      '';
      packages = [ pkgs.yubikey-personalization pkgs.libfido2 ];
    };
    pcscd.enable = true;
    # sound
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    # Maybe want to enable in the future
    # Enable the OpenSSH daemon.
    openssh.enable = true;
    # Execute shebangs like on normal linux (i.e #!/bin/bash)
    envfs.enable = true;
  };
  # services custom config
  environment = {
    # etc."lemurs/wayland/hyprland" = {
    #   mode = "0755";
    #   enable = true;
    #   text = ''
    #     #! /bin/sh
    #     exec ${lib.getExe pkgs.hyprland}
    #   '';
    # };
  };
}
