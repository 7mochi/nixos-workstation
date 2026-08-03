{ config, ... }:

{
  flake.modules.homeManager.nanamochi = {
    imports = [
      config.flake.modules.homeManager.shared
    ];

    home = {
      username = "nanamochi";
      homeDirectory = "/home/nanamochi";
      stateVersion = "26.05";
    };

    programs.home-manager.enable = true;

    xdg.userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}
