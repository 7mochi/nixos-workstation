{ config, ... }:

{
  flake.modules.nixos.shared = {
    imports = map (name: config.flake.modules.nixos.${name}) [
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
      "kernel"
      "keyring"
      "locale"
      "networking"
      "niri"
      "nix"
      "noctalia"
      "packages"
      "polkit"
      "power"
      "rust"
      "sddm"
      "sops"
      "ssh"
      "users"
      "virtualisation"
      "wayland"
      "web"
      "zram"
    ];
  };
}
