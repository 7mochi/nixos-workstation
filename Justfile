set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

flake := "path:$HOME/Documents/nixos-workstation"
host := env_var_or_default("NIXOS_HOST", "workstation")

fmt:
    nix fmt

check:
    nix flake check --no-build {{flake}}

dry-build:
    nix build {{flake}}#nixosConfigurations.{{host}}.config.system.build.toplevel --dry-run

rebuild:
    nh os switch {{flake}}#{{host}}

update:
    nix flake update --flake {{flake}}
    nh os switch {{flake}}#{{host}}

diff:
    nix build {{flake}}#nixosConfigurations.{{host}}.config.system.build.toplevel
    nvd diff /run/current-system result

doctor: check dry-build
    nix eval --raw {{flake}}#nixosConfigurations.{{host}}.config.home-manager.users.nanamochi.programs.fish.enable

outputs:
    niri msg outputs

windows:
    niri msg windows
