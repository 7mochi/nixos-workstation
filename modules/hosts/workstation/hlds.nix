_:

{
  flake.modules.nixos.hlds =
    { pkgs, ... }:

    let
      images = {
        public = "docker.io/jives/hlds:valve@sha256:83dccc68c2aa0711cf04c31bab67c41a502dec47379127162e0e9f85d2861630";
        legacy = "docker.io/jives/hlds:valve-legacy@sha256:bc239a4817dc36158bca840702c067df25e180c10209d47e7a03e0f0ea247af6";
      };

      rehlds = pkgs.callPackage ../../../pkgs/rehlds/package.nix { };
      docker = "${pkgs.docker}/bin/docker";

      launchScript = pkgs.writeShellScript "hlds-launch" ''
        set -eu

        conf=/run/hlds/launch.conf
        game=valve
        map=crossfire
        engine=stock
        args="+sv_lan 1 +maxplayers 12"

        if [ -f "$conf" ]; then
          game=$(sed -n 's/^GAME=//p' "$conf" | tail -n 1)
          map=$(sed -n 's/^MAP=//p' "$conf" | tail -n 1)
          engine=$(sed -n 's/^ENGINE=//p' "$conf" | tail -n 1)
          args=$(sed -n 's/^ARGS=//p' "$conf" | tail -n 1)
        fi

        [ -n "$game" ] || game=valve
        [ -n "$map" ] || map=crossfire
        [ -n "$engine" ] || engine=stock
        [ -n "$args" ] || args="+sv_lan 1 +maxplayers 12"

        if [ "$engine" = rehlds ]; then
          cp /run/hlds/rehlds/engine_i486.so ./engine_i486.so
          chmod 755 ./engine_i486.so
        fi

        export GAME="$game"
        exec /usr/bin/tini -- ./entrypoint.sh +map "$map" $args
      '';
    in
    {
      virtualisation.oci-containers = {
        backend = "docker";
        containers.hlds = {
          image = "hlds-runtime:current";
          pull = "never";
          autoStart = false;

          entrypoint = "/bin/sh";
          workdir = "/opt/steam/hlds";

          extraOptions = [
            "--network=host"
            "-i"
          ];

          volumes = [
            "${launchScript}:/run/hlds/launch.sh:ro"
            "/var/lib/hlds/launch.conf:/run/hlds/launch.conf:ro"
            "/var/lib/hlds/config-active:/temp/config:ro"
            "/var/lib/hlds/mods:/temp/mods:ro"
            "${rehlds}/lib/engine_i486.so:/run/hlds/rehlds/engine_i486.so:ro"
          ];

          cmd = [ "/run/hlds/launch.sh" ];
        };
      };

      systemd.tmpfiles.rules = [
        "d /var/lib/hlds 0775 root users -"
        "d /var/lib/hlds/config 0775 root users -"
        "d /var/lib/hlds/config/valve 0775 root users -"
        "d /var/lib/hlds/config/ag 0775 root users -"
        "d /var/lib/hlds/mods 0775 root users -"
        "f /var/lib/hlds/config/valve/.keep 0664 root users -"
        "f /var/lib/hlds/config/ag/.keep 0664 root users -"
        "f /var/lib/hlds/mods/.keep 0664 root users -"
        "f /var/lib/hlds/launch.conf 0664 root users -"
        "L /var/lib/hlds/config-active - - - - /var/lib/hlds/config/valve"
        "p /run/hlds-console 0600 root root -"
      ];

      systemd.services.hlds-console-stdin = {
        description = "Keep the HLDS console stdin open";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
          StandardOutput = "file:/run/hlds-console";
          Restart = "always";
        };
      };

      systemd.services.docker-hlds.serviceConfig.StandardInput = "file:/run/hlds-console";

      systemd.services.docker-hlds.preStart = ''
        branch=public
        engine=stock

        if [ -f /var/lib/hlds/launch.conf ]; then
          branch=$(sed -n 's/^BRANCH=//p' /var/lib/hlds/launch.conf | tail -n 1)
          engine=$(sed -n 's/^ENGINE=//p' /var/lib/hlds/launch.conf | tail -n 1)
        fi

        [ -n "$branch" ] || branch=public
        [ -n "$engine" ] || engine=stock

        if [ "$engine" = rehlds ] || [ "$branch" = legacy ]; then
          image="${images.legacy}"
        else
          image="${images.public}"
        fi

        ${docker} image inspect "$image" >/dev/null 2>&1 \
          || ${docker} pull "$image"
        ${docker} tag "$image" hlds-runtime:current
      '';

      networking.firewall.interfaces.enp6s0 = {
        allowedTCPPorts = [ 27015 ];
        allowedUDPPorts = [
          27015
          26900
        ];
      };
    };
}
