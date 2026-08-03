_:

{
  flake.modules.nixos.workstation =
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
      users.users = {
        nanamochi = normalUser "nanamochi";
      };

      programs.fish.enable = true;
    };
}
