{ config, lib, ... }:

{
  perSystem =
    { pkgs, self', ... }:
    let
      hosts = config.flake.nixosConfigurations;
      hostName = builtins.head (builtins.attrNames hosts);
      host = hosts.${hostName};

      updatable = lib.filterAttrs (
        name: pkg: (pkg.passthru.updateScript or null) != null && !(lib.hasPrefix "write-" name)
      ) self'.packages;

      skipped = lib.filterAttrs (
        name: pkg: (pkg.passthru.updateScript or null) == null && !(lib.hasPrefix "write-" name)
      ) self'.packages;

      updatePkgs = pkgs.writeShellApplication {
        name = "update-pkgs";
        runtimeInputs = [
          pkgs.nix
          pkgs.nix-update
        ];
        text = ''
          if [[ ! -f flake.nix ]]; then
            echo "update-pkgs: run this from the repository root" >&2
            exit 1
          fi

          ${lib.concatMapStrings (name: ''
            echo "==> ${name}"
            nix-update ${lib.escapeShellArg name} --flake --use-update-script
          '') (lib.attrNames updatable)}
          ${lib.optionalString (skipped != { }) ''
            echo
            echo "Without an automatic updater: ${lib.concatStringsSep " " (lib.attrNames skipped)}"
          ''}
        '';
      };
    in
    {
      apps = {
        vm = {
          type = "app";
          program = "${host.config.system.build.vm}/bin/run-${hostName}-vm";
        };

        update-pkgs = {
          type = "app";
          program = "${updatePkgs}/bin/update-pkgs";
        };
      };
    };
}
