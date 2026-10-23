{
  config,
  inputs,
  lib,
  ...
}:

let
  nixSettings = import ../../lib/nix-settings.nix;
  identity = import ../../lib/identity.nix;
in
{
  imports = [
    inputs.flake-parts.flakeModules.modules
  ];

  systems = [ nixSettings.system ];

  flake.lib.mkNixos =
    {
      name,
      system ? nixSettings.system,
      modules ? [ ],
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = { inherit identity inputs; };

      modules = [
        config.flake.modules.nixos.shared
        config.flake.modules.nixos.${name}
      ]
      ++ modules;
    };
}
