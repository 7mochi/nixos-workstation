{ config, ... }:

{
  flake.modules.nixos.system-minimal = {
    imports = map (name: config.flake.modules.nixos.${name}) [
      "kernel"
      "keyring"
      "locale"
      "networking"
      "nix"
      "packages"
      "sops"
      "ssh"
      "users"
    ];
  };
}
