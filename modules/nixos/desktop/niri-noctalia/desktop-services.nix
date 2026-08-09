_:

{
  flake.modules.nixos.shared = {
    hardware.sane.enable = true;

    programs.steam.enable = true;

    services = {
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      flatpak = {
        enable = true;

        packages = [
          "org.vinegarhq.Sober"
        ];

        update.auto = {
          enable = true;
          onCalendar = "daily";
        };
      };

      tumbler.enable = true;
    };
  };
}
