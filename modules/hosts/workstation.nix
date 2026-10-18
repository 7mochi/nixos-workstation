{ config, inputs, ... }:

let
  nixSettings = import ../../lib/nix-settings.nix;
  identity = import ../../lib/identity.nix;
in
{
  flake.nixosConfigurations."workstation" = inputs.nixpkgs.lib.nixosSystem {
    inherit (nixSettings) system;

    modules = [
      inputs.niri.nixosModules.niri
      inputs.sops-nix.nixosModules.sops
      inputs.home-manager.nixosModules.home-manager
      inputs.nix-flatpak.nixosModules.nix-flatpak
      config.flake.modules.nixos.workstation
      config.flake.modules.nixos.shared

      {
        networking.hostName = "workstation";
        system.stateVersion = "26.05";

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
          sharedModules = [
            inputs.noctalia.homeModules.default
            inputs.agent-skills.homeManagerModules.default
            inputs.zen-browser.homeModules.default
          ];
          extraSpecialArgs = {
            inherit inputs;
          };
          users.${identity.username} = config.flake.modules.homeManager.nanamochi;
        };
      }
    ];
  };
}
