{ lib }:

let
  system = [
    "intellij-idea"
    "intellij-idea-with-plugins"
    "obsidian"
    "rider"
    "rider-with-plugins"
    "steam"
    "steam-run"
    "steam-unwrapped"
    "stremio-linux-shell"
    "vscode"
    "unrar"
    "vmware-workstation"
    "wootility"
  ];

  perSystem = [
    "retrogecko"
    "power-bomberman"
  ];
in
{
  inherit system perSystem;

  predicate = names: pkg: builtins.elem (lib.getName pkg) names;
}
