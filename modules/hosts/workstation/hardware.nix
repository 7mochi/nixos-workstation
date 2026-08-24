{ lib, ... }:

{
  flake.modules.nixos.workstation =
    { modulesPath, config, ... }:

    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot = {
        initrd = {
          availableKernelModules = [
            "xhci_pci"
            "ahci"
            "nvme"
            "usb_storage"
            "usbhid"
            "sd_mod"
          ];
          kernelModules = [ ];
        };

        kernelModules = [ "kvm-intel" ];
        extraModulePackages = [ ];

        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
      };

      fileSystems = {
        "/" = {
          device = "/dev/disk/by-uuid/53308f0b-416b-432e-a8cc-d41dfe26fdae";
          fsType = "btrfs";
        };

        "/home" = {
          device = "/dev/disk/by-uuid/53308f0b-416b-432e-a8cc-d41dfe26fdae";
          fsType = "btrfs";
          options = [ "subvol=home" ];
        };

        "/nix" = {
          device = "/dev/disk/by-uuid/53308f0b-416b-432e-a8cc-d41dfe26fdae";
          fsType = "btrfs";
          options = [ "subvol=nix" ];
        };

        "/boot" = {
          device = "/dev/disk/by-uuid/6861-C6F0";
          fsType = "vfat";
          options = [
            "fmask=0077"
            "dmask=0077"
          ];
        };

        "/media/ssd" = {
          device = "/dev/disk/by-uuid/e85bdfb5-4835-4a02-a2e6-cc58b2b123e8";
          fsType = "btrfs";
          options = [
            "compress=zstd"
            "noatime"
          ];
        };

        "/media/hdd" = {
          device = "/dev/disk/by-uuid/7ca58179-89f1-4d63-977d-cd5c2e8a9950";
          fsType = "btrfs";
          options = [
            "compress=zstd"
            "noatime"
          ];
        };
      };

      swapDevices = [
        {
          device = "/dev/disk/by-uuid/2072261e-d588-4fc6-8d89-8cf8cbfbf395";
        }
      ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      hardware = {
        enableRedistributableFirmware = lib.mkDefault true;
        cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        opentabletdriver.enable = true;
        wooting.enable = true;
      };
    };
}
