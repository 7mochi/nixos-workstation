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
          allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "retrogecko" ];
        };
      };

      packages = {
        osu-lazer-torii-appimage = pkgs.callPackage ../../pkgs/osu-lazer-torii-appimage { };
        retrogecko = pkgs.callPackage ../../pkgs/retrogecko { };
        osu-wine = pkgs.callPackage ../../pkgs/osu-wine { };
      };
    };
}
