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

      systemd.services = {
        mullvad-daemon = {
          environment.MULLVAD_SETTINGS_DIR = "/var/lib/mullvad-vpn";

          postStart =
            let
              mullvad = config.services.mullvad-vpn.package;
            in
            ''
              while ! ${mullvad}/bin/mullvad status >/dev/null 2>&1; do sleep 1; done
              ${mullvad}/bin/mullvad auto-connect set on || true
              ${mullvad}/bin/mullvad relay set location pe || true
              ${mullvad}/bin/mullvad lan set allow || true
              ${mullvad}/bin/mullvad lockdown-mode set on || true
              ${mullvad}/bin/mullvad dns set default --block-ads --block-trackers --block-malware || true
            '';
        };

        mullvad-login = {
          after = [
            "mullvad-daemon.service"
            "network-online.target"
          ];
          requires = [ "mullvad-daemon.service" ];
          wants = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = pkgs.writeShellScript "mullvad-login" ''
              while ! ${pkgs.mullvad}/bin/mullvad status >/dev/null 2>&1; do sleep 1; done
              if ${pkgs.mullvad}/bin/mullvad account get 2>/dev/null | grep -qi 'not logged in'; then
                for _ in $(${pkgs.coreutils}/bin/seq 1 60); do
                  ${pkgs.mullvad}/bin/mullvad account login "$(cat /run/secrets/mullvad-account)" && exit 0
                  sleep 2
                done
                exit 1
              fi
            '';
          };
        };
      };
    };
}
