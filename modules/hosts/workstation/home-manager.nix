{ config, ... }:

let
  userModule = config.flake.modules.homeManager.nanamochi;
in
{
  flake.modules.nixos.workstation-home-manager =
    {
      identity,
      inputs,
      ...
    }:
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        extraSpecialArgs = {
          inherit inputs identity;
        };
        users.${identity.username} = userModule;
      };
    };
}
