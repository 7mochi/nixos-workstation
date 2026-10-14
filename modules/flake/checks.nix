{ config, inputs, ... }:

{
  perSystem =
    { pkgs, ... }:
    let
      hosts = config.flake.nixosConfigurations;
      hostName = builtins.head (builtins.attrNames hosts);
      host = hosts.${hostName};
      homeUser = builtins.head (builtins.attrNames host.config.home-manager.users);
    in
    {
      checks = {
        "nixos-${hostName}" = host.config.system.build.toplevel;

        format =
          pkgs.runCommand "check-nix-format"
            {
              nativeBuildInputs = [
                pkgs.findutils
                pkgs.nixfmt
              ];
            }
            ''
              cp -r ${inputs.self} source
              chmod -R u+w source
              cd source
              find . -path ./.git -prune -o -type f -name "*.nix" -print0 | xargs -0 nixfmt --check
              touch $out
            '';

        deadnix =
          pkgs.runCommand "check-deadnix"
            {
              nativeBuildInputs = [
                pkgs.deadnix
              ];
            }
            ''
              deadnix --fail ${inputs.self}
              touch $out
            '';

        statix =
          pkgs.runCommand "check-statix"
            {
              nativeBuildInputs = [
                pkgs.statix
              ];
            }
            ''
              statix check ${inputs.self}
              touch $out
            '';

        check-secrets =
          pkgs.runCommand "check-secrets"
            {
              nativeBuildInputs = [
                pkgs.findutils
                pkgs.gnugrep
              ];
            }
            ''
              cd ${inputs.self}

              # Private-key needles, split so this check's own source does not
              # match itself when the tree is scanned.
              needles=(
                "AGE-""SECRET-KEY-1"
                "BEGIN ""OPENSSH PRIVATE KEY"
                "BEGIN ""RSA PRIVATE KEY"
                "BEGIN ""EC PRIVATE KEY"
                "BEGIN ""PRIVATE KEY"
              )

              status=0

              while IFS= read -r -d "" file; do
                for needle in "''${needles[@]}"; do
                  if grep -qF -- "$needle" "$file"; then
                    echo "potential plaintext secret ($needle) in $file" >&2
                    status=1
                  fi
                done
              done < <(find . -path ./.git -prune -o -path ./docs -prune -o -path ./reports -prune -o -path ./research_notes -prune -o -type f -print0)

              for file in secrets/*.yaml; do
                if ! grep -q "^sops:" "$file"; then
                  echo "secrets file is not sops-encrypted: $file" >&2
                  status=1
                fi
              done

              [ "$status" -eq 0 ]
              touch $out
            '';

        niri-no-app-workflows =
          pkgs.runCommand "check-niri-no-app-workflows"
            {
              niriConfig = host.config.home-manager.users.${homeUser}.programs.niri.finalConfig;
              passAsFile = [ "niriConfig" ];
            }
            ''
              grep -F 'default-column-width { proportion 0.500000; }' "$niriConfigPath"

              if grep -F 'open-on-workspace' "$niriConfigPath"; then
                echo "app-specific workspace routing is disabled" >&2
                exit 1
              fi

              for width in \
                'default-column-width { fixed ' \
                'default-column-width { proportion 0.333330; }' \
                'default-column-width { proportion 0.666670; }' \
                'default-column-width { proportion 0.750000; }' \
                'default-column-width { proportion 1.000000; }'
              do
                if grep -F "$width" "$niriConfigPath"; then
                  echo "non-half default column widths are disabled" >&2
                  exit 1
                fi
              done

              for workspace in browser code chat gaming aesthetic; do
                if grep -F "workspace \"$workspace\"" "$niriConfigPath"; then
                  echo "app-specific workflow workspace '$workspace' is disabled" >&2
                  exit 1
                fi
              done

              touch $out
            '';

        fwupd-refresh-polkit-ordering =
          let
            fwupdRefresh = host.config.systemd.services.fwupd-refresh;
          in
          pkgs.runCommand "check-fwupd-refresh-polkit-ordering" { } ''
            ${
              if builtins.elem "polkit.service" fwupdRefresh.wants then
                "true"
              else
                "echo 'fwupd-refresh.service should want polkit.service' >&2; exit 1"
            }
            ${
              if builtins.elem "polkit.service" fwupdRefresh.after then
                "true"
              else
                "echo 'fwupd-refresh.service should start after polkit.service' >&2; exit 1"
            }
            touch $out
          '';
      };
    };
}
