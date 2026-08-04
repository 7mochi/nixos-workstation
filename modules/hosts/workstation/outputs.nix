{
  flake.modules.nixos.workstation = {
    home-manager.users.nanamochi.programs.niri.settings.outputs = {
      "Xiaomi Corporation Mi Monitor 5745300008782" = {
        mode = {
          width = 2560;
          height = 1440;
          refresh = 180.0;
        };
        scale = 1.0;
        position = {
          x = 0;
          y = 0;
        };
        focus-at-startup = true;
      };

      "GIGA-BYTE TECHNOLOGY CO., LTD. GIGABYTE G24F 21180B001914" = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 165.0;
        };
        scale = 1.0;
        position = {
          x = 2560;
          y = 0;
        };
      };
    };
  };
}
