_:

{
  flake.modules.nixos.packages =
    { pkgs, ... }:

    {
      environment.systemPackages = with pkgs; [
        git
        wget
        curl
      ];
    };
}
