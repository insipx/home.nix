{ pkgs, config, ... }:
let 

in {
    imports = [ ./common.nix ];

    services.gpg-agent = {
        enable = pkgs.hostPlatform.isLinux;
        enableScDaemon = true;
        defaultCacheTtl = 1800;
        enableSshSupport = true;
        pinentryFlavor = "gnome3";
        enableFishIntegration = true;
        extraConfig = ''
            allow-emacs-pinentry
        '';
    };
    
    services.lorri = { 
        # On Mac, Lorri must be setup according to [other](https://github.com/nix-community/lorri#setup-on-other-platforms) instructions
        enable = pkgs.hostPlatform.isLinux;
        enableNotifications = true;
    };
}
