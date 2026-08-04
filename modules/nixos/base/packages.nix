_:

{
  flake.modules.nixos.shared =
    { pkgs, ... }:

    {
      environment.systemPackages = with pkgs; [
        git
        wget
        curl
      ];
    };
}
