{ inputs, ... }:

let
  nixSettings = import ../../../lib/nix-settings.nix;
  pkgsPolicy = import ../../../lib/pkgs-policy.nix { lib = inputs.nixpkgs.lib; };
in
{
  flake.modules.nixos.nix =
    { identity, ... }:

    {
      nixpkgs.config.allowUnfreePredicate = pkgsPolicy.predicate pkgsPolicy.system;

      nix = {
        registry = builtins.mapAttrs (_name: value: { flake = value; }) (
          removeAttrs inputs [
            "deadband-src"
            "qylock"
            "quarkus-skills"
          ]
        );

        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];

          trusted-users = [
            "root"
            identity.username
          ];

          inherit (nixSettings) substituters;

          trusted-public-keys = nixSettings.trustedPublicKeys;

          fallback = true;
          connect-timeout = 5;

          auto-optimise-store = false;
          max-jobs = 4;
          cores = 0;
          keep-outputs = true;
        };

        gc.automatic = false;

        optimise = {
          automatic = true;
          dates = [ "03:45" ];
        };
      };

      documentation.nixos.enable = false;

      programs.nh = {
        enable = true;
        clean = {
          enable = true;
          dates = "daily";
          extraArgs = "--keep 5 --no-gcroots";
        };
      };
    };
}
