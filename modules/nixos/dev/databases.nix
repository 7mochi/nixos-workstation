_:

{
  flake.modules.nixos.shared =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    {
      services = {
        mysql = lib.mkIf (config.networking.hostName == "workstation") {
          enable = true;
          package = pkgs.mariadb;
        };

        redis = lib.mkIf (config.networking.hostName == "workstation") {
          servers."" = {
            enable = true;
          };
        };
      };
    };
}
