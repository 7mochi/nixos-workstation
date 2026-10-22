{ inputs, ... }:

{
  flake.modules.nixos.deadband = {
    imports = [ inputs.deadband.nixosModules.default ];
  };
}
