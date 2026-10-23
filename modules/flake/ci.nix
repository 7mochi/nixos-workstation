{ config, ... }:

let
  nixSettings = import ../../lib/nix-settings.nix;
  inherit (nixSettings) system;
  hosts = config.flake.nixosConfigurations;
  hostName = builtins.head (builtins.attrNames hosts);
  checks = removeAttrs (config.flake.checks.${system} or { }) [ "nixos-${hostName}" ];
in
{
  flake.ci.matrix = [
    {
      name = "nixos-${hostName}";
      attr = "nixosConfigurations.${hostName}.config.system.build.toplevel";
      inherit system;
    }
  ]
  ++ map (name: {
    inherit name system;
    attr = "checks.${system}.${name}";
  }) (builtins.attrNames checks);
}
