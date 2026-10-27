{ config, ... }:

{
  flake.modules.nixos.workstation = {
    imports = map (name: config.flake.modules.nixos.${name}) [
      "btrfs"
      "databases"
      "etc-hosts"
      "hardware"
      "hlds"
      "workstation-home-manager"
      "workstation-system"
      "monitors"
      "mullvad"
      "samba"
      "vm"
    ];
  };
}
