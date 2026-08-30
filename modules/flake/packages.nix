{
  inputs,
  lib,
  ...
}:

{
  perSystem =
    { system, pkgs, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfreePredicate =
            pkg:
            builtins.elem (lib.getName pkg) [
              "retrogecko"
              "steam-unwrapped"
            ];
        };
      };

      packages = {
        osu-lazer-torii-appimage = pkgs.callPackage ../../pkgs/osu-lazer-torii-appimage { };
        retrogecko = pkgs.callPackage ../../pkgs/retrogecko { };
      };
    };
}
