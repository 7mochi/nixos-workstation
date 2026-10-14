_:

{
  flake.modules.nixos.workstation = {
    services = {
      btrfs.autoScrub = {
        enable = true;
        fileSystems = [
          "/media/ssd"
          "/media/hdd"
        ];
        interval = "weekly";
      };

      fstrim.enable = true;
    };
  };
}
