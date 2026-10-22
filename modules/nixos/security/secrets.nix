_:

{
  flake.modules.nixos.shared =
    { config, identity, ... }:
    let
      user = config.users.users.${identity.username};
    in
    {
      sops = {
        defaultSopsFile = ../../../secrets/secrets.yaml;
        secrets = {
          "opencode-api-key" = {
            owner = user.name;
            inherit (user) group;
            mode = "0440";
          };
          "commandcode-api-key" = {
            owner = user.name;
            inherit (user) group;
            mode = "0440";
          };
          "inferx-api-key" = {
            owner = user.name;
            inherit (user) group;
            mode = "0440";
          };
          "radeon-api-key" = {
            owner = user.name;
            inherit (user) group;
            mode = "0440";
          };
          "mullvad-account" = {
            owner = "root";
          };
        };
      };
    };
}
