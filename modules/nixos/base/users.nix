_:

{
  flake.modules.nixos.shared =
    { identity, pkgs, ... }:

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
        hashedPassword = "$6$U8BFYn0uRr9YVvoO$nZg4.eDjSaHyZo1wYlxjfylSj0qHFr4kVNSEdBtzahWHdqeBFou/Xck/0KYnzoZLuYXNewHQqpH0fYqYTOS9b1";
      };

      programs.fish.enable = true;
    };
}
