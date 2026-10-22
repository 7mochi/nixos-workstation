{ config, ... }:

{
  perSystem =
    _:
    let
      hosts = config.flake.nixosConfigurations;
      hostName = builtins.head (builtins.attrNames hosts);
      host = hosts.${hostName};
    in
    {
      apps.vm = {
        type = "app";
        program = "${host.config.system.build.vm}/bin/run-${hostName}-vm";
      };
    };
}
