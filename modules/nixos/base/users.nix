_:

{
  flake.modules.nixos.shared =
    { pkgs, ... }:

    let
      normalUser = name: {
        isNormalUser = true;
        description = name;
        extraGroups = [
          "docker"
          "networkmanager"
          "users"
          "wheel"
        ];
        shell = pkgs.fish;
      };
    in
    {
      users.mutableUsers = false;

      users.users.nanamochi = normalUser "nanamochi" // {
        uid = 1000;
        hashedPassword = "$6$U8BFYn0uRr9YVvoO$nZg4.eDjSaHyZo1wYlxjfylSj0qHFr4kVNSEdBtzahWHdqeBFou/Xck/0KYnzoZLuYXNewHQqpH0fYqYTOS9b1";
      };

      programs.fish.enable = true;
    };
}
