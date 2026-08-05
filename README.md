# NixOS Workstation

Personal NixOS config for a Niri desktop with Noctalia.

## What Is Here

```text
flake.nix               flake inputs and the import-tree entry point
modules/flake/          flake-parts outputs, checks, formatter, templates, packages
modules/hosts/          host definitions and hardware config
modules/nixos/          system modules for boot, hardware, desktop, storage, dev tools
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

Custom packages follow the same split: derivations live in `pkgs/<name>/default.nix`
and are exposed as flake outputs by `modules/flake/packages.nix` (they cannot live
under `modules/`, where `import-tree` treats every file as a flake-parts module).
Run one with `nix run .#<name>` and update it with `nix-update <name> --flake`.

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
```

The Fish aliases live in `modules/home/shared/programs/fish.nix` and pick the
host from `$hostname` automatically. The repo commands live in `Justfile`,
which defaults to host `workstation`; override with
`NIXOS_HOST=7mochi-vm just rebuild`.

## Fresh Install

Both hosts mount a single btrfs volume by disk UUID. `/` lives on the btrfs
top-level, `/home` and `/nix` are subvolumes:

```text
<root-partition>  btrfs, mounted at / (top-level), /home (subvol home), /nix (subvol nix)
```

`7mochi-vm` has no separate boot partition: GRUB runs in legacy mode (no ESP).
`workstation` adds a FAT32 ESP at `/boot` (systemd-boot, UEFI) and a swap
partition; its devices are pinned in `modules/hosts/workstation/hardware.nix`.

Format the root partition and create the subvolumes:

```sh
mkfs.btrfs <root-partition>

mount /dev/disk/by-uuid/<root-uuid> /mnt
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/nix
umount /mnt
```

Mount the target:

```sh
mount -o compress=zstd,noatime /dev/disk/by-uuid/<root-uuid> /mnt
mkdir -p /mnt/home /mnt/nix
mount -o subvol=home,compress=zstd,noatime /dev/disk/by-uuid/<root-uuid> /mnt/home
mount -o subvol=nix,compress=zstd,noatime /dev/disk/by-uuid/<root-uuid> /mnt/nix
```

Install:

```sh
sudo nixos-install --flake /mnt/path/to/Documents/nixos-workstation#workstation
```

The disk UUIDs are committed per host in `modules/hosts/<host>/hardware.nix`
(`workstation` also pins its ESP and swap UUIDs). After formatting a new disk,
capture its UUIDs with `blkid` and update that file:

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

Outputs are declared per host. `workstation` pins its monitors in
`modules/hosts/workstation/outputs.nix`, Xiaomi Mi Monitor at 2560x1440@180 Hz (primary, left) and GIGABYTE G24F at 1920x1080@165 Hz (right). The VM has no output config and lets niri pick automatically.

Inspect connected outputs and their exact mode strings:

```sh
niri msg outputs
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
- `docs/system.md`: boot, storage, secrets.
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
