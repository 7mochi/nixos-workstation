_:

{
  flake.modules.nixos.workstation =
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
