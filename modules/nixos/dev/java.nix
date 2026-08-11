_:

{
  flake.modules.nixos.shared =
    { pkgs, ... }:

    {
      environment.systemPackages = with pkgs; [
        # Java 25 LTS toolchain.
        jdk25
      ];
    };
}
