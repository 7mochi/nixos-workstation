{
  flake.modules.nixos.syncthing =
    { identity, ... }:

    {
      services.syncthing = {
        enable = true;
        openDefaultPorts = true;
        user = identity.username;
        group = "users";
        dataDir = identity.homeDirectory;
        configDir = "${identity.homeDirectory}/.config/syncthing";
      };
    };
}
