{ config, ... }:

{
  flake.modules.nixos.workstation = {
    imports = map (name: config.flake.modules.nixos.${name}) [
      "btrfs"
      "databases"
      "etc-hosts"
      "hardware"
      "workstation-home-manager"
      "monitors"
      "mullvad"
      "samba"
      "vm"
    ];
  };
}
