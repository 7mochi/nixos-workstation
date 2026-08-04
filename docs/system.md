# System

These notes cover the system-level pieces that are easy to forget when changing
the workstation.

## Boot

Boot modules live under `modules/nixos/boot/`.

- `kernel.nix` enables the shared CachyOS BORE kernel. The bootloader is set
  per-host in `modules/hosts/*/hardware.nix`: the VM uses GRUB in legacy mode
  (no ESP), the workstation uses systemd-boot UEFI with a FAT32 ESP at `/boot`.

## Storage

Storage modules live under `modules/nixos/storage/`.

- `btrfs.nix` adds compression, `noatime`, scrub, and fstrim.

The host hardware module expects a single btrfs volume mounted by disk UUID:

```text
<root-uuid>  btrfs mounted at / (top-level), /home (subvol home), /nix (subvol nix)
```

The workstation additionally pins a swap partition and its ESP UUID in
`modules/hosts/workstation/hardware.nix`; the VM has no swap.

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

### Recipients

Each machine derives its own age key from its SSH host key. Private keys are
never shared or committed. A machine can decrypt a secret only if its age
public key is listed in `.sops.yaml`.

The repo has two recipients, the `vm` and `main_workstation`, so each machine can
decrypt the secrets with its own private key. Keep the recipients in
`.sops.yaml` up to date as machines change, and keep private backups of the keys
so the secrets stay recoverable if a machine is lost.

Add a recipient to the same `key_groups` entry. Do not put a leading `-` before
`age:`, that enables Shamir secret sharing and requires every key:

```yaml
keys:
  - &vm age1xxxx...
  - &main_workstation age1xxxx...
creation_rules:
  - path_regex: secrets/[^/]+\.yaml$
    key_groups:
      - age:
          - *vm
          - *main_workstation
```

Re-encrypt the secrets for the new recipient from any machine that can still
decrypt them:

```sh
nix-shell -p sops --run "sops updatekeys secrets/secrets.yaml"
```

Any backup of the private key is a copy of the decryption key. Keep backups of
`/etc/ssh/ssh_host_ed25519_key` or `~/.config/sops/age/keys.txt` private.

## Containers

Docker is enabled for workflow compatibility. The `docker` group is effectively
root-equivalent, so do not add users to it casually.

Podman is present as a disabled default. Enable it only when the workflow no
longer depends on Docker socket semantics.
