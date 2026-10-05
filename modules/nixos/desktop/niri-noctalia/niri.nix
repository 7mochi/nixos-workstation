_:

{
  flake.modules.nixos.shared =
    { pkgs, ... }:

    {
      programs.niri = {
        enable = true;
        package = pkgs.niri;
      };
    };
}
