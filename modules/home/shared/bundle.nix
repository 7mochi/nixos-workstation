{ config, ... }:

{
  flake.modules.homeManager.shared = {
    imports = map (name: config.flake.modules.homeManager.${name}) [
      "agent-skills"
      "commandcode"
      "cursor"
      "direnv"
      "equibop"
      "fastfetch"
      "fish"
      "git"
      "godot"
      "jetbrains"
      "kitty"
      "niri-animations"
      "niri-appearance"
      "niri-bindings"
      "niri-layout"
      "niri-rules"
      "niri-startup"
      "noctalia"
      "opencode"
      "osu-stable"
      "packages"
      "rea"
      "starship"
      "vscode"
      "web-apps"
      "zen"
    ];
  };
}
