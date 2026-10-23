{ config, ... }:

{
  flake.modules.nixos.shared = {
    imports = [ config.flake.modules.nixos.system-desktop ];
  };
}
