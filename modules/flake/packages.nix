_:

{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        citron-nextendo = pkgs.callPackage ../../pkgs/citron-nextendo { };
        ctr-nitro-fueled-appimage = pkgs.callPackage ../../pkgs/ctr-nitro-fueled-appimage { };
        osu-lazer-torii-appimage = pkgs.callPackage ../../pkgs/osu-lazer-torii-appimage { };
        power-bomberman = pkgs.callPackage ../../pkgs/power-bomberman { };
        retrogecko = pkgs.callPackage ../../pkgs/retrogecko { };
      };
    };
}
