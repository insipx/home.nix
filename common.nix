{
  pkgs,
  lib,
  config,
  ...
}:
{
  nix.settings.netrc-file = config.sops.secrets.nixGithubNetrc.path;
  nix.extraOptions = ''
    !include /run/secrets/nixAccessTokens
  '';
  environment = {
    systemPackages =
      with pkgs;
      [
        opensc
        lspmux
        zellij
        nix-output-monitor
        languagetool
        mermaid-cli
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        ollama
      ];

    etc."volos.crt" = {
      source = ./volos.cert;
    };
    variables = {
      NODE_EXTRA_CA_CERTS = "/etc/volos.crt";
      CLAUDE_CODE_MAX_SUBAGENTS_PER_SESSION = "1000";
    };
  };

  security.pki.certificates = [
    ''
      -----BEGIN CERTIFICATE-----
      MIIBlDCCATmgAwIBAgIQZan2L1JiYhHTp/yUgVuAozAKBggqhkjOPQQDAjAoMQ4w
      DAYDVQQKEwVWb2xvczEWMBQGA1UEAxMNVm9sb3MgUm9vdCBDQTAeFw0yNDEyMTky
      MTMyMDFaFw0zNDEyMTcyMTMyMDFaMCgxDjAMBgNVBAoTBVZvbG9zMRYwFAYDVQQD
      Ew1Wb2xvcyBSb290IENBMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEjPZBK319
      OFl56WZG+fuEXNAW6ECAz/UfXnViAnkfiNag/N72+lGqc0UMj5TFZj4TCzONE6lQ
      mRxekwfq2OYVkqNFMEMwDgYDVR0PAQH/BAQDAgEGMBIGA1UdEwEB/wQIMAYBAf8C
      AQEwHQYDVR0OBBYEFJfVFrIznQi3WORnHTxEk1TC3EdMMAoGCCqGSM49BAMCA0kA
      MEYCIQC362kqw/6FuZHy3ImWOtSkL+adh8/lRKMtyV8+MhSi4AIhAOiYIjTt5ulw
      /7gVZPmEpIFGOubQgDOA67M7E84sk844
      -----END CERTIFICATE-----
    ''
  ];
  programs.ssh = {
    knownHosts = {
      nixbuild = {
        hostNames = [ "eu.nixbuild.net" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
      };
      arm64-builder = {
        hostNames = [ "arm64-builder.insipx.xyz" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC3yqH3hvKqDTNkX4jnrw+OZHjYwAEkbMc/6YKumR8Sn";
      };
    };
    extraConfig = ''
      Host eu.nixbuild.net
        PubkeyAcceptedKeyTypes ssh-ed25519
        ServerAliveInterval 60
        IPQoS throughput
        IdentityFile /etc/ssh/ssh_host_ed25519_key

      # Darwin remote builders: GB-scale ssh-ng transfers have wedged
      # silently mid-copy (frozen socket, no FIN). Keepalives detect the
      # dead peer instead of hanging the nix daemon indefinitely.
      Host kusanagi cyllene
        ServerAliveInterval 30
        ServerAliveCountMax 6
        TCPKeepAlive yes
        IPQoS throughput
    '';
  };

  nix = {
    buildMachines = [
      {
        hostName = "arm64-builder.insipx.xyz";
        system = "aarch64-linux";
        maxJobs = 300;
        speedFactor = 100;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
        sshUser = "nixremote";
        sshKey = if pkgs.stdenv.hostPlatform.isDarwin then "/etc/ssh/ssh_host_ed25519_key" else null;
        protocol = "ssh-ng";
      }
      # {
      #   hostName = "eu.nixbuild.net";
      #   system = "i686-linux";
      #   maxJobs = 100;
      #   speedFactor = 50;
      #   supportedFeatures = [
      #     "benchmark"
      #     "big-parallel"
      #   ];
      # }
      # {
      #   hostName = "eu.nixbuild.net";
      #   system = "armv7-linux";
      #   maxJobs = 100;
      #   speedFactor = 50;
      #   supportedFeatures = [
      #     "benchmark"
      #     "big-parallel"
      #   ];
      # }
      # {
      #   hostName = "eu.nixbuild.net";
      #   system = "aarch64-linux";
      #   maxJobs = 100;
      #   speedFactor = 50;
      #   supportedFeatures = [
      #     "benchmark"
      #     "big-parallel"
      #   ];
      # }
      # {
      #   # only enable x86_64 if we're not already on x86_64
      #   hostName = "eu.nixbuild.net";
      #   system = "x86_64-linux";
      #   maxJobs = 100;
      #   supportedFeatures = [
      #     "benchmark"
      #     "big-parallel"
      #     "kvm"
      #   ];
      # }
      #{
      #  hostName = "kusanagi";
      #  sshUser = "nixbuilder";
      #  sshKey = "/root/.ssh/nixremote";
      #  systems = [
      #    "x86_64-darwin"
      #    "aarch64-darwin"
      #  ];
      #  maxJobs = 8;
      #  speedFactor = 2;
      #  supportedFeatures = [
      #    "nixos-test"
      #    "benchmark"
      #    "big-parallel"
      #  ];
      #  protocol = "ssh-ng";
      #}
      #{
      #  hostName = "cyllene";
      #  sshUser = "nixbuilder";
      #  sshKey = "/root/.ssh/nixremote";
      #  systems = [
      #    "x86_64-darwin"
      #    "aarch64-darwin"
      #  ];
      #  maxJobs = 8;
      #  speedFactor = 2;
      #  supportedFeatures = [
      #    "nixos-test"
      #    "benchmark"
      #    "big-parallel"
      #  ];
      #  protocol = "ssh-ng";
      #}
    ];
    settings = {
      extra-experimental-features = [
        "nix-command"
        "flakes"
        # iOS SDK derivations opt into content-addressing (stable store
        # paths across Xcode bundle hash drift)
        "ca-derivations"
      ];
      system-features = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      builders-use-substitutes = true;
      # extra-platforms = [ ]; # Don't try to build aarch64 locally
    };
    distributedBuilds = true;
  };
}
