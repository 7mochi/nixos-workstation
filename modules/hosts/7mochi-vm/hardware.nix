{ lib, ... }:

{
  flake.modules.nixos.virtualMachine =
    { modulesPath, ... }:

    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot = {
        initrd = {
          availableKernelModules = lib.mkDefault [
            "ata_piix"
            "ohci_pci"
            "ehci_pci"
            "ahci"
            "sd_mod"
            "sr_mod"
          ];
          kernelModules = [ ];
        };

        kernelModules = [ ];
        extraModulePackages = [ ];
      };

      boot.loader.grub = {
        enable = true;
        device = "/dev/sda";
        # Use provided UUIDs instead of blkid probing (required for btrfs subvolumes)
        fsIdentifier = "provided";
      };

      boot.kernelParams = [ "amd_pstate=active" ];

      fileSystems = {
        "/" = {
          device = "/dev/disk/by-uuid/fb1eaf94-0cb4-4497-8a4a-969dd0867ee8";
          fsType = "btrfs";
        };

        "/home" = {
          device = "/dev/disk/by-uuid/fb1eaf94-0cb4-4497-8a4a-969dd0867ee8";
          fsType = "btrfs";
          options = [ "subvol=home" ];
        };

        "/nix" = {
          device = "/dev/disk/by-uuid/fb1eaf94-0cb4-4497-8a4a-969dd0867ee8";
          fsType = "btrfs";
          options = [ "subvol=nix" ];
        };
      };

      swapDevices = [ ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.enableRedistributableFirmware = lib.mkDefault true;
      virtualisation.virtualbox.guest.enable = true;
    };
}
