_:

{
  flake.modules.homeManager.rea =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.ghidra ];

      home.sessionVariables.GHIDRA_INSTALL_DIR = "${pkgs.ghidra}/lib/ghidra";
    };
}
