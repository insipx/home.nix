{
  pkgs,
  config,
  lib,
  ...
}:
{
  sops = {
    defaultSopsFile = ./secrets/env.yaml;
    secrets.nixAccessTokens = lib.mkMerge [
      {
        mode = "0440";
      }
      (lib.mkIf (config.users.groups ? keys) {
        group = config.users.groups.keys.name;
      })
    ];
  };

  nix.extraOptions = ''
    !include ${config.sops.secrets.nixAccessTokens.path}
  '';
  environment = {
    systemPackages = with pkgs; [
      opensc
      sccache_wrapper
      lspmux
    ];

    etc."volos.crt" = {
      source = ./volos.cert;
    };
    variables = {
      NODE_EXTRA_CA_CERTS = "/etc/volos.crt";
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
    };
    extraConfig = ''
      Host eu.nixbuild.net
        PubkeyAcceptedKeyTypes ssh-ed25519
        ServerAliveInterval 60
        IPQoS throughput
        IdentityFile /etc/ssh/ssh_host_ed25519_key
    '';
  };

  nix = {
    buildMachines = [
      {
        hostName = "arm64-builder.insipx.xyz";
        system = "aarch64-linux";
        maxJobs = 300;
        speedFactor = 2;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
        mandatoryFeatures = [ ];
        sshUser = "nixremote";
        protocol = "ssh-ng";
      }
      {
        hostName = "eu.nixbuild.net";
        system = "i686-linux";
        maxJobs = 100;
        supportedFeatures = [
          "benchmark"
          "big-parallel"
        ];
      }
      {
        hostName = "eu.nixbuild.net";
        system = "armv7-linux";
        maxJobs = 100;
        supportedFeatures = [
          "benchmark"
          "big-parallel"
        ];
      }
      {
        hostName = "eu.nixbuild.net";
        system = "aarch64-linux";
        maxJobs = 100;
        supportedFeatures = [
          "benchmark"
          "big-parallel"
        ];
      }
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
    ];
    settings = {
      extra-experimental-features = [
        "nix-command"
        "flakes"
      ];
      system-features = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      builders-use-substitutes = true;
      extra-platforms = [ ]; # Don't try to build aarch64 locally
    };
    distributedBuilds = true;
  };
}
