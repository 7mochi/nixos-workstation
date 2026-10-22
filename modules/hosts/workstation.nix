{ config, inputs, ... }:

let
  nixSettings = import ../../lib/nix-settings.nix;
  identity = import ../../lib/identity.nix;
in
{
  flake.nixosConfigurations."workstation" = inputs.nixpkgs.lib.nixosSystem {
    inherit (nixSettings) system;

    specialArgs = { inherit identity inputs; };

    modules = [
      config.flake.modules.nixos.workstation
      config.flake.modules.nixos.shared

      {
        networking.hostName = "workstation";
        system.stateVersion = "26.05";
      }
    ];
  };
}
