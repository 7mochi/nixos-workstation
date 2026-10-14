_:

{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        citron-nextendo = pkgs.callPackage ../../pkgs/citron-nextendo { };
        osu-lazer-torii-appimage = pkgs.callPackage ../../pkgs/osu-lazer-torii-appimage { };
        power-bomberman = pkgs.callPackage ../../pkgs/power-bomberman { };
        retrogecko = pkgs.callPackage ../../pkgs/retrogecko { };
      };
    };
}
