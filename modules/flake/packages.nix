{
  perSystem =
    { pkgs, ... }:
    {
      packages.osu-lazer-torii-appimage = pkgs.callPackage ../../pkgs/osu-lazer-torii-appimage { };
    };
}
