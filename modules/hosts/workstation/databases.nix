_:

{
  flake.modules.nixos.databases =
    { pkgs, ... }:

    {
      services = {
        mysql = {
          enable = true;
          package = pkgs.mariadb;
        };

        redis = {
          servers."" = {
            enable = true;
          };
        };
      };
    };
}
