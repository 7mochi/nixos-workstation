{ config, ... }:

{
  flake.modules.homeManager.shared = {
    imports = map (name: config.flake.modules.homeManager.${name}) [
      "agent-skills"
      "cursor"
      "direnv"
      "equibop"
      "fastfetch"
      "fish"
      "git"
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
      "starship"
      "vscode"
      "web-apps"
      "zen"
    ];
  };
}
