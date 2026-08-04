{ config, inputs, ... }:

{
  flake.nixosConfigurations."workstation" = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = [
      inputs.niri.nixosModules.niri
      inputs.sops-nix.nixosModules.sops
      inputs.home-manager.nixosModules.home-manager
      config.flake.modules.nixos.workstation
      config.flake.modules.nixos.shared

      {
        networking.hostName = "workstation";
        system.stateVersion = "26.05";

        nixpkgs.overlays = [
          inputs.nix-cachyos-kernel.overlays.pinned
        ];

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
          sharedModules = [
            inputs.noctalia.homeModules.default
          ];
          users.nanamochi = config.flake.modules.homeManager.nanamochi;
        };
      }
    ];
  };
}
