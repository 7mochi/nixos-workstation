{ inputs, ... }:

{
  flake.modules.nixos.shared =
    { pkgs, ... }:

    {
      environment.systemPackages = [
        inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
}
