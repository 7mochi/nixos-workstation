{ config, ... }:

{
  flake.nixosConfigurations."workstation" = config.flake.lib.mkNixos {
    name = "workstation";
  };
}
