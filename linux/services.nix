{
  lib,
  pkgs,
  ...
}:
{

  services = {
    flatpak.enable = true;
    avahi.enable = true;
    chrony = {
      enable = true;
      enableNTS = true;
      servers = [
        "time.cloudflare.com"
        "ohio.time.system76.com"
      ];
    };
    resolved = {
      enable = true;
      settings.Resolve.DNSOverTLS = "opportunistic";
    };

    displayManager.lemurs = {
      enable = true;
      settings.environment_switcher.include_tty_shell = true;
    };
    seatd.enable = true;
    printing.enable = true;
    udev = {
      extraRules = ''
        ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
        ACTION=="add", SUBSYSTEM=="usb", TEST=="power/autosuspend" ATTR{power/autosuspend}="0"
        ACTION=="add", SUBSYSTEM=="usb", TEST=="power/autosuspend_delay_ms" ATTR{power/autosuspend_delay_ms}="0"
      '';
      packages = [
        pkgs.yubikey-personalization
        pkgs.libfido2
      ];
    };
    pcscd.enable = true;
    # sound
    pipewire = {
      enable = true;
      pulse.enable = true;
      audio.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      wireplumber.enable = true;
    };
    # Maybe want to enable in the future
    # Enable the OpenSSH daemon.
    openssh.enable = true;
    # Execute shebangs like on normal linux (i.e #!/bin/bash)
    envfs.enable = true;
  };

  # A recent nixpkgs bump broke the s6-notify bridge in the stock seatd unit: seatd
  # 0.9.3 starts fine ("seatd started") but its Type=notify readiness never reaches
  # systemd, so systemd kills it on a 90s start-timeout loop. libseat then can't reach
  # a seat (the lemurs wayland session is registered seatless in logind), aquamarine
  # spins "Couldn't dispatch libseat events" forever, Hyprland melts and xdph crashes
  # in teardown. Run seatd directly with Type=exec so systemd treats exec as ready.
  systemd.services.seatd.serviceConfig = {
    Type = lib.mkForce "exec";
    ExecStart = lib.mkForce "${pkgs.seatd}/bin/seatd -u root -g seat -l info";
  };

  # services custom config
  environment = {
    etc."lemurs/wayland/Hypr" = {
      mode = "0755";
      enable = true;
      text = ''
        #! /bin/sh
        exec ${lib.getExe pkgs.hyprland}
      '';
    };
    etc."lemurs/wayland/Gamez" = {
      mode = "0755";
      enable = true;
      text = ''
        #!/usr/bin/env bash
        set -xeuo pipefail

        gamescopeArgs=(
            --adaptive-sync # VRR support
            --hdr-enabled
            --mangoapp # performance overlay
            --fullscreen
            --nested-refresh 240
            --expose-wayland
            --force-grab-cursor
            --rt
            --steam
        )
        steamArgs=(
            -pipewire-dmabuf
            -tenfoot
        )
        mangoConfig=(
            cpu_temp
            gpu_temp
            ram
            vram
        )
        mangoVars=(
            MANGOHUD=1
            MANGOHUD_CONFIG="$(IFS=,; echo "''${mangoConfig[*]}")"
        )

        export "''${mangoVars[@]}"
        exec gamescope "''${gamescopeArgs[@]}" -- steam "''${steamArgs[@]}"
      '';
    };
  };
}
