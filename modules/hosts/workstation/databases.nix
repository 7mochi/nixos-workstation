_:

{
  flake.modules.nixos.databases =
    { config, pkgs, ... }:

    {
      services = {
        mysql = {
          enable = true;
          package = pkgs.mariadb;
          settings.mysqld.bind-address = "127.0.0.1";
        };

        redis = {
          servers."" = {
            enable = true;
          };
        };
      };

      systemd.services.mysql-set-root-password = {
        description = "Set the MariaDB root password";
        after = [ "mysql.service" ];
        wants = [ "mysql.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          ${config.services.mysql.package}/bin/mariadb -u root -e "
            ALTER USER 'root'@'localhost'
              IDENTIFIED VIA mysql_native_password USING PASSWORD('root')
              OR unix_socket;
          "
        '';
      };
    };
}
