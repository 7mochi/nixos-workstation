_:

{
  flake.modules.nixos.shared =
    { config, pkgs, ... }:

    {
      networking.networkmanager.enable = true;

      services.mullvad-vpn = {
        enable = true;
        gui.enable = true;
        enableEarlyBootBlocking = true;
      };

      systemd.services.mullvad-daemon.environment.MULLVAD_SETTINGS_DIR = "/var/lib/mullvad-vpn";

      systemd.services.mullvad-daemon.postStart =
        let
          mullvad = config.services.mullvad-vpn.package;
        in
        ''
          while ! ${mullvad}/bin/mullvad status >/dev/null 2>&1; do sleep 1; done
          ${mullvad}/bin/mullvad auto-connect set on
          ${mullvad}/bin/mullvad relay set location pe
          ${mullvad}/bin/mullvad lan set allow
          ${mullvad}/bin/mullvad lockdown-mode set on
          ${mullvad}/bin/mullvad dns set default --block-ads --block-trackers --block-malware
        '';

      systemd.services.mullvad-login = {
        after = [ "mullvad-daemon.service" ];
        requires = [ "mullvad-daemon.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "mullvad-login" ''
            if grep -Eq '"logged_out"|"revoked"' /var/lib/mullvad-vpn/device.json 2>/dev/null; then
              ${pkgs.mullvad}/bin/mullvad account login "$(cat /run/secrets/mullvad-account)"
            fi
          '';
        };
      };
    };
}
