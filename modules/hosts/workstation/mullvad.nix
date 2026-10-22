{ lib, ... }:

{
  flake.modules.nixos.mullvad =
    { config, ... }:

    {
      systemd.services.mullvad-daemon.postStart = lib.mkAfter ''
        ${config.services.mullvad-vpn.package}/bin/mullvad relay set location pe || true
      '';
    };
}
