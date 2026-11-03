_:

{
  flake.modules.homeManager.godot =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.godot_4 ];

      home.file.".local/share/godot/export_templates".source =
        "${pkgs.godot_4-export-templates-bin}/share/godot/export_templates";
    };
}
