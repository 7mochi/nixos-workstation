{ inputs, ... }:

{
  flake.modules.nixos.niri =
    { pkgs, ... }:

    {
      imports = [ inputs.niri.nixosModules.niri ];

      programs.niri = {
        enable = true;
        package = pkgs.niri;
      };
    };
}
