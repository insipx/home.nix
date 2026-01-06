_:
{
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

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise = {
      automatic = true;
      dates = "9:00";
    };
    buildMachines = [{
      hostName = "arm64-builder.insipx.xyz";
      system = "aarch64-linux";
      maxJobs = 8;
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
      sshUser = "nixremote";
      protocol = "ssh-ng";
    }];
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      system-features = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      builders-use-substitutes = true;
      extra-platforms = [ ]; # Don't try to build aarch64 locally
    };
    distributedBuilds = true;
  };
}
