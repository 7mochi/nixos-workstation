_:

{
  flake.modules.nixos.shared =
    { config, ... }:
    {
      sops = {
        defaultSopsFile = ../../../secrets/secrets.yaml;
        secrets = {
          "opencode-api-key" = {
            owner = config.users.users.nanamochi.name;
            group = config.users.users.nanamochi.group;
            mode = "0440";
          };
          "commandcode-api-key" = {
            owner = config.users.users.nanamochi.name;
            group = config.users.users.nanamochi.group;
            mode = "0440";
          };
          "inferx-api-key" = {
            owner = config.users.users.nanamochi.name;
            group = config.users.users.nanamochi.group;
            mode = "0440";
          };
          "radeon-api-key" = {
            owner = config.users.users.nanamochi.name;
            group = config.users.users.nanamochi.group;
            mode = "0440";
          };
          "mullvad-account" = {
            owner = "root";
          };
        };
      };
    };
}
