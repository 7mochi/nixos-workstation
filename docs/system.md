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

The host hardware module expects a single btrfs volume mounted by disk UUID:

```text
<root-uuid>  btrfs mounted at / (top-level), /home (subvol home), /nix (subvol nix)
```

Use `nixos-rebuild boot` and reboot when changing mount options or filesystem
devices.

## Secrets

Secrets are managed with `sops-nix`. Encrypted files live under `secrets/` and
are committed to the repo; no plaintext secrets belong here.

The age identity is the host SSH key:

```nix
sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
```

That means a fresh machine needs its host SSH key in place before secrets can be
decrypted.

```sh
# 1. One-time: set up the age edit identity from the SSH key
mkdir -p ~/.config/sops/age
nix-shell -p ssh-to-age --run \
  "ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key > ~/.config/sops/age/keys.txt"

# 2. Get the public age key (used for .sops.yaml creation rules)
nix-shell -p ssh-to-age --run "ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub"

# 3. Create or edit an encrypted secrets file
cd ~/Documents/nixos-workstation
nix-shell -p sops --run "sops secrets/secrets.yaml"
#   each key becomes a secret, e.g.:
#   opencode-api-key: <KEY>

# 4. Commit the encrypted file, then rebuild
just rebuild

# 5. Verify a decrypted secret
cat /run/secrets/opencode-api-key
```

Declare each secret in `modules/nixos/security/secrets.nix` (`sops.secrets`).
Each one is decrypted at activation time to `/run/secrets/<name>` with the
configured owner/group/mode.

## Containers

Docker is enabled for workflow compatibility. The `docker` group is effectively
root-equivalent, so do not add users to it casually.

Podman is present as a disabled default. Enable it only when the workflow no
longer depends on Docker socket semantics.
