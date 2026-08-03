# System

These notes cover the system-level pieces that are easy to forget when changing
the workstation.

## Boot

Boot modules live under `modules/nixos/boot/`.

- `kernel.nix` enables the shared CachyOS BORE kernel. The bootloader is set
  per-host in `modules/hosts/*/hardware.nix`; the VM uses GRUB in legacy mode
  (no ESP).

## Storage

Storage modules live under `modules/nixos/storage/`.

- `btrfs.nix` adds compression, `noatime`, scrub, and fstrim.
- `impermanence.nix` is gated behind `workstation.impermanence.enable`.

The host hardware module expects a single btrfs volume mounted by disk UUID:

```text
<root-uuid>  btrfs mounted at / (top-level), /home (subvol home), /nix (subvol nix)
```

Use `nixos-rebuild boot` and reboot when changing mount options or filesystem
devices.

## Impermanence

Impermanence is prepared, not enabled by default.

Before enabling it, make sure `/persist` exists and that the persistence list
covers the state you actually use. Pay special attention to:

```text
/etc/NetworkManager/system-connections
/var/lib/bluetooth
/var/lib/docker
/var/lib/nixos
/var/log
~/.local/share/keyrings
~/.ssh
~/.mozilla
~/.local/state/noctalia
~/.cache/noctalia
~/Pictures/Wallpapers
```

The user directory list is shared between `nanamochi` and future users to avoid drift.

## Secrets

Secrets are wired through `sops-nix`, but no plaintext secrets belong in this
repo.

The default age key source is the host SSH key:

```nix
sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
```

That means a fresh machine needs its host SSH key in place before secrets can be
decrypted.

## Containers

Docker is enabled for workflow compatibility. The `docker` group is effectively
root-equivalent, so do not add users to it casually.

Podman is present as a disabled default. Enable it only when the workflow no
longer depends on Docker socket semantics.
