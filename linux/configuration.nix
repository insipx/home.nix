# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, ... }:
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./disk-config.nix
      ./services.nix
      ./cachix.nix
    ];

  time.timeZone = "America/New_York";
  # yubikey needs polkit rules
  security = {
    rtkit.enable = true;
    polkit.enable = true;
    polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.debian.pcsc-lite.access_card") {
          return polkit.Result.YES;
        }
      });

      polkit.addRule(function(action, subject) {
        if (action.id == "org.debian.pcsc-lite.access_pcsc") {
          return polkit.Result.YES;
        }
      });
    '';
  };
  boot = {
    # binfmt.emulatedSystems = [ "aarch64-linux" ];
    # Use latest xanmod kernel.
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    loader = {
      efi.canTouchEfiVariables = true;
      limine = {
        enable = true;
        efiSupport = true;
        style = {
          interface.branding = "tanjiro";
          wallpapers = [ "/extra/boot-wallpapers/lain.jpg" ];
          wallpaperStyle = "centered";
        };
        enrollConfig = true;
        maxGenerations = 15;
        extraConfig = ''
          default_entry: 1>1
        '';
      };
    };
    plymouth = {
      enable = true;
      theme = "cross_hud";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "cross_hud" ];
        })
      ];
    };
    kernelModules = [ "kvm-amd" ];
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
    extraModulePackages = [ ];
    consoleLogLevel = 3;
    initrd = {
      systemd.enable = true;
      verbose = false;
      kernelModules = [ ];
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    };
  };

  services.chrony = {
    enable = true;
    enableNTS = true;
    servers = [
      "time.cloudflare.com"
      "ohio.time.system76.com"
    ];
  };
  networking.hostName = "tanjiro"; # Define your hostname.
  # Pick only one of the below networking options.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  programs = {
    hyprland.enable = true;
    gamescope = {
      enable = true;
      capSysNice = true;
    };
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
    firefox = {
      enable = true;
      package = pkgs.firefox-devedition;
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    direnv = {
      enable = true;
      enableFishIntegration = true;
    };
  };
  sops = {
    age = {
      generateKey = true;
      keyFile = "./../keys/age-yubikey-identity-e5e2e0d8.txt";
    };
    #    secrets.anthropic_key = {
    #      group = "staff";
    #      owner = "insipx";
    #      mode = "0400"; # Read-only by owner
    #    };
    #    secrets.cachix_auth_token = {
    #      group = "staff";
    #      owner = "insipx";
    #      mode = "0400"; # Read-only by owner
    #    };
    defaultSopsFile = ./../secrets/env.yaml;
  };
  programs = {
    fish = {
      enable = true;
      #      # Set your time zone.
      #      interactiveShellInit = ''
      #        time.timeZone = "America/New_York"
      #                 set -x ANTHROPIC_API_KEY (cat ${config.sops.secrets.anthropic_key.path})
      #                 set -x CACHIX_AUTH_TOKEN (cat ${config.sops.secrets.cachix_auth_token.path})
      #      '';
      #    };
    };
  }; # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.insipx = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "fuse" "video" "audio" "input" "seat" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };
  users.defaultUserShell = pkgs.fish;

  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };
  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim
    iotop
    wget
    kitty
    age-plugin-yubikey
    yofi
    yubioath-flutter
    unzip
    pinentry-curses
    cachix
    wl-clipboard
    clipse
    solaar
    efibootmgr
    killall
    mangohud
    libusb1
    pwvucontrol
    pavucontrol
    alsa-utils
    google-chrome
    claude-code
    vlc
    discord

    alsa-ucm-conf # includes options for Motu M2
    lnav
    spotify
    k3s

    # Hyprland
    hyprshot
    hypridle
    catppuccin-cursors.mochaDark
    rpi-imager
  ];
  catppuccin = {
    flavor = "mocha";
    cursors.enable = true;
    tty.enable = true;
    cache.enable = true;
  };
  nix.settings.trusted-users = [ "root" "insipx" ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}


