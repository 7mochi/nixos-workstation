{ config, ... }:

{
  flake.modules.nixos.system-desktop = {
    imports = [
      config.flake.modules.nixos.system-minimal
    ]
    ++ map (name: config.flake.modules.nixos.${name}) [
      "audio"
      "deadband"
      "desktop-services"
      "docker"
      "fonts"
      "git"
      "go"
      "graphics"
      "home-manager"
      "java"
      "niri"
      "noctalia"
      "polkit"
      "power"
      "rust"
      "sddm"
      "virtualisation"
      "wayland"
      "web"
      "zram"
    ];
  };
}
