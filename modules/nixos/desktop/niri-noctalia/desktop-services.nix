{ inputs, ... }:

{
  flake.modules.nixos.desktop-services = {
    imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

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
