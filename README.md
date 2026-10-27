# NixOS Workstation

Personal NixOS config for a Niri desktop with Noctalia.

## What Is Here

```text
flake.nix               flake inputs and the import-tree entry point
modules/flake/          flake-parts outputs, checks, formatter, templates, packages
modules/hosts/          host definitions, hardware, and host-only modules
modules/nixos/          generic system modules (boot, hardware, desktop, security, dev)
modules/home/shared/    shared Home Manager profile for the desktop and CLI
modules/home/nanamochi/ personal user account module
pkgs/                   custom package derivations (e.g. osu-lazer-torii-appimage)
templates/              project templates exposed by the flake
docs/                   workflow and template notes
secrets/                sops-nix notes, no plaintext secrets
```

The config uses a dendritic flake layout: files under `modules/` are imported by
`import-tree` and merge into shared module outputs such as
`flake.modules.nixos.shared` and `flake.modules.homeManager.shared`.

Custom packages live in `pkgs/<name>/package.nix` and are exposed automatically
by `pkgs-by-name-for-flake-parts`, they cannot live under `modules/`, where
`import-tree` treats every file as a flake-parts module. Run one with
`nix run .#<name>`, reference it as `pkgs.local.<name>` inside the flake, and
update it with `nix-update <name> --flake`. `just update-pkgs` discovers every
package with a `passthru.updateScript` and runs `nix-update --use-update-script`;
packages without one are reported and must be bumped by hand.

## Daily Use

From the shell:

```sh
check
drybuild
rebuild
update
doctor
```

From the repo:

```sh
just check
just dry-build
just rebuild
just diff
just doctor
just update-pkgs
```

The Fish aliases live in `modules/home/shared/programs/fish.nix` and pick the
host from `$hostname` automatically. The repo commands live in `Justfile`,
which defaults to host `workstation` (override with `NIXOS_HOST=<name> just
rebuild` if you add a machine).

## Fresh Install

The root is a single ext4 partition mounted by disk UUID, `/home` and `/nix` are
plain directories on it (no subvolumes). The data disks `/media/ssd` and
`/media/hdd` stay btrfs.

```text
<root-partition>  ext4, mounted at /
```

The workstation uses systemd-boot UEFI with a FAT32 ESP at `/boot` and a swap
partition, its devices are pinned in `modules/hosts/workstation/hardware.nix`.

Format the root partition:

```sh
mkfs.ext4 <root-partition>
```

Mount the target:

```sh
mount /dev/disk/by-uuid/<root-uuid> /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-uuid/<esp-uuid> /mnt/boot
```

Install:

```sh
sudo nixos-install --flake /mnt/path/to/Documents/nixos-workstation#workstation
```

The disk UUIDs are committed in `modules/hosts/workstation/hardware.nix`
(including the ESP and swap UUIDs). After formatting a new disk, capture its
UUIDs with `blkid` and update that file:

```sh
blkid -o value -s UUID <root-partition>
```

## Safe Rebuilds

Normal rebuild:

```sh
nix flake check --no-build path:$HOME/Documents/nixos-workstation
sudo nixos-rebuild switch --flake path:$HOME/Documents/nixos-workstation#workstation
```

When changing filesystems or mount options, build the next generation for boot
and reboot into it:

```sh
sudo nixos-rebuild boot --flake path:$HOME/Documents/nixos-workstation#workstation
sudo reboot
```

That avoids restarting active mounts such as `/home` inside the running session.

## Niri And Noctalia

Niri is enabled through `sodiboo/niri-flake`. The Home Manager config is split
into focused files under `modules/home/shared/desktop/niri/`:

```text
appearance.nix  raw KDL extras for Noctalia blur/backdrop integration
animations.nix  animation tuning and shaders
bindings.nix    keybindings
layout.nix      input and layout settings
rules.nix       window rules
startup.nix     compositor startup commands
```

Noctalia starts from Niri with `spawn-at-startup`. Keep a single startup path
unless there is a concrete reason to move to a systemd user service.

Noctalia has declarative config and runtime state:

- Declarative settings: `modules/home/shared/desktop/noctalia.nix`
- Runtime settings: `~/.local/state/noctalia/settings.toml`
- Wallpaper choice cache: `~/.cache/noctalia/wallpapers.json`

## Monitors

Outputs are declared per host. The workstation pins its monitors in
`modules/hosts/workstation/monitors.nix`: Xiaomi Mi Monitor at 2560x1440@180 Hz
(primary, left) and GIGABYTE G24F at 1920x1080@165 Hz (right).

Inspect connected outputs and their exact mode strings:

```sh
niri msg outputs
```

## HLDS Server

The workstation runs a LAN-only Half-Life Dedicated Server as an OCI container
through `virtualisation.oci-containers`, using Docker and host networking. It
runs with `+sv_lan 1`, is reachable only on the LAN interface `enp6s0`, and the
NixOS firewall allows TCP/UDP `27015` and UDP `26900` there, so it is not
exposed through the WAN or Mullvad.

- Module: `modules/hosts/workstation/hlds.nix`
- Runtime state: `/var/lib/hlds/launch.conf` (`GAME`, `MAP`, `ARGS`)
- Config: `/var/lib/hlds/config/<game>`, active via `/var/lib/hlds/config-active`
- Mods: `/var/lib/hlds/mods` (AG lives in `mods/ag`)
- Switch: `hlds game ag ag_crossfire`, `hlds map <map>`, `hlds args ...`
- Manage: `hlds <status|start|stop|restart|logs|game|map|args|mods|config|info|ip|console|shell>`
  (`hlds` with no argument shows the service status)
- Console: `hlds console` (detach with `Ctrl-P`, `Ctrl-Q`)
- Logs: `hlds logs` or `journalctl CONTAINER_NAME=hlds -f`
- Detailed operations: `docs/system.md#hlds-server`

Switching game, map, or arguments does not require a rebuild; `hlds` updates
`launch.conf` and restarts the unit.

The image is pinned by digest. To update it, resolve the current digest and
change the `image` value:

```sh
nix run nixpkgs#skopeo -- inspect --format '{{.Digest}}' docker://docker.io/jives/hlds:valve
```

## Development

Use `mise` for per-project runtime versions:

```sh
mise use node@24
mise use bun@latest
mise use python@3.13
```

Use `direnv` with `nix-direnv` for Nix project shells:

```sh
echo "use flake" > .envrc
direnv allow
```

Project templates are exposed by the flake:

```sh
nix flake init -t path:$HOME/Documents/nixos-workstation#node
nix flake init -t path:$HOME/Documents/nixos-workstation#bun
nix flake init -t path:$HOME/Documents/nixos-workstation#python
nix flake init -t path:$HOME/Documents/nixos-workstation#rust
nix flake init -t path:$HOME/Documents/nixos-workstation#local-services
```

More notes:

- `docs/installation.md`: hosts, fresh install, reinstall, post install.
- `docs/desktop.md`: Niri, Noctalia, SDDM, portals, cursor handling.
- `docs/system.md`: boot, storage, secrets, HLDS server.
- `docs/dev-workflows.md`: daily development workflow.
- `docs/dev-templates.md`: project templates.

## Git Notes

Local flake evaluation only sees files tracked by Git when using `.#...`. After
adding an imported module, stage it before evaluating:

```sh
git add path/to/new-file.nix
```

For quick checks without staging, use an explicit path flake reference:

```sh
nix flake check --no-build path:$HOME/Documents/nixos-workstation
```
