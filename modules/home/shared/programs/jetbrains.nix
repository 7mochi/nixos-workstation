{ inputs, ... }:

{
  flake.modules.homeManager.shared =
    { pkgs, ... }:

    {
      home.packages = [
        (inputs.nix-jetbrains-plugins.lib.buildIdeWithPlugins pkgs "idea" [
          "izhangzhihao.rainbow.brackets"
          "com.junkfactory.tokyodark"
          "String Manipulation"
          "com.github.copilot"
        ])
      ];

      home.file.".config/JetBrains/IntelliJIdea2026.2/options/colors.scheme.xml".text = ''
        <application>
          <component name="EditorColorsManagerImpl">
            <global_color_scheme name="TokyoDark" />
          </component>
        </application>
      '';

      home.file.".config/JetBrains/IntelliJIdea2026.2/options/laf.xml".text = ''
        <application>
          <component name="LafManager">
            <laf themeId="com.junkfactory.tokyodark" />
          </component>
        </application>
      '';
    };
}
