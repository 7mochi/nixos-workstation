_:

{
  flake.modules.nixos.users =
    {
      config,
      identity,
      pkgs,
      ...
    }:

    let
      normalUser = name: {
        isNormalUser = true;
        description = name;
        extraGroups = [
          "docker"
          "libvirtd"
          "networkmanager"
          "users"
          "wheel"
        ];
        shell = pkgs.fish;
      };
    in
    {
      users.mutableUsers = false;

      users.users.${identity.username} = normalUser identity.username // {
        inherit (identity) uid;
        hashedPasswordFile = config.sops.secrets.password.path;
      };

      programs.fish.enable = true;
    };
}
