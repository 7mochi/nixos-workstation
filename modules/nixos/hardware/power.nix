_:

{
  flake.modules.nixos.shared = {
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
