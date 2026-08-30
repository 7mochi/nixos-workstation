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
              "power-bomberman"
            ];
        };
      };

      packages = {
        osu-lazer-torii-appimage = pkgs.callPackage ../../pkgs/osu-lazer-torii-appimage { };
        power-bomberman = pkgs.callPackage ../../pkgs/power-bomberman { };
        retrogecko = pkgs.callPackage ../../pkgs/retrogecko { };
      };
    };
}
