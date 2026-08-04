_:

{
  flake.modules.nixos.shared = {
    fileSystems = {
      "/" = {
        options = [
          "compress=zstd"
          "noatime"
        ];
      };

      "/home" = {
        options = [
          "compress=zstd"
          "noatime"
        ];
      };

      "/nix" = {
        options = [
          "compress=zstd"
          "noatime"
        ];
      };
    };

    services = {
      btrfs.autoScrub = {
        enable = true;
        fileSystems = [ "/" ];
        interval = "weekly";
      };

      fstrim.enable = true;
    };
  };
}
