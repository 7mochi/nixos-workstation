_:

{
  flake.modules.nixos.power = {
    services = {
      fwupd.enable = true;
      power-profiles-daemon.enable = true;
      upower.enable = true;
    };

    systemd.services.fwupd-refresh = {
      after = [ "polkit.service" ];
      wants = [ "polkit.service" ];
    };
  };
}
