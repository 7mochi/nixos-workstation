{ inputs, ... }:

let
  nixSettings = import ../../lib/nix-settings.nix;
in
{
  imports = [
    inputs.flake-parts.flakeModules.modules
  ];

  systems = [ nixSettings.system ];
}
