# System

These notes cover the system-level pieces that are easy to forget when changing
the workstation.

## Boot

Boot modules live under `modules/nixos/boot/`.

- `kernel.nix` enables the shared CachyOS BORE kernel. The bootloader is set in
  `modules/hosts/workstation/hardware.nix`: systemd-boot UEFI with a FAT32 ESP
  at `/boot`.

## Storage

Storage modules live under `modules/nixos/storage/`.

- `btrfs.nix` adds compression, `noatime`, scrub, and fstrim.

The host hardware module expects a single btrfs volume mounted by disk UUID:

```text
<root-uuid>  btrfs mounted at / (top-level), /home (subvol home), /nix (subvol nix)
```

The workstation additionally pins a swap partition and its ESP UUID in
`modules/hosts/workstation/hardware.nix`.

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
decrypted, and the edit identity derived from it once (sops looks for
`~/.config/sops/age/keys.txt`; `ssh-to-age` and `sops` are already in the system
profile, no `nix-shell` needed):

```sh
# 1. One-time: set up the age edit identity from the host SSH key (sudo to
#    read /etc/ssh; the file must stay private)
mkdir -p ~/.config/sops/age
sudo bash -c 'ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key' > ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# 2. Get the public age key (used for .sops.yaml creation rules)
ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub

# 3. Create or edit an encrypted secrets file
cd ~/Documents/nixos-workstation
sops secrets/secrets.yaml
#   each key becomes a secret, e.g.:
#   opencode-api-key: <KEY>

# 4. Commit the encrypted file, then rebuild
just rebuild
```

If `sops` fails with "Failed to get the data key required to decrypt the SOPS
file ... Did not find keys in ... `~/.config/sops/age/keys.txt`", the edit
identity is missing or stale, run step 1 again. The derived public key must
match one of the recipients in `.sops.yaml`; the host SSH keys are restored
from backup when reinstalling (see `docs/installation.md`), so a restored key
keeps the same age identity.

Declare each secret in `modules/nixos/security/secrets.nix` (`sops.secrets`).
Each one is decrypted at activation time to `/run/secrets/<name>` with the
configured owner/group/mode.

### Recipients

Each machine derives its own age key from its SSH host key. Private keys are
never shared or committed. A machine can decrypt a secret only if its age
public key is listed in `.sops.yaml`.

The repo currently has one recipient, the workstation's `main_workstation`, so
only this machine can decrypt the secrets. Because it is the only key, keep a
private backup of it: if the workstation is lost, `secrets/secrets.yaml` cannot
be decrypted. Back up `/etc/ssh/ssh_host_ed25519_key` (and
`~/.config/sops/age/keys.txt`) to a safe place outside the machine.

To add a machine, add its recipient to the same `key_groups` entry. Do not put
a leading `-` before `age:`, that enables Shamir secret sharing and requires
every key:

```yaml
keys:
  - &main_workstation age1xxxx...
  - &new_machine age1xxxx...
creation_rules:
  - path_regex: secrets/[^/]+\.yaml$
    key_groups:
      - age:
          - *main_workstation
          - *new_machine
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
