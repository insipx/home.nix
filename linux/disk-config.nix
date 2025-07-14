{
  disko.devices = {
    disk = {
      bootdisk = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "10G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            plainSwap = {
              size = "256G";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true; # resume from hiberation from this device
              };
            };
            extra = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                mountpoint = "/extra";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
            };
          };
        };
      };
      # Devices will be mounted and formatted in alphabetical order, and btrfs can only mount raids
      # when all devices are present. So we define an "empty" luks device on the first disk,
      # and the actual btrfs raid on the second disk, and the name of these entries matters!
      disk1 = {
        type = "disk";
        device = "/dev/nvme2n1";
        content = {
          type = "gpt";
          partitions = {
            crypt_p1 = {
              size = "100%";
              content = {
                type = "luks";
                name = "p1"; # device-mapper name when decrypted
                settings = {
                  allowDiscards = true;
                };
              };
            };
          };
        };
      };
      disk2 = {
        type = "disk";
        device = "/dev/nvme3n1";
        content = {
          type = "gpt";
          partitions = {
            crypt_p2 = {
              size = "100%";
              content = {
                type = "luks";
                name = "p2"; # device-mapper name when decrypted
                settings = {
                  allowDiscards = true;
                };
              };
            };
          };
        };
      };
      disk3 = {
        type = "disk";
        device = "/dev/nvme4n1";
        content = {
          type = "gpt";
          partitions = {
            crypt_p3 = {
              size = "100%";
              content = {
                type = "luks";
                name = "p3"; # device-mapper name when decrypted
                settings = {
                  allowDiscards = true;
                };
              };
            };
          };
        };
      };
      disk4 = {
        type = "disk";
        device = "/dev/nvme5n1";
        content = {
          type = "gpt";
          partitions = {
            crypt_p4 = {
              size = "100%";
              content = {
                type = "luks";
                name = "p4";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-d raid0"
                    "/dev/mapper/p1" # Use decrypted mapped device, same name as defined in disk1
		    "/dev/mapper/p2"
                    "/dev/mapper/p3"
                  ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "rw"
                        "relatime"
                        "ssd"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}

