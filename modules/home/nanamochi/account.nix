{ config, ... }:

let
  identity = import ../../../lib/identity.nix;
in
{
  flake.modules.homeManager.nanamochi = {
    imports = [
      config.flake.modules.homeManager.shared
    ];

    home = {
      inherit (identity) username homeDirectory;
      stateVersion = "26.05";
    };

    programs.home-manager.enable = true;

    xdg.userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}
