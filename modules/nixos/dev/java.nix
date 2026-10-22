_:

{
  flake.modules.nixos.java =
    { pkgs, ... }:

    {
      environment.sessionVariables.JAVA_HOME = "${pkgs.jdk25.home}";
      environment.systemPackages = with pkgs; [
        # Java 25 LTS toolchain.
        jdk25
      ];
    };
}
